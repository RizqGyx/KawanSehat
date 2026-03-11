import Foundation
import Combine

// MARK: - Gemini API Models
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GenerationConfig?
    
    enum CodingKeys: String, CodingKey {
        case contents
        case generationConfig = "generation_config"
    }
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GenerationConfig: Codable {
    let temperature: Float
    let topP: Float?
    let topK: Int?
    let maxOutputTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case temperature
        case topP = "top_p"
        case topK = "top_k"
        case maxOutputTokens = "max_output_tokens"
    }
}

struct GeminiResponse: Codable {
    let candidates: [Candidate]?
    
    struct Candidate: Codable {
        let content: GeminiContent?
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case content
            case finishReason = "finish_reason"
        }
    }
}

// MARK: - Suggestion Response
struct GeminiSuggestion: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let foodName: String
    let suggestion: String
    let alternatives: [String]
    
    init(
        foodName: String,
        suggestion: String,
        alternatives: [String] = []
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.foodName = foodName
        self.suggestion = suggestion
        self.alternatives = alternatives
    }
}

// MARK: - GeminiService
@MainActor
class GeminiService: ObservableObject {
    static let shared = GeminiService()
    
    @Published var isLoading = false
    @Published var suggestions: [GeminiSuggestion] = []
    @Published var errorMessage: String?
    
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    
    init() {
        // Get API key from environment or use a placeholder
        // For production, store this in a secure manner (Keychain, config file, etc.)
        self.apiKey = UserDefaults.standard.string(forKey: "GEMINI_API_KEY") ?? ""
    }
    
    // MARK: - Set API Key
    func setAPIKey(_ key: String) {
        let updatedKey = key.trimmingCharacters(in: .whitespaces)
        UserDefaults.standard.set(updatedKey, forKey: "GEMINI_API_KEY")
    }
    
    // MARK: - Get Health Suggestion from Gemini
    func getHealthSuggestion(
        for food: String,
        userProfile: UserProfile
    ) async -> GeminiSuggestion? {
        guard !apiKey.isEmpty else {
            errorMessage = "API key tidak diatur. Silakan atur Gemini API key terlebih dahulu."
            return nil
        }
        
        isLoading = true
        errorMessage = nil
        
        let prompt = buildPrompt(for: food, userProfile: userProfile)
        
        do {
            let suggestion = try await callGeminiAPI(with: prompt, foodName: food)
            isLoading = false
            
            // Save to history
            suggestions.insert(suggestion, at: 0)
            UserDefaultsService.shared.saveSuggestionHistory(suggestions)
            
            return suggestion
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return nil
        }
    }
    
    // MARK: - Call Gemini API
    private func callGeminiAPI(with prompt: String, foodName: String) async throws -> GeminiSuggestion {
        let part = GeminiPart(text: prompt)
        let content = GeminiContent(parts: [part])
        let config = GenerationConfig(
            temperature: 0.7,
            topP: 0.95,
            topK: 40,
            // Increase max tokens to reduce chance of response being cut off
            maxOutputTokens: 1024
        )
        
        let request = GeminiRequest(contents: [content], generationConfig: config)
        
        var urlRequest = URLRequest(url: URL(string: "\(baseURL)?key=\(apiKey)")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "GeminiAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "API response error"])
        }
        
        let decodedResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        guard let candidate = decodedResponse.candidates?.first,
              let content = candidate.content,
              let textPart = content.parts.first else {
            throw NSError(domain: "GeminiAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        let responseText = textPart.text

        // Debug: Log request/response so we can inspect why output might be cut off
        #if DEBUG
        print("--- Gemini API request prompt ---")
        print(prompt)
        print("--- Gemini API response ---")
        print(responseText)
        #endif

        let (suggestion, alternatives) = parseGeminiResponse(responseText)
        
        return GeminiSuggestion(
            foodName: foodName,
            suggestion: suggestion,
            alternatives: alternatives
        )
    }
    
    // MARK: - Build Prompt
    private func buildPrompt(for food: String, userProfile: UserProfile) -> String {
        return """
        Kamu adalah ahli gizi profesional yang memberikan saran kesehatan dalam bahasa Indonesia.
        
        Data pengguna:
        - Nama: \(userProfile.name)
        - BMI: \(String(format: "%.1f", userProfile.bmi)) (\(userProfile.bmiCategory))
        - Kebutuhan kalori harian: \(String(format: "%.0f", userProfile.tdee)) kcal
        - Budget makanan harian: Rp \(Int(userProfile.dailyBudgetIDR)):,-
        - Level aktivitas: \(userProfile.activityLevel.description)
        
        Makanan yang dipilih: \(food)
        
        Berikan jawaban yang lengkap dan jangan terpotong.
        
        Berikan:
        1. Saran kesehatan singkat (1-2 kalimat) tentang makanan ini dalam konteks kebutuhan pengguna
        2. 2-3 alternatif makanan yang lebih sehat dan terjangkau
        
        Format respons (gunakan ---):
        Saran: [saran kesehatan]
        Alternatif:
        - [alternatif 1]
        - [alternatif 2]
        - [alternatif 3]
        """
    }
    
    // MARK: - Parse Gemini Response
    private func parseGeminiResponse(_ response: String) -> (suggestion: String, alternatives: [String]) {
        var suggestion = ""
        var alternatives: [String] = []
        
        let lines = response.components(separatedBy: .newlines)
        var inAlternatives = false
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.starts(with: "Saran:") {
                suggestion = trimmed.replacingOccurrences(of: "Saran:", with: "").trimmingCharacters(in: .whitespaces)
            } else if trimmed.starts(with: "Alternatif:") {
                inAlternatives = true
            } else if inAlternatives && trimmed.starts(with: "-") {
                let alt = trimmed.replacingOccurrences(of: "-", with: "").trimmingCharacters(in: .whitespaces)
                if !alt.isEmpty {
                    alternatives.append(alt)
                }
            }
        }
        
        // If the model returned a free-form answer without the expected markers,
        // show the full response so it doesn't appear cut off.
        if suggestion.isEmpty {
            suggestion = response.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return (suggestion, alternatives)
    }
    
    // MARK: - Load History
    func loadHistory() {
        suggestions = UserDefaultsService.shared.loadSuggestionHistory()
    }
    
    // MARK: - Clear History
    func clearHistory() {
        suggestions.removeAll()
        UserDefaultsService.shared.saveSuggestionHistory([])
    }
    
    // MARK: - Delete Suggestion
    func deleteSuggestion(_ suggestion: GeminiSuggestion) {
        suggestions.removeAll { $0.id == suggestion.id }
        UserDefaultsService.shared.saveSuggestionHistory(suggestions)
    }
}
