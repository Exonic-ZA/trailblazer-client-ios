//
//  TrailblazerNetworkManager.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2025/01/24.
//  Copyright © 2025 Traccar. All rights reserved.
//

import UIKit

protocol TrailblazerNetworkManagerDelegate: AnyObject {
//    func createMetadata(_ photoInfo: TrailblazerPhoto)
//    func sendPhoto(_ photoInfo: TrailblazerPhoto, metadata: TrailblazerMetadata)
}

typealias HTTPHeaders = [String: String]

class TrailblazerNetworkManager: NSObject {
    
    var deviceIdURL: URL
    var metadataURL: URL
    var photoURL: URL
    var photoId: Int?
    var username: String
    var password: String
    
    weak var delegate: TrailblazerNetworkManagerDelegate?
    
    override init() {
        deviceIdURL = URL(string: "https://pathfinder.sbmkinetics.co.za/api/devices")!
        metadataURL = URL(string: "https://pathfinder.sbmkinetics.co.za/api/images")!
        photoURL = URL(string: "https://pathfinder.sbmkinetics.co.za/api/images")!
        username = Bundle.main.object(forInfoDictionaryKey: "Username") as? String ?? ""
        password = Bundle.main.object(forInfoDictionaryKey: "Password") as? String ?? ""
    }
    
    func retrieveDeviceId(_ deviceId: String, completion: @escaping(DeviceIdResult) -> Void) {
        let loginString = "\(self.username):\(self.password)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        let url = String("https://pathfinder.sbmkinetics.co.za/api/devices?uniqueId=\(deviceId)")
        deviceIdURL = URL(string: url)!
        var request = URLRequest(url: deviceIdURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept") // Ensure API expects JSON
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let jsonData = try decoder.decode([TrailblazerDeviceId].self, from: data!)
                if jsonData.isEmpty {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Please check with your operator if your device is correctly set up on the system"])
                    completion(DeviceIdResult(deviceId: nil, error: error))
                } else {
                    completion(DeviceIdResult(deviceId: jsonData[0], error: nil))
                }
            } catch {
                print("❌ JSON Decoding Error: \(error)")
            }
        }
        dataTask.resume()
    }
    
    func createMetadata(_ photo: TrailblazerPhoto, deviceId: Int, completion: @escaping(MetadataResult) -> Void) {
        let json: [String: Any] = [
            "fileName" : photo.fileName,
            "fileExtension" : photo.fileExtension,
            "deviceId" : deviceId,
            "latitude" : photo.latitude,
            "longitude" : photo.longitude
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            print("❌ Failed to serialize JSON")
            return
        }
        
        let loginString = "\(self.username):\(self.password)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()

        var request = URLRequest(url: metadataURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept") // Ensure API expects JSON
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(MetadataResult(metadata: nil, error: error))
                return
            }
            let decoder = JSONDecoder()
            do {
                let jsonData = try decoder.decode(TrailblazerMetadata.self, from: data!)
                completion(MetadataResult(metadata: jsonData, error: nil))
            } catch {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Create Metadata JSON Decoding Error"])
                completion(MetadataResult(metadata: nil, error: error))
            }
        }
        dataTask.resume()
    }
    
    func sendPhoto(_ photo: UIImage, metaResult: TrailblazerMetadata, completion: @escaping (PhotoResult) -> Void) {
        guard let imageData = photo.jpegData(compressionQuality: 0.2) else {
            return
        }
        let url = String("https://pathfinder.sbmkinetics.co.za/api/images/\(metaResult.id)/upload")
        photoURL = URL(string: url)!
        var request = URLRequest(url: photoURL)
        request.httpMethod = "POST"
        request.setValue("image/png", forHTTPHeaderField: "Content-Type") // ✅ Matches cURL
        request.setValue("*/*", forHTTPHeaderField: "Accept") // ✅ Matches cURL

        // Add Authorization header (Basic Auth)
        let loginString = "\(self.username):\(self.password)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        let dataTask = session.uploadTask(with: request, from: imageData) { responseData, response, error in
            if let error = error {
                completion(PhotoResult(uploadInfo: nil, error: error))
                return
            }

            completion(PhotoResult(uploadInfo: "Upload Successful", error: nil))
        }
        dataTask.resume()
    }
    
}

struct DeviceIdResult {
    let deviceId: TrailblazerDeviceId?
    let error: Error?
}

struct MetadataResult {
    let metadata: TrailblazerMetadata?
    let error: Error?
}

struct PhotoResult {
    let uploadInfo: String?
    let error: Error?
}
