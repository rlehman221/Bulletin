//
//  Send_Post_ViewController.swift
//  News
//
//  Created by Ryan Lehman on 5/9/18.
//

import UIKit
import Firebase
import FirebaseMessaging

class Send_Post_ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var textField: UITextView!
    var pickerData: [String] = [String]()
    var topic = ""
    var ref: DatabaseReference! // Reference to database
    var postType = "Announcement"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
        self.picker.dataSource = self
        pickerData = ["Announcement", "Event"]
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
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        postType = pickerData[row]
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func send_button_clicked(_ sender: Any) {
        Notfication_Request(message: self.subjectField.text!, topic: self.topic, title: self.topic).sendNotfication()
        Database_Request(subject: self.subjectField.text!, message: textField.text!, clubName: self.topic , PostType: self.postType).send_request()
    }
    

}
