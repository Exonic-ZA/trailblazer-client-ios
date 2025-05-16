//
//  KeychainHelper.swift
//  TraccarClient
//
//  Created by Jordan Levy on 16/05/2025.
//  Copyright © 2025 Traccar. All rights reserved.
//

import Foundation
import Security

enum KeychainHelper {

    static func save(service: String, account: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        // Remove existing item if it exists
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        SecItemDelete(query)

        // Add new item
        let attributes = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data
        ] as CFDictionary

        let status = SecItemAdd(attributes, nil)
        if status != errSecSuccess {
            print("🔐 Failed to save to Keychain. Status: \(status)")
        }
    }

    static func read(service: String, account: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }

    static func delete(service: String, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary

        SecItemDelete(query)
    }
}
