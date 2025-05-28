//
//  UserDefaults+SOS.swift
//  TraccarClient
//
//  Created by Jordan Levy on 28/05/2025.
//  Copyright © 2025 Traccar. All rights reserved.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let sosActive = "sos_active"
    }

    var isSosActive: Bool {
        get { bool(forKey: Keys.sosActive) }
        set { set(newValue, forKey: Keys.sosActive) }
    }

}
