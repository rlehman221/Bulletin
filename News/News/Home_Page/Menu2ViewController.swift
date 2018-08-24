//
//  MenuViewController.swift
//  News
//
//  Created by Ryan Lehman on 7/16/18.
//

import UIKit
import Firebase

class Menu2ViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var adminClub: UILabel!
    @IBOutlet weak var clubPost: UILabel!
    @IBOutlet weak var newPost: UIView!
    @IBOutlet weak var newPostButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var events_view: UIView!
    @IBOutlet weak var coming_soon: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    var ref: DatabaseReference! // Reference to database
    var club = ""
    var username : String!
    var email : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
        spinner.isHidden = false
        getServerInfo {
            do {
                try self.getUserData()
            } catch {
                print("Menu: Load database error")
            }
            
            self.logoutButton.addTarget(self, action: #selector(Menu2ViewController.signOut(_:)), for: .touchUpInside)
            self.feedbackButton.addTarget(self, action: #selector(Menu2ViewController.requestFeedback(_:)), for: .touchUpInside)
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
        }
    }
    
    @objc func signOut(_ sender: UIButton!) {
        MyVariables.yourVariable = "1"
        try! Auth.auth().signOut()
    }
    
    func getServerInfo (finished: @escaping () -> Void)
    {
        ref = Database.database().reference() // Reference to database
        ref.child("Server Info").child("Events").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as! Float
            if value == 1 {
                self.events_view.alpha = 1
                self.coming_soon.text = ""
            }
            else {
                self.events_view.alpha = 0.5
                self.coming_soon.text = "Coming Soon!"
            }
            finished()
        }
        
    }
    
    func revealPost() {
        if (club == "") {
            newPost.alpha = 0
        }
        else {
            newPost.alpha = 1
        }
    }
    
    @objc func goToCreatePost(_ sender: UIButton!) {
        
    }
    
    @objc func requestFeedback(_ sender: UIButton!){
        let uuid = UUID().uuidString
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Feedback", message: "Please enter your feedback", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))")
            self.ref.child("Feedback").child(uuid).setValue(textField?.text) // Creates user with email and attaches all the clubs as false values
        }))
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        
        alert.addAction(cancelAction)
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func getUserData() throws {
        ref = Database.database().reference()
        ref.child("Users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.exists() { return }
            let data = snapshot.value as? [String:Any]
            self.username = data!["Name"] as! String
            self.email = data!["Email"] as! String
            let admin = data!["Admin"] as! [String:String]
            if (admin["Valid"] == "true") {
                self.club = admin["Club"]!
                self.adminClub.text = self.club + " Admin"
                self.adminClub.alpha = 1
                self.clubPost.text = self.club
            }
            else {
                self.adminClub.text = ""
                self.adminClub.alpha = 0
                self.clubPost.text = ""
            }
            self.nameLabel.text = self.username
            self.emailLabel.text = self.email
            self.clubPost.text = self.club
            self.revealPost()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
