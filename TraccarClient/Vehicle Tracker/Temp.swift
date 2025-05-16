//
//  Temp.swift
//  TraccarClient
//
//  Created by Idol MacBook Pro on 2025/05/12.
//  Copyright © 2025 Traccar. All rights reserved.
//

import UIKit

class Temp: UIViewController {

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var disclaimerView: UIView!
    @IBOutlet weak var disclaimerBodyText: UILabel!
    @IBOutlet weak var consentButton: UIButton!

    var showDisclaimer: Bool = true
    let userDefaults = UserDefaults.standard

    let bodyString = """
    This app collects and stores your precise location data even when the app is closed or not in use in order to:
    • Enable real-time tracking of delivery vehicles and sales personnel
    • Provide SOS emergency response functionality
    • Optimise routes and analyse performance

    Your location is only tracked when manually enabled. The tracking status is always clearly visible within the app.

    Location data is securely stored and used solely for operational purposes. It is never sold to third parties for marketing.

    You may disable tracking at any time through the app's settings.
    """

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if user has already consented
        let hasConsented = userDefaults.bool(forKey: "hasConsentedToDisclaimer")
        overlayView.isHidden = hasConsented

        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.90)
        disclaimerView.layer.cornerRadius = 30
        consentButton.layer.cornerRadius = 25

        disclaimerBodyText.text = bodyString
        disclaimerBodyText.textColor = UIColor.label
        consentButton.setTitleColor(.white, for: .normal)
    }

    @IBAction func consentPressed(_ sender: Any) {
        showDisclaimer = false
        overlayView.isHidden = true
        userDefaults.set(true, forKey: "hasConsentedToDisclaimer")
    }
}
