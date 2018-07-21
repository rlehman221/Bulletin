//
//  SettingsViewController.swift
//  News
//
//  Created by Ryan Lehman on 7/17/18.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    let user = Auth.auth().currentUser
    var ref: DatabaseReference! // Reference to database
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeUsername(_ sender: Any) {
        ref = Database.database().reference()
        
        let usernameAlert = UIAlertController(title: "Change Username", message: "Enter a new username", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        usernameAlert.addTextField { (textField) in
            textField.placeholder = "Enter username here"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        usernameAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak usernameAlert] (_) in
            let textField = usernameAlert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))")
            self.ref.child("Users").child((self.user?.uid)!).child("Name").setValue(textField?.text)
        }))
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
            UIAlertAction in
        }
        
        usernameAlert.addAction(cancelAction)
        // 4. Present the alert.
        self.present(usernameAlert, animated: true, completion: nil)
    }
    
    @IBAction func changePassword(_ sender: Any) {

        let resetAlert = UIAlertController(title: "Invalid Password", message: "New passwords don't match", preferredStyle: .alert)
        let passwordAlert = UIAlertController(title: "Change Password", message: "", preferredStyle: .alert)
        let confirmAlert = UIAlertController(title: "Password Successfully Changed", message: "", preferredStyle: .alert)
        let backendFailAlert = UIAlertController(title: "Network Error", message: "Please try again", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        passwordAlert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.placeholder = "Type your old password here"
            textField.isSecureTextEntry = true
          
        }
        
        passwordAlert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.placeholder = "Type your new password here"
            textField.isSecureTextEntry = true
         
        }
        
        passwordAlert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.placeholder = "Re-type your new password here"
            textField.isSecureTextEntry = true
           
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        passwordAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak passwordAlert] (_) in
            let oldPasswordTxt = passwordAlert?.textFields![0] // Force unwrapping because we know it exists.
            let newPasswordTxt = passwordAlert?.textFields![1]
            let confirmedNewPasswordTxt = passwordAlert?.textFields![2]
            
            if (newPasswordTxt?.text == confirmedNewPasswordTxt?.text){
                let credential = EmailAuthProvider.credential(withEmail: (self.user?.email)!, password: (oldPasswordTxt?.text)!)
                
                self.user?.reauthenticate(with: credential, completion: { (error) in
                    if error != nil{
                        print("not the right old password")
                    }else{
                        //change to new password
                        self.user?.updatePassword(to: (confirmedNewPasswordTxt?.text)!, completion: { (error) in
                            if (error != nil) {
                                print(error.debugDescription)
                                self.present(backendFailAlert, animated: true, completion: nil)
                            } else {
                                self.present(confirmAlert, animated: true, completion: nil)
                            }
                        })
                    }
                })
                
            } else {
                print("password and confirmed password don't match")
                self.present(resetAlert, animated: true, completion: nil)
            }
        }))
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        
        let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.present(passwordAlert, animated: true, completion: nil)
        }
        
        let passCancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
            UIAlertAction in
        }
        
        passwordAlert.addAction(passCancelAction)
        confirmAlert.addAction(okAction)
        resetAlert.addAction(cancelAction)
        backendFailAlert.addAction(okAction)
        // 4. Present the alert.
        self.present(passwordAlert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
