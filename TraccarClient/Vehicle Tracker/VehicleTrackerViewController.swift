//
//  VehicleTrackerViewController.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2024/11/11.
//  Copyright © 2024 Traccar. All rights reserved.
//

import UIKit
import CoreLocation

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

        // print out the image size as a test
        print(image.size)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        let photoInfo = TrailblazerPhoto(imageData,
                                         fileName: viewModel?.deviceIdentifier ?? "",
                                         fileExtension: "jpg",
                                         deviceId: viewModel?.deviceIdentifier ?? "",
                                         longitude: photoLocation.location?.coordinate.longitude ?? 0.0,
                                         latitude: photoLocation.location?.coordinate.latitude ?? 0.0)
        
        sendPhoto(photoInfo, image: image)
    }
    
    func sendPhoto(_ photoInfo: TrailblazerPhoto, image: UIImage) {

        trailblazerNetworkManager.retrieveDeviceId((viewModel?.deviceIdentifier?.filter {$0 != " "}.uppercased())!) { [weak self] deviceId in
            self?.trailblazerNetworkManager.createMetadata(photoInfo, deviceId: deviceId.id) { metaResult in
                let result = TrailblazerMetadata(id: metaResult.id,
                                                 fileName: metaResult.fileName,
                                                 fileExtension: metaResult.fileExtension,
                                                 uploadedAt: metaResult.uploadedAt,
                                                 deviceId: metaResult.deviceId,
                                                 latitude: metaResult.latitude,
                                                 longitude: metaResult.longitude)
                self?.trailblazerNetworkManager.sendPhoto(image, metaResult: result) { [weak self] photoResult in
                    DispatchQueue.main.async() {
                        self?.uploadLabel.text = "Upload Successful"
                    }
                    print(photoResult)
                }
            }
        }
    }
}
