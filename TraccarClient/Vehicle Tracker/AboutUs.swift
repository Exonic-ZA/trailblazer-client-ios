//
//  AboutUs.swift
//  TraccarClient
//
//  Created by Idol MacBook Pro on 2025/05/12.
//  Copyright © 2025 Traccar. All rights reserved.
//

import UIKit

class AboutUs: UIViewController {
    
    @IBOutlet weak var contentLabel: UILabel!
    
    let header1String = "About Us\n"
    let header2String = "What We Do\n"
    let header3String = "Our Commitment to Your Privacy\n"
    let header4String = "Why Choose Trailblazer?\n"
    
    
    let bodyText1String = """
     Welcome to Trailblazer, a mobile tracking app designed to streamline business operations through secure, location-based solutions and advanced delivery management tools. Our mission is to empower businesses with real-time insights, efficient logistics, and robust privacy controls to drive success.
     \n
     """
    
    let bodyText2String = """
    Trailblazer leverages precise location data, device IDs, and user-uploaded images to deliver powerful features tailored for business needs, including:
    
    """
    let boldBullet1String = """
      - Real-Time Tracking: 
    """
    let bulletDetail1String = """
      Monitor t he locations of delivery vehicles and sales personnel to optimize logistics and enhance responsiveness.\n
    """
    
    let boldBullet2String = """
      - SOS Emergency Response: 
    """
    let bulletDetail2String = """
      Provide rapid assistance by utilizing accurate location data during critical situations.\n
    """
    
    let boldBullet3String = """
      - Route Optimization and Performance Analysis: 
    """
    let bulletDetail3String = """
      Analyze location data to improve routes, reduce operational costs, and boost workforce efficiency.\n
    """
    
    let boldBullet4String = """
      - Parcel Delivery Management: 
    """
    let bulletDetail4String = """
    Enable users to take and upload pictures of parcels to our secure servers, ensuring accurate tracking, proof of delivery, and streamlined package management.
    \n
    """
         
    let bodyText3String = """
     At Trailblazer, your trust is paramount. We collect precise location data and device IDs, even when t he app is closed or not in use, to support the features listed above. Location tracking is only active when manually enabled, and the tracking status is always clearly visible within the app. Additionally, any pictures you take and upload for parcel delivery management are securely stored and used solely for operational purposes, such as verifying deliveries. 

     Your data—whether location, device IDs, or images—is never sold to third parties for marketing or any unauthorized use. You retain full control and can disable tracking or manage your data preferences at any time through the app. For a detailed explanation of how we protect your information, please visit our Privacy Policy. 
     \n
     """
    let bodyText4String = """
     Trailblazer combines cutting-edge technology with a commitment to transparency and user control. Whether you're managing a fleet, coordinating field teams, ensuring safety through emergency response, or tracking parcel deliveries wit h visual proof, our app is designed to meet your needs. We prioritize security, privacy, and ease of use to help your business operate wit h confidence and efficiency.

     Thank you for choosing Trailblazer. Let us help you blaze new trails in logistics and delivery management.
     """
    
    let headerAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "trailblazer-light-green"),
        .font: UIFont.systemFont(ofSize: 30.0, weight: .bold),
    ]
    let boldTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.black,
        .font: UIFont.systemFont(ofSize: 20.0, weight: .bold),
    ]
    let normalTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.black,
        .font: UIFont.systemFont(ofSize: 20.0),
    ]
    
    var showDiscalimer: Bool = true
     let bodyString = """
    This app collects and stores your precise location data even when t he app is closed or not in use to enable:
    - **Real-time tracking** of delivery vehicles and sales personnel
    - SOS emergency response functionality?
    - Route optimization and performance analysis \n
    Your location is only tracked when tracking is manually enabled. The tracking status is always clearly visible in the app.\n
    Location data is securely stored and used solely for business operations purposes. It is never sold to third parties for marketing.
    You can disable tracking at any time through the app.
    """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        let formattedAboutUsString = NSMutableAttributedString()
        
        let header1 = NSMutableAttributedString(string: header1String, attributes: headerAttributes)
        formattedAboutUsString.append(header1)
        let bodyText1 = NSMutableAttributedString(string: bodyText1String, attributes: normalTextAttributes)
        formattedAboutUsString.append(bodyText1)
        
        let header2 = NSMutableAttributedString(string: header2String, attributes: headerAttributes)
        formattedAboutUsString.append(header2)
        let bodyText2 = NSMutableAttributedString(string: bodyText2String, attributes: normalTextAttributes)
        formattedAboutUsString.append(bodyText2)
        
        let bulletH1 = NSMutableAttributedString(string: boldBullet1String, attributes: boldTextAttributes)
        formattedAboutUsString.append(bulletH1)
        let bulletD1 = NSMutableAttributedString(string: bulletDetail1String, attributes: normalTextAttributes)
        formattedAboutUsString.append(bulletD1)
        
        let bulletH2 = NSMutableAttributedString(string: boldBullet2String, attributes: boldTextAttributes)
        formattedAboutUsString.append(bulletH2)
        let bulletD2 = NSMutableAttributedString(string: bulletDetail2String, attributes: normalTextAttributes)
        formattedAboutUsString.append(bulletD2)
        
        let bulletH3 = NSMutableAttributedString(string: boldBullet3String, attributes: boldTextAttributes)
        formattedAboutUsString.append(bulletH3)
        let bulletD3 = NSMutableAttributedString(string: bulletDetail3String, attributes: normalTextAttributes)
        formattedAboutUsString.append(bulletD3)
        
        let bulletH4 = NSMutableAttributedString(string: boldBullet4String, attributes: boldTextAttributes)
        formattedAboutUsString.append(bulletH4)
        let bulletD4 = NSMutableAttributedString(string: bulletDetail4String, attributes: normalTextAttributes)
        formattedAboutUsString.append(bulletD4)
        
        let header3 = NSMutableAttributedString(string: header3String, attributes: headerAttributes)
        formattedAboutUsString.append(header3)
        let bodyText3 = NSMutableAttributedString(string: bodyText3String, attributes: normalTextAttributes)
        formattedAboutUsString.append(bodyText3)
        
        let header4 = NSMutableAttributedString(string: header4String, attributes: headerAttributes)
        formattedAboutUsString.append(header4)
        let bodyText4 = NSMutableAttributedString(string: bodyText4String, attributes: normalTextAttributes)
        formattedAboutUsString.append(bodyText4)
        
        contentLabel.attributedText = formattedAboutUsString
    }
    
    @IBAction func openPrivacyPage(_ sender: Any) {
        guard let url = URL(string: "https://sbmserv.co.za/privacy-policy/") else { return }
        UIApplication.shared.open(url)
    }
}
