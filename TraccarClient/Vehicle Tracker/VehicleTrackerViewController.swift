//
//  VehicleTrackerViewController.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2024/11/11.
//  Copyright © 2024 Traccar. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class VehicleTrackerViewController: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var sosButton: UIButton!
    @IBOutlet weak var sosMessage: UILabel!
    @IBOutlet weak var vehicleView: UIView!
    @IBOutlet weak var vehicleReg: UILabel!
    @IBOutlet weak var clockInAndOut: UIButton!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settings: UIButton!
    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var viewModel: VehicleTrackerViewModel?
    var settingsViewController = SettingsViewController()
    var imagePicker: UIImagePickerController!
    var photoLocation = CLLocationManager()
    
    var online = false
    var waiting = false
    var stopped = false
    var sendingSOS = false

    let positionProvider = PositionProvider()
    var locationManager = CLLocationManager()
    var databaseHelper: DatabaseHelper?
    let networkManager = NetworkManager()
    let userDefaults = UserDefaults.standard
    let trailblazerNetworkManager = TrailblazerNetworkManager()
    
    var buffer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseHelper = DatabaseHelper()
        
        buffer = userDefaults.bool(forKey: "buffer_preference")
        self.viewModel = VehicleTrackerViewModel()
        
        positionProvider.delegate = self
        locationManager.delegate = self
        networkManager.delegate = self
        trailblazerNetworkManager.delegate = self
        photoLocation.delegate = self
        
        setupView()
    }
    
    func setupView() {
        sosMessage.text = ""
        uploadLabel.text = ""
        
        connectedLabel.layer.borderWidth = 1.5
        connectedLabel.layer.borderColor = UIColor.darkGray.cgColor
        connectedLabel.backgroundColor = UIColor.lightGray
        connectedLabel.textColor = UIColor.black
        connectedLabel.layer.cornerRadius = 16
        connectedLabel.clipsToBounds = true
        
        vehicleView.layer.cornerRadius = 16
        vehicleReg.text = viewModel?.deviceIdentifier
        
        connectedLabel.text = viewModel?.connectionText
        
        clockInAndOut.layer.cornerRadius = 16
        clockInAndOut.setTitle(self.viewModel?.clockInOrOut, for: .normal)
        clockInAndOut.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        settingsView.layer.cornerRadius = settingsView.frame.height / 2
        takePhoto.layer.cornerRadius = takePhoto.frame.height / 2
        
        let sosGesture = UILongPressGestureRecognizer(target: self, action: #selector(sosPressed))
        sosGesture.minimumPressDuration = 2.0
        sosGesture.delegate = self
        self.sosButton.addGestureRecognizer(sosGesture)

        photoLocation.desiredAccuracy = kCLLocationAccuracyBest
        photoLocation.requestAlwaysAuthorization()
        photoLocation.startUpdatingLocation()
    }

    @IBAction func clockInOrOut(_ sender: UIButton) {
        if viewModel?.deviceIdentifier != "" {
            if viewModel?.clockIn == true {
                clockOut()
            } else {
                clockin()
            }
        } else {
            performSegue(withIdentifier: "Settings", sender: self)
        }
    }
    
    @IBAction func settingsPressed(_ sender: UIButton) {
        sosMessage.text = ""
        performSegue(withIdentifier: "Settings", sender: self)
    }
    
    @IBAction func sosPressed(_ sender: UILongPressGestureRecognizer) {
        if viewModel?.deviceIdentifier != "" {
            if sender.state == .began {
                sendingSOS = true
                let pulse = PulseAnimation(numberOfPulses: 8, radius: 50, position: sosButton.center)
                pulse.animationDuration = 1.0
                pulse.backgroundColor = UIColor.red.cgColor
                self.view.layer.insertSublayer(pulse, below: self.view.layer)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                
                clockin()
                connectedLabel.text = viewModel?.sosStatus
            } else if sender.state == .ended {
                connectedLabel.text = viewModel?.connectionText
                sosMessage.text = viewModel?.sosSent
            }
        } else {
            performSegue(withIdentifier: "Settings", sender: self)
        }
    }
    
    @IBAction func takePhotoPressed(_ sender: UIButton) {
        if viewModel?.deviceIdentifier != "" {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                selectImageFrom(.photoLibrary)
                return
            }
            selectImageFrom(.camera)
        } else {
            performSegue(withIdentifier: "Settings", sender: self)
        }
    }
    
    private func clockin() {
        viewModel?.clockIn = true
        online = true
        start()
        sosMessage.text = ""
        uploadLabel.text = ""
        connectedLabel.backgroundColor = UIColor(named: "trailblazer-light-background")
        connectedLabel.layer.borderColor = UIColor(named: "trailblazer-light-green")?.cgColor
        connectedLabel.textColor = UIColor(named: "trailblazer-light-green")
        clockInAndOut.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        connectedLabel.text = viewModel?.connectionText
        clockInAndOut.setTitle(self.viewModel?.clockInOrOut, for: .normal)
    }
    
    private func clockOut() {
        viewModel?.clockIn = false
        online = false
        sendingSOS = false
        uploadLabel.text = ""
        stop()
        connectedLabel.layer.borderColor = UIColor.darkGray.cgColor
        connectedLabel.backgroundColor = UIColor.lightGray
        connectedLabel.textColor = UIColor.black
        clockInAndOut.setImage(UIImage(systemName: "play.fill"), for: .normal)
        connectedLabel.text = viewModel?.connectionText
        clockInAndOut.setTitle(self.viewModel?.clockInOrOut, for: .normal)
    }
    
    func start() {
        self.stopped = false
        if self.online {
            read()
        }
        positionProvider.startUpdates()
        locationManager.startMonitoringSignificantLocationChanges()
        networkManager.start()
    }
    
    func stop() {
        networkManager.stop()
        locationManager.stopMonitoringSignificantLocationChanges()
        positionProvider.stopUpdates()
        self.stopped = true
    }
    
    func selectImageFrom(_ source: Enums.ImageSource){
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SettingsViewController {
            settingsViewController = (segue.destination as? SettingsViewController)!
            settingsViewController.settingsDelegate = self
            settingsViewController.vehicleIdentifier = viewModel?.deviceIdentifier
            settingsViewController.serverURL = viewModel?.serverURL
            settingsViewController.locationAccuracy = viewModel?.locationAccuracy
        }
    }
    
    func write(_ position: Position) {
        let context = DatabaseHelper().managedObjectContext
        if context.hasChanges {
            try? context.save()
        }
        if self.online && self.waiting {
            read()
            self.waiting = false
        }
    }
    
    func read() {
        if let position = databaseHelper?.selectPosition() {
            send(position)
        } else {
            self.waiting = true
        }
    }
    
    func delete(_ position: Position) {
        databaseHelper?.delete(position: position)
        read()
    }
    
    func send(_ position: Position) {
        let deviceID = viewModel?.deviceIdentifier?.filter {$0 != " "}.uppercased()
        var url: URL?
        if sendingSOS {
            url = ProtocolFormatter.formatPostion(position, url: (viewModel?.serverURL)!, alarm: "sos", deviceId: deviceID)
        } else {
            url = ProtocolFormatter.formatPostion(position, url: (viewModel?.serverURL)!, deviceId: deviceID)
        }
        print("INFO SENT: \(String(describing: url))")
        if let request = url {
            RequestManager.sendRequest(request, completionHandler: {(_ success: Bool) -> Void in
                if success {
                    if self.buffer {
                        self.delete(position)
                    }
                } else {
                    StatusViewController.addMessage(NSLocalizedString("Send failed", comment: ""))
                    if self.buffer {
                        self.retry()
                    }
                }
            })
        } else {
            StatusViewController.addMessage(NSLocalizedString("Send failed", comment: ""))
            if buffer {
                self.retry()
            }
        }
    }
    
    func retry() {
        let deadline = DispatchTime.now() + Double(TrackingController.RETRY_DELAY * NSEC_PER_MSEC) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: {() -> Void in
            if !self.stopped && self.online {
                self.read()
            }
        })
    }
}

extension VehicleTrackerViewController: settingsDelegate, PositionProviderDelegate, NetworkManagerDelegate, TrailblazerNetworkManagerDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate {
    
    func updateIdentifier() {
        vehicleReg.text = viewModel?.deviceIdentifier
    }
    
    func didUpdate(position: Position) {
        StatusViewController.addMessage(NSLocalizedString("Location update", comment: ""))
        if buffer {
            write(position)
        } else {
            send(position)
        }
    }
    
    func didUpdateNetwork(online: Bool) {
        StatusViewController.addMessage(NSLocalizedString("Connectivity change", comment: ""))
        if !self.online && online {
            read()
        }
        self.online = online
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        self.activityLoader.startAnimating()
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("❌ Failed to convert image to Data")
            return
        }
        
        let photoInfo = TrailblazerPhoto(
            imageData,
            fileName: viewModel?.deviceIdentifier ?? "",
            fileExtension: "jpg",
            deviceId: viewModel?.deviceIdentifier ?? "",
            longitude: photoLocation.location?.coordinate.longitude ?? 0.0,
            latitude: photoLocation.location?.coordinate.latitude ?? 0.0
        )
        
        sendPhoto(photoInfo, image: image)
    }
    
    
    
    func sendPhoto(_ photoInfo: TrailblazerPhoto, image: UIImage) {
        self.uploadLabel.text = "Uploading image"
        
        let identifier = viewModel?.deviceIdentifier?.filter { $0 != " " }.uppercased() ?? ""
        trailblazerNetworkManager.retrieveDeviceId(identifier) { [weak self] result in
            if let error = result.error {
                DispatchQueue.main.async {
                    self?.uploadLabel.text = error.localizedDescription
                    self?.activityLoader.stopAnimating()
                }
                return
            }
            
            guard let deviceId = result.deviceId?.id else {
                DispatchQueue.main.async {
                    self?.uploadLabel.text = "Invalid device ID"
                    self?.activityLoader.stopAnimating()
                }
                return
            }
            
            self?.trailblazerNetworkManager.createMetadata(photoInfo, deviceId: deviceId) { metaResult in
                if let compressedData = self?.ensureImageSize(image) {
                    let compressedImage = UIImage(data: compressedData)
                    let newPhotoInfo = TrailblazerPhoto(
                        compressedData,
                        fileName: photoInfo.fileName,
                        fileExtension: photoInfo.fileExtension,
                        deviceId: photoInfo.deviceId,
                        longitude: photoInfo.longitude,
                        latitude: photoInfo.latitude
                    )
                    
                    self?.trailblazerNetworkManager.sendPhoto(compressedImage!, metaResult: metaResult) { [weak self] photoResult in
                        DispatchQueue.main.async {
                            self?.uploadLabel.text = "Upload Successful"
                            self?.activityLoader.stopAnimating()
                        }
                        print(photoResult)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.uploadLabel.text = "Image processing failed"
                        self?.activityLoader.stopAnimating()
                    }
                }
            }
        }
    }
    
    
    
    func ensureImageSize(_ image: UIImage) -> Data? {
        if let compressedData = image.optimizedJPEGData() {
            return compressedData
        }
        return nil
    }
}
    
    extension UIImage {
        /// Optimized JPEG compression with binary search
        func optimizedJPEGData(maxFileSize: Int = 10_000_000) -> Data? {
            var minQuality: CGFloat = 0.1
            var maxQuality: CGFloat = 1.0
            var bestData: Data?
            
            while minQuality <= maxQuality {
                let midQuality = (minQuality + maxQuality) / 2
                if let data = self.jpegData(compressionQuality: midQuality) {
                    if data.count < maxFileSize {
                        bestData = data
                        minQuality = midQuality + 0.01 // Increase quality
                    } else {
                        maxQuality = midQuality - 0.01 // Decrease quality
                    }
                } else {
                    break
                }
            }
            
            // If compression failed, try resizing
            if let bestData = bestData, bestData.count > maxFileSize {
                if let resized = self.resized(to: 800) {
                    return resized.optimizedJPEGData() // Reattempt compression
                }
            }
            return bestData
        }
        
        /// Resizes image to fit within `maxSize` while maintaining aspect ratio
        func resized(to maxSize: CGFloat = 1000) -> UIImage? {
            let aspectRatio = size.width / size.height
            let newWidth = aspectRatio > 1 ? maxSize : maxSize * aspectRatio
            let newHeight = aspectRatio > 1 ? maxSize / aspectRatio : maxSize
            
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: newWidth, height: newHeight))
            return renderer.image { _ in
                self.draw(in: CGRect(origin: .zero, size: CGSize(width: newWidth, height: newHeight)))
            }
        }
    }
