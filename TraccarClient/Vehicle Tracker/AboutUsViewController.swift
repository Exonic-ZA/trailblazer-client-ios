//  AboutUsViewController.swift
//  TraccarClient
//
//  Created by Idol MacBook Pro on 2025/05/12.
//  Updated for improved copy and link handling

import UIKit

class AboutUsViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
            contentTextView.delegate = self
            super.viewDidLoad()
            setupView()
        }

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
      Monitor the locations of delivery vehicles and sales personnel to optimise logistics and enhance responsiveness.\n
    """

    let boldBullet2String = """
      - SOS Emergency Response: 
    """
    let bulletDetail2String = """
      Provide rapid assistance by utilising accurate location data during critical situations.\n
    """

    let boldBullet3String = """
      - Route Optimisation and Performance Analysis: 
    """
    let bulletDetail3String = """
      Analyse location data to improve routes, reduce operational costs, and boost workforce efficiency.\n
    """

    let boldBullet4String = """
      - Parcel Delivery Management: 
    """
    let bulletDetail4String = """
    Enable users to take and upload pictures of parcels to our secure servers, ensuring accurate tracking, proof of delivery, and streamlined package management.
    \n
    """

    let bodyText3String = """
     At Trailblazer, your trust is paramount. We collect precise location data and device IDs, even when the app is closed or not in use, to support the features listed above. Location tracking is only active when manually enabled, and the tracking status is always clearly visible within the app. Additionally, any pictures you take and upload for parcel delivery management are securely stored and used solely for operational purposes, such as verifying deliveries.

     Your data—whether location, device IDs, or images—is never sold to third parties for marketing or any unauthorised use. You retain full control and can disable tracking or manage your data preferences at any time through the app.\n
     """
    let privacyLink = "Privacy Policy: https://sbmserv.co.za/privacy-policy/\n\n"

    let bodyText4String = """
     Trailblazer combines cutting-edge technology with a commitment to transparency and user control. Whether you're managing a fleet, coordinating field teams, ensuring safety through emergency response, or tracking parcel deliveries with visual proof, our app is designed to meet your needs. We prioritise security, privacy, and ease of use to help your business operate with confidence and efficiency.

     Thank you for choosing Trailblazer. Let us help you blaze new trails in logistics and delivery management.
     """

    let headerAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "trailblazer-light-green") ?? UIColor.systemGreen,
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

    let linkTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.link,
        .font: UIFont.systemFont(ofSize: 20.0),
    ]

    func setupView() {
            let formattedAboutUsString = NSMutableAttributedString()

            formattedAboutUsString.append(NSAttributedString(string: header1String, attributes: headerAttributes))
            formattedAboutUsString.append(NSAttributedString(string: bodyText1String, attributes: normalTextAttributes))

            formattedAboutUsString.append(NSAttributedString(string: header2String, attributes: headerAttributes))
            formattedAboutUsString.append(NSAttributedString(string: bodyText2String, attributes: normalTextAttributes))

            formattedAboutUsString.append(NSAttributedString(string: boldBullet1String, attributes: boldTextAttributes))
            formattedAboutUsString.append(NSAttributedString(string: bulletDetail1String, attributes: normalTextAttributes))

            formattedAboutUsString.append(NSAttributedString(string: boldBullet2String, attributes: boldTextAttributes))
            formattedAboutUsString.append(NSAttributedString(string: bulletDetail2String, attributes: normalTextAttributes))

            formattedAboutUsString.append(NSAttributedString(string: boldBullet3String, attributes: boldTextAttributes))
            formattedAboutUsString.append(NSAttributedString(string: bulletDetail3String, attributes: normalTextAttributes))

            formattedAboutUsString.append(NSAttributedString(string: boldBullet4String, attributes: boldTextAttributes))
            formattedAboutUsString.append(NSAttributedString(string: bulletDetail4String, attributes: normalTextAttributes))

            formattedAboutUsString.append(NSAttributedString(string: header3String, attributes: headerAttributes))
            formattedAboutUsString.append(NSAttributedString(string: bodyText3String, attributes: normalTextAttributes))

            let privacyPolicyURL = URL(string: "https://sbmserv.co.za/privacy-policy/")!
            let linkText = NSMutableAttributedString(string: "View our ")
            linkText.append(NSAttributedString(string: "Privacy Policy", attributes: [.link: privacyPolicyURL]))
            linkText.append(NSAttributedString(string: "\n\n", attributes: normalTextAttributes))
            formattedAboutUsString.append(linkText)


            formattedAboutUsString.append(NSAttributedString(string: header4String, attributes: headerAttributes))
            formattedAboutUsString.append(NSAttributedString(string: bodyText4String, attributes: normalTextAttributes))

            contentTextView.attributedText = formattedAboutUsString
            contentTextView.linkTextAttributes = linkTextAttributes
            contentTextView.isEditable = false
            contentTextView.isSelectable = true
            contentTextView.dataDetectorTypes = [.link]
        }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
}
