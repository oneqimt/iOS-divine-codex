//
//  TokenManager.swift
//  Divine Codex iOS
//
//  Created by Dennis Miller on 5/28/26.
//

import Foundation

class TokenManager {
    static let shared = TokenManager()
    
    private var token: String?
    
    private init() {
    }
    
    func getToken() -> String {
        return token ?? ""
    }
    
    func setToken(_ token: String) {
        self.token = token
    }
}
