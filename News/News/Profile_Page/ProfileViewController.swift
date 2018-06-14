//
//  Profile_ViewController.swift
//  News
//
//  Created by Nik Murthy on 2/24/18.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    
    //@IBOutlet weak var deleteAccount: UIButton!
    @IBOutlet weak var editPassword: UIButton!
    @IBOutlet weak var editName: UIButton!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Opening Profile...")
        getInfo()
        editName.addTarget(self, action: #selector(ProfileViewController.edit_name(_:)), for: .touchUpInside)
        editPassword.addTarget(self, action: #selector(ProfileViewController.edit_password(_:)), for: .touchUpInside)
        //deleteAccount.addTarget(self, action: #selector(ProfileViewController.delete_account(_:)), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getInfo() {
        let UID = (Auth.auth().currentUser?.uid)
        ref = Database.database().reference()
        ref.child("Users").child(UID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            let userData = snapshot.value as? NSDictionary
            let userEmail = (userData?["Email"] as? String)!
            let userName = (userData?["Name"] as? String)!
            self.name.text = userName
            self.email.text = userEmail
        })
    }
    
    @objc func edit_name(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Edit Name", message: "Enter a new name.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "New Name..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            let UID = (Auth.auth().currentUser?.uid)
            self.ref = Database.database().reference()
            self.ref.child("Users").child(UID!).child("Name").setValue(textField?.text)
            self.viewDidLoad()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func edit_password(_ sender: UIButton!) {
        let fail_alert = UIAlertController(title: "Error", message: "Unable to change password", preferredStyle: .alert)
        fail_alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        let alert = UIAlertController(title: "Edit Password", message: "Enter a new password", preferredStyle: .alert)
        alert.addTextField{ (textField) in
            textField.placeholder = "Current Password"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "New Password"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Confirm New Password"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            let textField0 = alert?.textFields![0]
            let textField1 = alert?.textFields![1]
            let textField2 = alert?.textFields![2]
            if (textField1?.text! != textField2?.text!) {
                self.present(fail_alert, animated: true, completion: nil)
                return
            }
            self.ref = Database.database().reference()
            let user = Auth.auth().currentUser
            let credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: (textField0?.text!)!)
            user?.reauthenticate(with: credential, completion: { (error) in
                if (error == nil) {
                    Auth.auth().currentUser?.updatePassword(to: (textField1?.text)!) { (error) in
                        print("Password changed to " + (textField1?.text!)!)
                    }
                }
                else {
                    self.present(fail_alert, animated: true, completion: nil)
                    print("Error changing password.")
                }
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func delete_account(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to do this?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak alert] (_) in
            let current_user = Auth.auth().currentUser;
            current_user?.delete { error in
                if error != nil {
                    print("An error occurred")
                }
                else {
                    print("User deleted.")
                    self.performSegue(withIdentifier: "backToLogin", sender: self)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

