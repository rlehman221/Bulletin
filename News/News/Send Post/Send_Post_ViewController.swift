//
//  Send_Post_ViewController.swift
//  News
//
//  Created by Ryan Lehman on 5/9/18.
//

import UIKit
import Firebase
import FirebaseMessaging

class Send_Post_ViewController: UIViewController {

    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var textField: UITextView!
    var topic = ""
    var ref: DatabaseReference! // Reference to database
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        ref.child("Users").child((Auth.auth().currentUser?.uid)!).child("Admin").observe(.value) { (snapshot) in
            
            if !snapshot.exists() { return }
            let data = snapshot.value as? [String:String]
            // This can be used to see if the user is allowed to see the posting screen "Plus" button at top end
            if (data!["Valid"]! == "true"){
                print("worked Today")
                self.topic = data!["Club"]!
                
            } else {
                print("didn't worked")
            }
        }
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func send_button_clicked(_ sender: Any) {
        print(textField.text!)
        Notfication_Request(message: self.subjectField.text!, topic: self.topic, title: self.topic).sendNotfication()
    }
    

}
