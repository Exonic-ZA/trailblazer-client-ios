//
//  TrailblazerPhoto.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2025/01/24.
//  Copyright © 2025 Traccar. All rights reserved.
//

import Foundation

struct TrailblazerPhoto: Codable {
    var imageId = UUID()
    let image: Data
    
    init(image: Data) {
        self.image = image
    }
}
