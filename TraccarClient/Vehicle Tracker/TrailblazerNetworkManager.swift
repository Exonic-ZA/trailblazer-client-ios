//
//  TrailblazerNetworkManager.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2025/01/24.
//  Copyright © 2025 Traccar. All rights reserved.
//

import Foundation

protocol TrailblazerNetworkManagerDelegate: AnyObject {
    func sendPhoto(_ trailblazerPhoto: TrailblazerPhoto)
}

class TrailblazerNetworkManager: NSObject {
    
    var photoURL: URL
    weak var delegate: TrailblazerNetworkManagerDelegate?
    
    override init() {
        photoURL = URL(string: "https://pathfinder.sbmkinetics.co.za/")!
    }
    
    func sendPhoto(_ photo: TrailblazerPhoto, completion: @escaping(Result<Int, Error>) -> Void) {
        
        let dataTask = URLSession.shared.dataTask(with: photoURL) { (data, response, error) in
            guard error == nil else {
                print (error!.localizedDescription)
                print ("stuck in data task")
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let jsonData = try decoder.decode(Int.self, from: data!)
                completion(.success(jsonData))
            }
            catch {
                print ("an error in catch")
                print (error)
            }
        }
        dataTask.resume()
    }
    
}
