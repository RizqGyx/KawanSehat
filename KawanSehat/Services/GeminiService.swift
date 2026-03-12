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

// MARK: - Smart Meal Recommendation
struct MealRecommendation: Identifiable, Codable {
    let id: UUID
    let mealType: MealType
    let foodName: String
    let description: String
    let calorieInfo: String
    let budgetInfo: String
    let timestamp: Date
    
    enum MealType: String, Codable {
        case breakfast = "Sarapan"
        case lunch = "Makan Siang"
        case dinner = "Makan Malam"
    }
    
    init(
        mealType: MealType,
        foodName: String,
        description: String,
        calorieInfo: String,
        budgetInfo: String
    ) {
        self.id = UUID()
        self.mealType = mealType
        self.foodName = foodName
        self.description = description
        self.calorieInfo = calorieInfo
        self.budgetInfo = budgetInfo
        self.timestamp = Date()
    }
}


// MARK: - GeminiService
@MainActor
class GeminiService: ObservableObject {
    static let shared = GeminiService()
    
    @Published var isLoading = false
    @Published var suggestions: [GeminiSuggestion] = []
    @Published var errorMessage: String?
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    private var currentAPIKeyIndex: Int = 0  // Track which API key we're using
    
    init() {
        // API keys are now stored in APIConfig.swift
        currentAPIKeyIndex = 0
    }
    
    // MARK: - Get Current Active API Key
    private var activeAPIKey: String? {
        if currentAPIKeyIndex < APIConfig.allAPIKeys.count {
            return APIConfig.allAPIKeys[currentAPIKeyIndex]
        }
        return APIConfig.primaryAPIKey
    }
    
    // MARK: - Fallback to Next API Key
    private func switchToNextAPIKey() {
        currentAPIKeyIndex += 1
        if currentAPIKeyIndex >= APIConfig.allAPIKeys.count {
            currentAPIKeyIndex = 0  // Cycle back to first key
        }
        print("🔄 Switched to API key #\(currentAPIKeyIndex + 1)/\(APIConfig.availableKeysCount)")
    }
    
    // MARK: - Get Health Suggestion from Gemini
    func getHealthSuggestion(
        for food: String,
        userProfile: UserProfile
    ) async -> GeminiSuggestion? {
        guard !APIConfig.allAPIKeys.isEmpty else {
            errorMessage = "Tidak ada API key yang tersedia. Silakan set API key di APIConfig.swift"
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
    
    // MARK: - Generic Text Generation
    /// Generate plain text from a prompt (used by other features like Sleep advice)
    func generateText(prompt: String) async throws -> String {
        var lastError: Error?
        let maxRetries = APIConfig.availableKeysCount
        
        for attempt in 0..<maxRetries {
            do {
                guard let apiKey = activeAPIKey else {
                    throw NSError(domain: "GeminiAPI", code: -3, userInfo: [NSLocalizedDescriptionKey: "No API key available"])
                }
                
                let part = GeminiPart(text: prompt)
                let content = GeminiContent(parts: [part])
                let config = GenerationConfig(
                    temperature: 0.7,
                    topP: 0.95,
                    topK: 40,
                    maxOutputTokens: 512
                )
                
                let request = GeminiRequest(contents: [content], generationConfig: config)
                
                var urlRequest = URLRequest(url: URL(string: "\(baseURL)?key=\(apiKey)")!)
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try JSONEncoder().encode(request)
                urlRequest.timeoutInterval = 30
                
                let (data, response) = try await URLSession.shared.data(for: urlRequest)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "GeminiAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                }
                
                switch httpResponse.statusCode {
                case 200:
                    break
                case 400, 401, 403:
                    print("❌ API key invalid (HTTP \(httpResponse.statusCode)). Trying next key...")
                    switchToNextAPIKey()
                    lastError = NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid API key"])
                    if attempt < maxRetries - 1 { continue } else { throw lastError! }
                case 429:
                    print("⚠️ Rate limited (HTTP 429). Trying next key...")
                    switchToNextAPIKey()
                    lastError = NSError(domain: "GeminiAPI", code: 429, userInfo: [NSLocalizedDescriptionKey: "Rate limited"])
                    if attempt < maxRetries - 1 { continue } else { throw lastError! }
                case 500...599:
                    print("⚠️ Server error (HTTP \(httpResponse.statusCode)). Trying next key...")
                    switchToNextAPIKey()
                    lastError = NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                    if attempt < maxRetries - 1 { continue } else { throw lastError! }
                default:
                    throw NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected HTTP response"])
                }
                
                let decodedResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                guard let candidate = decodedResponse.candidates?.first,
                      let content = candidate.content,
                      let textPart = content.parts.first else {
                    throw NSError(domain: "GeminiAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                }
                
                let responseText = textPart.text
                
                #if DEBUG
                print("--- Gemini Generic Request ---")
                print(prompt)
                print("--- Gemini Generic Response ---")
                print(responseText)
                #endif
                
                return responseText.trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                lastError = error
                print("❌ Generic generateText attempt \(attempt + 1)/\(maxRetries) failed: \(error.localizedDescription)")
                if attempt < maxRetries - 1 {
                    switchToNextAPIKey()
                } else {
                    throw error
                }
            }
        }
        
        throw lastError ?? NSError(domain: "GeminiAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "All API keys failed"])
    }
    
    // MARK: - Call Gemini API with Retry & Fallback
    private func callGeminiAPI(with prompt: String, foodName: String) async throws -> GeminiSuggestion {
        var lastError: Error?
        let maxRetries = APIConfig.availableKeysCount
        
        for attempt in 0..<maxRetries {
            do {
                guard let apiKey = activeAPIKey else {
                    throw NSError(domain: "GeminiAPI", code: -3, userInfo: [NSLocalizedDescriptionKey: "No API key available"])
                }
                
                let part = GeminiPart(text: prompt)
                let content = GeminiContent(parts: [part])
                let config = GenerationConfig(
                    temperature: 0.7,
                    topP: 0.95,
                    topK: 40,
                    maxOutputTokens: 1024
                )
                
                let request = GeminiRequest(contents: [content], generationConfig: config)
                
                var urlRequest = URLRequest(url: URL(string: "\(baseURL)?key=\(apiKey)")!)
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try JSONEncoder().encode(request)
                
                // Set timeout to 30 seconds
                urlRequest.timeoutInterval = 30
                
                let (data, response) = try await URLSession.shared.data(for: urlRequest)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "GeminiAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                }
                
                // Check status code
                switch httpResponse.statusCode {
                case 200:
                    // Success
                    break
                case 400, 401, 403:
                    // Invalid API key - try next one
                    print("❌ API key invalid (HTTP \(httpResponse.statusCode)). Trying next key...")
                    switchToNextAPIKey()
                    lastError = NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid API key"])
                    if attempt < maxRetries - 1 {
                        continue
                    } else {
                        throw lastError!
                    }
                case 429:
                    // Rate limited - try next key
                    print("⚠️ Rate limited (HTTP 429). Trying next key...")
                    switchToNextAPIKey()
                    lastError = NSError(domain: "GeminiAPI", code: 429, userInfo: [NSLocalizedDescriptionKey: "Rate limited"])
                    if attempt < maxRetries - 1 {
                        continue
                    } else {
                        throw lastError!
                    }
                case 500...599:
                    // Server error - try next key
                    print("⚠️ Server error (HTTP \(httpResponse.statusCode)). Trying next key...")
                    switchToNextAPIKey()
                    lastError = NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                    if attempt < maxRetries - 1 {
                        continue
                    } else {
                        throw lastError!
                    }
                default:
                    throw NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected HTTP response"])
                }
                
                let decodedResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                
                guard let candidate = decodedResponse.candidates?.first,
                      let content = candidate.content,
                      let textPart = content.parts.first else {
                    throw NSError(domain: "GeminiAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                }
                
                let responseText = textPart.text
                
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
                
            } catch {
                lastError = error
                print("❌ Attempt \(attempt + 1)/\(maxRetries) failed: \(error.localizedDescription)")
                
                if attempt < maxRetries - 1 {
                    switchToNextAPIKey()
                } else {
                    throw error
                }
            }
        }
        
        throw lastError ?? NSError(domain: "GeminiAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "All API keys failed"])
    }
    
    // MARK: - Build Prompt
    private func buildPrompt(for food: String, userProfile: UserProfile) -> String {
        return """
        Ahli gizi yang memberikan saran dalam bahasa Indonesia.
        
        Data pengguna:
        - Nama: \(userProfile.name)
        - BMI: \(String(format: "%.1f", userProfile.bmi))
        - Kalori/hari: \(String(format: "%.0f", userProfile.tdee)) kcal
        - Budget/hari: Rp \(Int(userProfile.dailyBudgetIDR))
        
        Makanan: \(food)
        
        Berikan saran kesehatan singkat (1-2 kalimat) dan 2-3 alternatif lebih sehat.
        
        Format:
        Saran: [saran]
        Alternatif:
        - [alternatif 1]
        - [alternatif 2]
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
    
    // MARK: - Generate Smart Meal Recommendation
    /// Generate personalized meal recommendation for specific meal time
    func generateMealRecommendation(
        mealType: MealRecommendation.MealType,
        userProfile: UserProfile
    ) async -> MealRecommendation? {
        guard !APIConfig.allAPIKeys.isEmpty else {
            errorMessage = "Tidak ada API key yang tersedia. Silakan set API key di APIConfig.swift"
            return nil
        }
        
        isLoading = true
        errorMessage = nil
        
        let prompt = buildMealPrompt(for: mealType, userProfile: userProfile)
        
        do {
            let recommendation = try await callGeminiMealAPI(
                with: prompt,
                mealType: mealType,
                userProfile: userProfile
            )
            isLoading = false
            return recommendation
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return nil
        }
    }
    
    // MARK: - Call Gemini API for Meal Recommendation with Retry & Fallback
    private func callGeminiMealAPI(
        with prompt: String,
        mealType: MealRecommendation.MealType,
        userProfile: UserProfile
    ) async throws -> MealRecommendation {
        var lastError: Error?
        let maxRetries = APIConfig.availableKeysCount
        
        for attempt in 0..<maxRetries {
            do {
                guard let apiKey = activeAPIKey else {
                    throw NSError(domain: "GeminiAPI", code: -3, userInfo: [NSLocalizedDescriptionKey: "No API key available"])
                }
                
                let part = GeminiPart(text: prompt)
                let content = GeminiContent(parts: [part])
                let config = GenerationConfig(
                    temperature: 0.8,
                    topP: 0.95,
                    topK: 40,
                    maxOutputTokens: 1024
                )
                
                let request = GeminiRequest(contents: [content], generationConfig: config)
                
                var urlRequest = URLRequest(url: URL(string: "\(baseURL)?key=\(apiKey)")!)
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try JSONEncoder().encode(request)
                urlRequest.timeoutInterval = 30
                
                let (data, response) = try await URLSession.shared.data(for: urlRequest)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "GeminiAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                }
                
                // Handle different HTTP status codes
                switch httpResponse.statusCode {
                case 200:
                    break
                case 400, 401, 403:
                    print("❌ API key invalid (HTTP \(httpResponse.statusCode)). Trying next key...")
                    switchToNextAPIKey()
                    lastError = NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid API key"])
                    if attempt < maxRetries - 1 {
                        continue
                    } else {
                        throw lastError!
                    }
                case 429:
                    print("⚠️ Rate limited (HTTP 429). Trying next key...")
                    switchToNextAPIKey()
                    lastError = NSError(domain: "GeminiAPI", code: 429, userInfo: [NSLocalizedDescriptionKey: "Rate limited"])
                    if attempt < maxRetries - 1 {
                        continue
                    } else {
                        throw lastError!
                    }
                case 500...599:
                    print("⚠️ Server error (HTTP \(httpResponse.statusCode)). Trying next key...")
                    switchToNextAPIKey()
                    lastError = NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                    if attempt < maxRetries - 1 {
                        continue
                    } else {
                        throw lastError!
                    }
                default:
                    throw NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected HTTP response"])
                }
                
                let decodedResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                
                guard let candidate = decodedResponse.candidates?.first,
                      let content = candidate.content,
                      let textPart = content.parts.first else {
                    throw NSError(domain: "GeminiAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                }
                
                let responseText = textPart.text
                
                #if DEBUG
                print("--- Gemini Meal Recommendation Request ---")
                print(prompt)
                print("--- Gemini Meal Recommendation Response ---")
                print(responseText)
                #endif
                
                let (foodName, description, calories, budget) = parseMealRecommendationResponse(responseText)
                
                return MealRecommendation(
                    mealType: mealType,
                    foodName: foodName,
                    description: description,
                    calorieInfo: calories,
                    budgetInfo: budget
                )
                
            } catch {
                lastError = error
                print("❌ Meal API Attempt \(attempt + 1)/\(maxRetries) failed: \(error.localizedDescription)")
                
                if attempt < maxRetries - 1 {
                    switchToNextAPIKey()
                } else {
                    throw error
                }
            }
        }
        
        throw lastError ?? NSError(domain: "GeminiAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "All API keys failed"])
    }
    
    // MARK: - Build Meal Recommendation Prompt
    private func buildMealPrompt(
        for mealType: MealRecommendation.MealType,
        userProfile: UserProfile
    ) -> String {
        let mealName: String
        switch mealType {
        case .breakfast: mealName = "sarapan"
        case .lunch: mealName = "makan siang"
        case .dinner: mealName = "makan malam"
        }
        
        return """
        Rekomendasi \(mealName) untuk pengguna dengan kalori ~\(String(format: "%.0f", userProfile.caloriesPerMealIntake)) kcal dan budget \(userProfile.budgetPerMealFormatted).
        
        OUTPUT HANYA format di bawah tanpa teks tambahan, sapa, atau keterangan lain:
        Makanan: [nama makanan]
        Deskripsi: [alasan singkat 2 kalimat]
        Kalori: [~XXX kcal]
        Budget: Rp [XXX.000]
        """
    }
    
    // MARK: - Parse Meal Recommendation Response
    private func parseMealRecommendationResponse(
        _ response: String
    ) -> (foodName: String, description: String, calories: String, budget: String) {
        var foodName = ""
        var description = ""
        var calories = ""
        var budget = ""
        
        let lines = response.components(separatedBy: .newlines)
        
        // Parse format fields - extract after the colon
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines and non-format lines
            if trimmed.isEmpty || (!trimmed.contains(":")) {
                continue
            }
            
            if trimmed.starts(with: "Makanan:") {
                let value = trimmed.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                if !value.isEmpty && foodName.isEmpty {
                    foodName = value
                }
            } else if trimmed.starts(with: "Deskripsi:") {
                let value = trimmed.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                if !value.isEmpty && description.isEmpty {
                    description = value
                }
            } else if trimmed.starts(with: "Kalori:") {
                let value = trimmed.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                if !value.isEmpty && calories.isEmpty {
                    calories = value
                }
            } else if trimmed.starts(with: "Budget:") {
                let value = trimmed.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                if !value.isEmpty && budget.isEmpty {
                    budget = value
                }
            }
        }
        
        // Provide sensible defaults if parsing incomplete
        if foodName.isEmpty {
            foodName = "Rekomendasi Makanan"
        }
        if description.isEmpty {
            description = "Pilihan yang sehat dan terjangkau"
        }
        if calories.isEmpty {
            calories = "~400-500 kcal"
        }
        if budget.isEmpty {
            budget = "Rp 15.000 - 25.000"
        }
        
        return (foodName, description, calories, budget)
    }
}
