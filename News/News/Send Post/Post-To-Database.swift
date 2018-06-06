//
//  Post-To-Database.swift
//  News
//
//  Created by Ryan Lehman on 6/5/18.
//

import Foundation
import Firebase
import UIKit

class Database_Request {
    var subject: String
    var message: String
    var clubName: String
    var PostType: String
    var timeStamp: String
    
    init(subject: String, message: String, clubName: String, PostType: String) {
        self.subject = subject
        self.message = message
        self.clubName = clubName
        self.PostType = PostType
        self.timeStamp = ""
    }
    
    func send_request() {
        // Get the current Date and Time
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let finalDate = dateFormatter.string(from: currentDate)
        
        var ref: DatabaseReference! // Reference to database
        ref = Database.database().reference() // Reference to database
        let uuid = UUID().uuidString // Creates random hash value unique to each post
        let otherData = ["Type": self.PostType, "Name": self.clubName, "Subject": self.subject, "Body": self.message, "Date": finalDate]
        let sendingDict = [uuid: otherData] as [String : Any] // Allocates a bigger dictionary to hold sending data for the user
        
        ref.child("Feed").updateChildValues(sendingDict)// Creates user with email and attaches all the clubs as false values
        ref.child("Clubs").child(self.clubName).child("Posts").updateChildValues(sendingDict)
    }
    
}
