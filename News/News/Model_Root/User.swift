/**
 * User
 *
 * Created on: June 20, 2018
 * Authors: Ryan Lehman && Nik Murphy
 *
 * Description: A User that consists of an eamil, password, and name.
 * Creates a user in an authentication database then creates a unique
 * of the user in the database. A email is then send of for the user
 * to later verfiy.
 */

import Foundation
import Firebase

class User {
    
    var email: String!
    var password: String!
    var name: String!
    var alerts: [String] = ["Successfully Signed Up", "Please check your email for a verification link"]
    var ref: DatabaseReference! // Reference to database
    
   /**
    * Constructor for a user instance
    *
    * @param (String) The email of the user
    * @param (String) The password for the user login
    * @param (String) The name that the user will go by
    *
    * @return
    */
    init(email: String, password: String, name: String) {
        self.email = email
        self.password = password
        self.name = name
    }
    
    func get_email() -> String {
        return self.email
    }

    func get_pass() -> String {
        return self.password
    }
    
    func get_name() -> String {
        return self.name
    }
    
   /**
    * Sends a request to firebase to see if the user is able to be added
    * to the authentication database. If verfied an email function is called.
    *
    * @param
    *
    * @return
    */
    func add_User()
    {
        Auth.auth().createUser(withEmail: self.email, password: self.password) { (User, Error) in
            if Error != nil {
                
                if let errCode = AuthErrorCode(rawValue: Error!._code) {
                    
                    switch errCode {
                    case .emailAlreadyInUse:
                        self.alerts[0] = "Email Exists"
                        self.alerts[1] = "The email entered is already being used"
                    case .invalidEmail:
                        print("invalid email")
                    default:
                        print("Create User Error: \(Error!)")
                    }
                }
                
            } else {
                // Send a verfication email to the user
                self.send_Verification()
                self.add_to_database()
            }
        }
    }
    
    func getter_alert() -> Array<String>
    {
        return self.alerts
    }
    
   /**
    * Sends the user a verfication email
    *
    * @param
    *
    * @return
    */
    func send_Verification()
    {
        Auth.auth().currentUser?.sendEmailVerification { (Error) in
            if Error != nil {
                print("User Error: \(Error!)")
            } else {
                print("Successfully sent verification email")
            }
        }
    }
    
   /**
    * Adds the user into the scalable database by creating a unique
    * instance of a new user with certain pre-set conditions.
    *
    * @param
    *
    * @return
    */
    func add_to_database()
    {
        ref = Database.database().reference() // Reference to database
        ref.observeSingleEvent(of: .value, with: { snapshot in //Looks at database to see which clubs are active
       
            if !snapshot.exists() { return }
            
            let clubsHolder = snapshot.childSnapshot(forPath: "Active Clubs").value
            let allClubs = clubsHolder as? [String:Any] // Adds all the known clubs a dictionary
            let adminInfo = ["Club": "", "Valid": "false"]
            
            let sendingDict = ["Admin": adminInfo,"Subscribed": allClubs!,"Email": self.email, "Name": self.name, "Denial_Counts": 0, "Last Post": "0"] as [String : Any] // Allocates a bigger dictionary to hold sending data for the user
          
            self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).setValue(sendingDict) // Creates user with email and attaches all the clubs as false values
        })
    }
}
