//
//  TrailblazerDeviceId.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2025/01/31.
//  Copyright © 2025 Traccar. All rights reserved.
//

import Foundation

struct TrailblazerDeviceId: Codable {
    let id: Int
    var attributes: [String:Int]?
    let groupId: Int
    let calendarId: Int
    let name: String
    let uniqueId: String
    let status: String
    let lastUpdate: String
    let positionId: Int
    let phone: Int?
    let model: String?
    let contact: String?
    let category: String?
    let disabled: Bool
    let expirationTime: String?
}
