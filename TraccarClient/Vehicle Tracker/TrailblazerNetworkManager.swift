//
//  TrailblazerNetworkManager.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2025/01/24.
//  Copyright © 2025 Traccar. All rights reserved.
//

import UIKit

protocol TrailblazerNetworkManagerDelegate: AnyObject {}

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
    
    func retrieveDeviceId(_ deviceId: String, completion: @escaping (DeviceIdResult) -> Void) {
        let loginString = "\(self.username):\(self.password)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        let url = "https://pathfinder.sbmkinetics.co.za/api/devices?uniqueId=\(deviceId)"
        deviceIdURL = URL(string: url)!
        var request = URLRequest(url: deviceIdURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            if let dataString = String(data: data, encoding: .utf8) {
                print("📜 Raw Response Data: \(dataString)")
            }
            
            let decoder = JSONDecoder()
            do {
                let jsonData = try decoder.decode([TrailblazerDeviceId].self, from: data)
                if jsonData.isEmpty {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Device not found on system"])
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
    
    func createMetadata(_ photo: TrailblazerPhoto, deviceId: Int, completion: @escaping (MetadataResponse) -> Void) {
        let json: [String: Any] = [
            "fileName": photo.fileName,
            "fileExtension": photo.fileExtension,
            "deviceId": deviceId,
            "latitude": photo.latitude,
            "longitude": photo.longitude
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
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                let metadata = try JSONDecoder().decode(MetadataResponse.self, from: data)
                completion(metadata)
            } catch {
                print("❌ JSON Decoding Error: \(error)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("📜 Raw Response Data: \(dataString)")
                }
            }
        }
        dataTask.resume()
    }
    
    func sendPhoto(_ photo: UIImage, metaResult: MetadataResponse, completion: @escaping (String) -> Void) {
        guard let imageData = photo.optimizedJPEGData() else {
            print("❌ Failed to compress image")
            return
        }
        
        let url = "https://pathfinder.sbmkinetics.co.za/api/images/\(metaResult.id)/upload"
        guard let photoURL = URL(string: url) else { return }
        var request = URLRequest(url: photoURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        
        let loginString = "\(self.username):\(self.password)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let dataTask = session.uploadTask(with: request, from: imageData) { responseData, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            completion("Upload Successful")
        }
        dataTask.resume()
    }
    
    
    struct DeviceIdResult {
        let deviceId: TrailblazerDeviceId?
        let error: Error?
    }
}
