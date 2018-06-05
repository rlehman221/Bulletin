//
//  File.swift
//  News
//
//  Created by Ryan Lehman on 5/26/18.
//

import Foundation
import Firebase


class Notfication_Request {
    var main_url: String
    var message: String
    var topic: String
    var title: String
    init(message: String, topic: String, title: String) {
        self.main_url = "https://fcm.googleapis.com/fcm/send"
        self.message = message
        self.topic = topic
        self.title = title
    }
    
    func sendNotfication() {
        let url = URL(string: self.main_url)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA-knzFxI:APA91bH-u1gLVfKfVuAfGihHziU7XhG7Bs1RhlHxDGWm3o-8bjmrdNKgydGYPrx909XnSivAeemG1ekvts3fQqW-sbqxivcCACnhiH9griAr-cZTRuLxvJuvZDLAqTSrmWjAUFOZzLuj", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        let postString: [String: Any] = [
            "condition": "'\(self.topic)' in topics",
            "priority" : "high",
            "notification" : [
                "body" : "\(self.message)",
                "title" : "\(self.title)",
            ]
        ]
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: postString)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }
}
