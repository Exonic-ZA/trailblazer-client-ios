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
    @IBOutlet weak var disclaimerbodyText: UILabel!
    @IBOutlet weak var consentButton: UIButton!
    
    var showDiscalimer: Bool = true
     let bodyString = """
    This app collects and stores your precise location data even when t he app is closed or not in use to enable:
    - Real-time tracking of delivery vehicles and sales personnel
    - SOS emergency response functionality
    - Route optimization and performance analysis \n
    Your location is only tracked when tracking is manually enabled. The tracking status is always clearly visible in the app.\n
    Location data is securely stored and used solely for business operations purposes. It is never sold to third parties for marketing.
    You can disable tracking at any time through the app.
    """
    
    override func viewDidLoad() {
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        disclaimerView.layer.cornerRadius = 30
        consentButton.layer.cornerRadius = 30
        
        
        disclaimerbodyText.text = bodyString
    }
    
    @IBAction func consentPressed(_ sender: Any) {
        showDiscalimer = false
        overlayView.isHidden = true
    }
}

