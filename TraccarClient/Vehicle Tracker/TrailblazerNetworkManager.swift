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
    
    var metadataURL: URL
    var photoURL: URL
    var photoId: Int?
    var username: String
    var password: String
    
    weak var delegate: TrailblazerNetworkManagerDelegate?
    
    override init() {
        metadataURL = URL(string: "https://pathfinder.sbmkinetics.co.za/api/images")!
        photoURL = URL(string: "https://pathfinder.sbmkinetics.co.za/api/images/\(photoId)/upload")!
        username = Bundle.main.object(forInfoDictionaryKey: "Username") as? String ?? ""
        password = Bundle.main.object(forInfoDictionaryKey: "Password") as? String ?? ""
    }
    
    func createMetadata(_ photo: TrailblazerPhoto, completion: @escaping(TrailblazerMetadata) -> Void) {
        let deviceId = Int.random(in: 0..<1000000)
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
//    let url = String("https://pathfinder.sbmkinetics.co.za/api/images/\(metaResult.id)/upload")
//    photoURL = URL(string: "https://pathfinder.sbmkinetics.co.za/api/images/\(metaResult.)/upload")!
    
    func sendPhoto(_ photo: UIImage, metaResult: TrailblazerMetadata, completion: @escaping (String) -> Void) {
        guard let imageData = photo.jpegData(compressionQuality: 0.2) else {
            return
        }
//        guard let imageData = photo.pngData() else {
//            print("❌ Failed to convert image to PNG")
//            return
//        }

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
    
    
//    func sendPhoto(_ photo: TrailblazerPhoto, metaResult: TrailblazerMetadata, completion: @escaping(String) -> Void) {
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: photo.image, options: []) else {
//            print("❌ Failed to serialize JSON")
//            return
//        }
//        
////        var data = Data()
////        data.append(photo.image)
//        
//        let loginString = "\(self.username):\(self.password)"
//        let loginData = loginString.data(using: .utf8)!
//        let base64LoginString = loginData.base64EncodedString()
//
//        var request = URLRequest(url: photoURL)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept") // Ensure API expects JSON
//        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
////        request.httpBody = jsonData
//
////        print("📤 Request Body: \(String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")")
//        print("🔑 Authorization Header: Basic \(base64LoginString)")
//        print("🌎 Metadata URL: \(photoURL.absoluteString)")
//
//        let session = URLSession.shared
//        let dataTask = session.uploadTask(with: request, from: jsonData, completionHandler: { responseData, response, error in
//            if let error = error {
//                print("❌ Error: \(error.localizedDescription)")
//                return
//            }
//            
//            if let response = response as? HTTPURLResponse {
//                print("✅ Response Code: \(response.statusCode)")
//            }
//            
//            if let data = responseData {
//                print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "Invalid Response")")
//            }
//
//            let decoder = JSONDecoder()
//            do {
//                let jsonData = try decoder.decode(String.self, from: responseData!)
//                completion(jsonData)
//            } catch {
//                print("❌ JSON Decoding Error: \(error)")
//            }
//        }).resume()
//    }
//    func sendPhoto(_ photo: TrailblazerPhoto, metaResult: TrailblazerMetadata, completion: @escaping(Result<Int, Error>) -> Void) {
//    
//        let param = [
//            "fileName" : photo.fileName,
//            "fileExtension" : "jpg",
//            "deviceId" : photo.deviceId,
//            "latitude" : photo.latitude,
//            "longitude" : photo.longitude
//        ] as [String : Any]
//        
//        guard let mediaImage = Media(withImage: photo.image, forKey: "image") else { return }
//        var request = URLRequest(url: photoURL)
//        request.httpMethod = "POST"
//
//        //create boundary
//        let boundary = generateBoundary()
//        //set content type
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        //call createDataBody method
//        let dataBody = createDataBody(withParameters: param, media: [mediaImage], boundary: boundary)
//        request.httpBody = dataBody
//        print("DATA: \(dataBody)")
//        
//        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            guard error == nil else {
//                print (error!.localizedDescription)
//                print ("stuck in data task")
//                return
//            }
//            
//            let decoder = JSONDecoder()
//            
//            do {
//                let jsonData = try decoder.decode(Int.self, from: data!)
//                completion(.success(jsonData))
//            }
//            catch {
//                print ("an error in catch")
//                print (error)
//            }
//        }
//        dataTask.resume()
//    }
    
    func createDataBody(withParameters params: [String: Any]?, media: [Media]?, boundary: String) -> Data {
       let lineBreak = "\r\n"
       var body = Data()
       if let parameters = params {
          for (key, value) in parameters {
             body.append("--\(boundary + lineBreak)")
             body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
              body.append("\((value as? String ?? "0.0") + lineBreak)")
          }
       }
       if let media = media {
          for photo in media {
             body.append("--\(boundary + lineBreak)")
             body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
             body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
             body.append(photo.data)
             body.append(lineBreak)
          }
       }
       body.append("--\(boundary)--\(lineBreak)")
       return body
    }
    
    func generateBoundary() -> String {
       return "Boundary-\(NSUUID().uuidString)"
    }
    
    struct Media {
        let key: String
        let filename: String
        let data: Data
        let mimeType: String
        init?(withImage image: Data?, forKey key: String) {
            self.key = key
            self.mimeType = "image/jpeg"
            self.filename = "imagefile.jpg"
            guard let data = image else { return nil }
            self.data = data
        }
    }
    
}

extension Data {
   mutating func append(_ string: String) {
      if let data = string.data(using: .utf8) {
         append(data)
         print("data======>>>",data)
      }
   }
}
