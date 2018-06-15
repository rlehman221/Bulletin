//
//  Send_Post_ViewController.swift
//  News
//
//  Created by Ryan Lehman on 5/9/18.
//

import UIKit
import Firebase
import FirebaseMessaging
import Foundation
import MessageUI

class Send_Post_ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate {
    
    
    var adminClub = ""
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var textField: UITextView!
    var pickerData: [String] = [String]()
    var topic = ""
    var ref: DatabaseReference! // Reference to database
    var postType = "Announcement"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
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
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
        } else {
            sendEmail()
        }
        
    }
    
    func findAdminClub (finished: @escaping () -> Void) {
        let uid = Auth.auth().currentUser?.uid
        
        ref.child("Users").child(uid!).child("Admin").child("Club").observeSingleEvent(of: .value, with: { (snapshot) in
            self.adminClub = (snapshot.value as? String)!
            finished()
        })
    }
    
    func sendEmail() {
        
        findAdminClub {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.setToRecipients(["address@example.com"])
            composeVC.setSubject(self.subjectField.text!)
            composeVC.setMessageBody(self.textField.text, isHTML: false)
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
        }

    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print(result)
        switch (result) {
            case .cancelled:
                self.dismiss(animated: true, completion: nil)
                break;
            case .sent:
                // If email was successful send data to database and a notifcation to users
                self.dismiss(animated: true, completion: nil)
                Notfication_Request(message: self.subjectField.text!, topic: self.topic, title: self.topic).sendNotfication()
                Database_Request(subject: self.subjectField.text!, message: textField.text!, clubName: self.topic , PostType: self.postType).send_request()
                
                let upload_alert = UIAlertController(title: "Post Successful", message: "Your post has been successfully made", preferredStyle: UIAlertControllerStyle.alert)
                
                // Add ok action to alert
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                }
    
                // Link to alert controller
                upload_alert.addAction(okAction)
                self.present(upload_alert, animated: true, completion: nil) // Display alert to the user
                
                break;
            case .failed:
                self.dismiss(animated: true, completion: nil)
                let fail_alert = UIAlertController(title: "Post Failed", message: "Your post failed to be made please try again", preferredStyle: UIAlertControllerStyle.alert)
                
                // Add ok action to alert
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                }
                
                // Link to alert controller
                fail_alert.addAction(okAction)
                self.present(fail_alert, animated: true, completion: nil) // Display alert to the user
                
                break;
            
            default:
                controller.dismiss(animated: true, completion: nil)
                break;
        }
    }
}
