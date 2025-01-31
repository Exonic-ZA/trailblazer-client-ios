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

        print("🔑 Authorization Header: Basic \(base64LoginString)")
        print("🌎 Metadata URL: \(deviceIdURL.absoluteString)")

        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("✅ Response Code: \(response.statusCode)")
            }
            
            if let data = data {
                print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "Invalid Response")")
            }

            let decoder = JSONDecoder()
            do {
                let jsonData = try decoder.decode([TrailblazerDeviceId].self, from: data!)
                completion(DeviceIdResult(deviceId: jsonData[0], error: nil))
            } catch {
                print("❌ JSON Decoding Error: \(error)")
            }
        }
        dataTask.resume()
    }
    
    func createMetadata(_ photo: TrailblazerPhoto, deviceId: Int, completion: @escaping(TrailblazerMetadata) -> Void) {
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

        print("📤 Request Body: \(String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")")
        print("🔑 Authorization Header: Basic \(base64LoginString)")
        print("🌎 Metadata URL: \(metadataURL.absoluteString)")

        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("✅ Response Code: \(response.statusCode)")
            }
            
            if let data = data {
                print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "Invalid Response")")
            }

            let decoder = JSONDecoder()
            do {
                let jsonData = try decoder.decode(TrailblazerMetadata.self, from: data!)
                completion(jsonData)
            } catch {
                print("❌ JSON Decoding Error: \(error)")
            }
        }
        dataTask.resume()
    }
    
    func sendPhoto(_ photo: UIImage, metaResult: TrailblazerMetadata, completion: @escaping (String) -> Void) {
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

        print("🔑 Authorization Header: Basic \(base64LoginString)")
        print("🌎 Upload URL: \(photoURL.absoluteString)")
        print("📤 Uploading raw image data (size: \(imageData.count) bytes)")

        let session = URLSession.shared
        let dataTask = session.uploadTask(with: request, from: imageData) { responseData, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            if let response = response as? HTTPURLResponse {
                print("✅ Response Code: \(response.statusCode)")
            }

            if let data = responseData {
                print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "Invalid Response")")
            }

            completion("Upload Successful")
        }
        dataTask.resume()
    }
    
}

struct DeviceIdResult {
    let deviceId: TrailblazerDeviceId?
    let error: Error?
}
