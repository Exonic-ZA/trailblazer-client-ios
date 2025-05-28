//
//  VehicleTrackerViewModel.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2024/11/11.
//  Copyright © 2024 Traccar. All rights reserved.
//

import Foundation

struct VehicleTrackerViewModel {
    
    var clockIn = false

    var connectionText: String {
        clockIn ? "● Connected" : "Disconnected"
    }

    var clockInOrOut: String {
        clockIn ? " Clock out" : " Clock in"
    }

    var sosStatusText: String {
        "● Sending SOS"
    }

    var sosModeActiveText: String {
        "🚨 SOS mode active"
    }

    var sosModeEndedText: String {
        "🛑 SOS mode ended"
    }

    var deviceIdentifier: String? {
        UserDefaults.standard.string(forKey: "device_id_preference") ?? ""
    }

    var serverURL: String? {
        UserDefaults.standard.string(forKey: "server_url_preference") ?? ""
    }

    var locationAccuracy: String? {
        UserDefaults.standard.string(forKey: "accuracy_preference")
    }
}
