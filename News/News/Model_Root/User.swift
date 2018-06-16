//
//  Creates an instance of a user that has an email and password field
// 
//  Created by Ryan Lehman on 2/12/18.
//

import Foundation
import Firebase

class User {
    
    var email: String!
    var password: String!
    var name: String!
    var alerts: [String] = ["Successfully Signed Up", "Please check your email for a verification link"]
    var ref: DatabaseReference! // Reference to database
    
    // constructor for each user
    init(email: String, password: String, name: String) {
        self.email = email
        self.password = password
        self.name = name
    }
    
    // getter Method: email of the user instance
    func get_email() -> String {
        return self.email
    }
    
    // getter Method: password of the user instance
    func get_pass() -> String {
        return self.password
    }
    
    func get_name() -> String {
        return self.name
    }
    
    // sends a request to firebase to see if the user is able to be added to the database
    func add_User() {
        
        Auth.auth().createUser(withEmail: self.email, password: self.password) { (User, Error) in
            if Error != nil {
                
                if let errCode = AuthErrorCode(rawValue: Error!._code) {
                    
                    switch errCode {
                    case .emailAlreadyInUse:
                        print("in use")
                        self.alerts[0] = "Email Exists"
                        self.alerts[1] = "The email entered is already being used"
                       
                    case .invalidEmail:
                        print("invalid email")
                    default:
                        print("Create User Error: \(Error!)")
                    }
                }
                
            } else {
                print("all good... continue")
                
                // Send a verfication email to the user
                self.sendVerification()
                self.add_to_database()
                
            }
        }
        
        print("went Through first")
    }
    
    func getter_alert() -> Array<String>{
        
        return self.alerts
        
    }
    
    // Function to send each user a verfication email after signing up
    func sendVerification(){
        Auth.auth().currentUser?.sendEmailVerification { (Error) in
            if Error != nil {
                print("User Error: \(Error!)")
            } else {
                print("Successfully sent verification email")
            }
        }
    }
    
    // Function to add the user into scalable database
    func add_to_database(){
        ref = Database.database().reference() // Reference to database
        ref.observeSingleEvent(of: .value, with: { snapshot in //Looks at database to see which clubs are active
       
            if !snapshot.exists() { return }
            
            let clubsHolder = snapshot.childSnapshot(forPath: "Active Clubs").value
            print(clubsHolder!)
            let allClubs = clubsHolder as? [String:Any] // Adds all the known clubs a dictionary
        
            let adminInfo = ["Club": "", "Valid": "false"]
            
            
            let sendingDict = ["Admin": adminInfo,"Subscribed": allClubs!,"Email": self.email, "Name": self.name, "Denial_Counts": 0, "Last Post": "0"] as [String : Any] // Allocates a bigger dictionary to hold sending data for the user
          
            self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).setValue(sendingDict) // Creates user with email and attaches all the clubs as false values
        })
        
    }
    
}
