/**
 * SignUpViewController
 *
 * Created on: July 1, 2018
 * Authors: Ryan Lehman
 *
 * Description: Allows the user to enter their email into a textfield. After a send
 * button is clicked a firebase call is made to see if the password mapped to the email
 * can be reset. If the email is valid an email will send through. If not the user is
 * displayed an error message.
 */

import UIKit
import Firebase

class Forgot_PasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email_field: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.email_field.delegate = self as UITextFieldDelegate

        
        // Do any additional setup after loading the view.
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the search to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    * Triggered from interaction with a textfield, an email is sent to
    * the firebase database to reset the users password. If the email is
    * invalid a alert is presented to the screen. If the email is valid
    * the screen is moved back to the login screen through a segue.
    *
    * @param UIButton press
    *
    * @return
    */
    @IBAction func send_button(_ sender: Any)
    {
        Auth.auth().sendPasswordReset(withEmail: email_field.text!) { (error) in
            
            if ((error) != nil){
                
                if (error?.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted.") {
                    
                   let invalid_Alert = UIAlertController(title: "Invalid Attempt", message: "The email provided does not have an account", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel)
                    invalid_Alert.addAction(okAction)
                    self.present(invalid_Alert, animated: true, completion: nil)
                    
                } else {
                    
                    let invalid_Alert = UIAlertController(title: "Invalid Attempt", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel)
                    invalid_Alert.addAction(okAction)
                    self.present(invalid_Alert, animated: true, completion: nil)
                    
                }
            } else {
                let valid_Alert = UIAlertController(title: "Email Successfully Sent", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.performSegue(withIdentifier: "to_home", sender: self) // Be directed back to login view controller
                }
                valid_Alert.addAction(okAction)
                self.present(valid_Alert, animated: true, completion: nil)
            }
        }
    }
}
