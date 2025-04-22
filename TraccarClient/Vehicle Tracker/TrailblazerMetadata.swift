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
    let deviceImage: String
    let latitude: Double
    let longitude: Double
    let lastUpdate: String  // 🔹 Change from Double to String

    enum CodingKeys: String, CodingKey {
        case id, fileName, fileExtension, uploadedAt, deviceId, deviceImage, latitude, longitude, lastUpdate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        fileName = try container.decode(String.self, forKey: .fileName)
        fileExtension = try container.decode(String.self, forKey: .fileExtension)
        uploadedAt = try container.decode(String.self, forKey: .uploadedAt)
        deviceId = try container.decode(Int.self, forKey: .deviceId)

        // Handle deviceImage as Int or String
        if let imageInt = try? container.decode(Int.self, forKey: .deviceImage) {
            deviceImage = String(imageInt)
        } else {
            deviceImage = try container.decode(String.self, forKey: .deviceImage)
        }

        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)

        lastUpdate = try container.decode(String.self, forKey: .lastUpdate)
    }
}


struct MetadataWrapper: Codable {
    let attributes: TrailblazerMetadata
}

struct MetadataResponse: Codable {
    let id: Int
    let fileName: String
    let fileExtension: String
    let uploadedAt: String
    let deviceId: Int
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case id, fileName, fileExtension, uploadedAt, deviceId, latitude, longitude
    }
}


