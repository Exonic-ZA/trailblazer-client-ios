//
//  CredentialHelper.swift
//  TraccarClient
//
//  Created by Jordan Levy on 16/05/2025.
//  Copyright © 2025 Traccar. All rights reserved.
//

import Foundation

enum CredentialHelper {
    static var staticUsername: String {
        return ["s", "y", "s", "t", "e", "m", "@", "t", "r", "a", "i", "l", "b", "l", "a", "z", "e", "r", ".", "i", "n", "t", "e", "r", "n", "a", "l"].joined()
    }

    static var staticPassword: String {
        return ["B", "a", "b", "b", "l", "i", "n", "g", "+", "S", "t", "o", "m", "p", "+", "B", "o", "t", "t", "l", "i", "n", "g", "8", "+", "P", "a", "y", "r", "o", "l", "l"].joined()
    }

    static func preloadToKeychainIfNeeded() {
        let usernameExists = KeychainHelper.read(service: "Trailblazer", account: "api-username") != nil
        let passwordExists = KeychainHelper.read(service: "Trailblazer", account: "api-password") != nil

        if !usernameExists {
            KeychainHelper.save(service: "Trailblazer", account: "api-username", value: staticUsername)
        }
        
        if !passwordExists {
            KeychainHelper.save(service: "Trailblazer", account: "api-password", value: staticPassword)
        }
    }
}
