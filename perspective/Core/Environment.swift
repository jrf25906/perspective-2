import Foundation

enum AppConfig {
    static let apiBaseURL = "http://localhost:5000/api/v1"
    
    // Add more environment variables as needed
    static let isDebug = true
    static let apiTimeout: TimeInterval = 30
} 