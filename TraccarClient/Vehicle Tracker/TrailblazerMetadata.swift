//
//  TrailablazerMetadata.swift
//  TraccarClient
//
//  Created by Balleng on 2025/01/30.
//  Copyright © 2025 Traccar. All rights reserved.
//

struct TrailblazerMetadata: Codable {
    let id: Int
    let fileName: String
    let fileExtension: String
    let uploadedAt: String
    let deviceId: Int
    let latitude: Double
    let longitude: Double
}
