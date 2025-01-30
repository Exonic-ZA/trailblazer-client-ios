//
//  TrailblazerPhoto.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2025/01/24.
//  Copyright © 2025 Traccar. All rights reserved.
//

import Foundation

struct TrailblazerPhoto: Codable {
    let image: Data
    let fileName: String
    let fileExtension: String
    let deviceId: String
    var latitude: Double
    var longitude: Double
    
    init(_ image: Data, fileName: String, fileExtension: String, deviceId: String, longitude: Double, latitude: Double) {
        self.image = image
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.deviceId = deviceId
        self.longitude = Double(truncating: longitude as NSNumber)
        self.latitude = Double(truncating: latitude as NSNumber)
    }
}
