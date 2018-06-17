//
//  View that displays to the user a sign in menu, allowing users to enter
//  an email and password to be signed in or transferred to sign up view
//  Created by Ryan Lehman on 2/11/18.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.text = "rlehman221@gmail.com"
        passwordField.text = "password"
        signInButton.addTarget(self, action: #selector(self.signIn(_:)), for: .touchUpInside)
    }
    
    // checks if the email and password entered in the
    // text field have been verfied upon button pressing
    @objc func signIn(_ sender:UIButton!)
    {
        print(passwordField.text!)
        try! Auth.auth().signOut()
        Auth.auth().fetchProviders(forEmail: emailField.text!, completion: ({ (Data, Error) in
            if ((Error == nil) && (Data != nil)){
                Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                    if let user = Auth.auth().currentUser {
                        if !user.isEmailVerified {
                            print("email not verfied")
                            let verifAlert = UIAlertController(title: "Not Verified", message: "Please verify your account", preferredStyle: UIAlertControllerStyle.alert)
                            let re_verfiyAction = UIAlertAction(title: "Resend Verfication Email", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                                User(email: self.emailField.text!, password: self.passwordField.text!, name: "").sendVerification()
                            }
                            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel) {
                                UIAlertAction in
                                NSLog("Ok Pressed")
                            }
                            verifAlert.addAction(re_verfiyAction)
                            verifAlert.addAction(okAction)
                            self.present(verifAlert, animated: true, completion: nil)
                        } else {
                            print ("Email verified. Signing in...")
                            self.performSegue(withIdentifier: "home_segue", sender: self)
                        }
                    } else {
                        
                        let alert = UIAlertController(title: "Invalid User", message: "The email or password entered is not valid", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        print("No user")
                       
                        
                    }
                })
            } else {
                if Error == nil{
                    print("invalid email")
                    let alert = UIAlertController(title: "Invalid Email", message: "The email or password entered is not valid", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if let errCode = AuthErrorCode(rawValue: Error!._code) {
                        
                        switch errCode {
                        case .invalidEmail:
                            print("invalid email")
                            let alert = UIAlertController(title: "Invalid Email", message: "The email or password entered is not valid", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        default:
                            print(Error!)
                        }
                    }
                }
                
            }
        }))
            
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


