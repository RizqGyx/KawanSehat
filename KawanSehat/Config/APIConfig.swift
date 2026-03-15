//
//  APIConfig.swift
//  KawanSehat
//
//  Created by Muhammad Rizki on 11/03/26.
//

import Foundation

// MARK: - API Configuration
/// Centralized API key management with fallback mechanism
/// API Keys are loaded from APISecrets.swift (which should be gitignored)
struct APIConfig {
    
    // MARK: - API Key Management
    static var allAPIKeys: [String] {
        // Load from APISecrets file (gitignored in production)
        let keys = APISecrets.GEMINI_API_KEYS
        return keys.filter { !$0.isEmpty && !$0.contains("YOUR_") }
    }
    
    // Get primary API key (first available key)
    static var primaryAPIKey: String? {
        return allAPIKeys.first
    }
    
    // Get API key from index
    static func apiKey(at index: Int) -> String? {
        guard index >= 0 && index < allAPIKeys.count else { return nil }
        return allAPIKeys[index]
    }
    
    // Get total available keys
    static var availableKeysCount: Int {
        return allAPIKeys.count
    }
}
