/**
 * LoginViewController
 *
 * Created on: June 20, 2018
 * Authors: Ryan Lehman && Nik Murphy
 *
 * Description: Displays a login menu that allows an email and password to
 *  be verfied through a database (firebase) and continue onto the main screen. If
 *  the user is not verified they will be prompted through alerts. A signup button is
 *  also displayed to take the user to a sign up page. Their also is a forgot my password
 *  fuctionuialtiy to allow a users password to be reset through our database (firebase).
 */

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Used for dismissing keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        emailField.text = ""
        passwordField.text = ""
        self.emailField.delegate = self as UITextFieldDelegate
        self.passwordField.delegate = self as UITextFieldDelegate
        signInButton.addTarget(self, action: #selector(self.signIn(_:)), for: .touchUpInside)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

   
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the search to resign the first responder status.
        view.endEditing(true)
    }
    
   /**
    * Description: Triggered from button call and checks users email and password for verfication.
    * If data is confirmed segue is triggered if not an UI alert is triggered for display
    *
    *
    * @param UIButton press
    *
    * @return
    */
    @objc func signIn(_ sender:UIButton!)
    {
        try! Auth.auth().signOut()
        Auth.auth().fetchProviders(forEmail: emailField.text!, completion: ({ (Data, Error) in
            
            if ((Error == nil) && (Data != nil)){
                
                Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                    
                    if let user = Auth.auth().currentUser {
                        
                        if !user.isEmailVerified {
                            let not_verif_Alert = UIAlertController(title: "Not Verified", message: "Please verify your account", preferredStyle: UIAlertControllerStyle.alert)
                            let re_verfiyAction = UIAlertAction(title: "Resend Verfication Email", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                                User(email: self.emailField.text!, password: self.passwordField.text!, name: "").send_Verification()
                            }
                            
                            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel)
                            
                            not_verif_Alert.addAction(re_verfiyAction)
                            not_verif_Alert.addAction(okAction)
                            
                            self.present(not_verif_Alert, animated: true, completion: nil)
                            
                        } else {
                            self.performSegue(withIdentifier: "home_segue", sender: self)
                        }
                    } else {
                        let invalid_alert = UIAlertController(title: "Invalid User", message: "The email or password entered is not valid", preferredStyle: UIAlertControllerStyle.alert)
                        invalid_alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        
                        self.present(invalid_alert, animated: true, completion: nil)
                    }
                })
            } else {
                if Error == nil{
                    let invalid_alert = UIAlertController(title: "Invalid Email", message: "The email or password entered is not valid", preferredStyle: UIAlertControllerStyle.alert)
                    invalid_alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    
                    self.present(invalid_alert, animated: true, completion: nil)
                    
                } else {
                    if let errCode = AuthErrorCode(rawValue: Error!._code) {
                        
                        switch errCode {
                        case .invalidEmail:
                            let invalid_alert = UIAlertController(title: "Invalid Email", message: "The email or password entered is not valid", preferredStyle: UIAlertControllerStyle.alert)
                            
                            invalid_alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            
                            self.present(invalid_alert, animated: true, completion: nil)
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


