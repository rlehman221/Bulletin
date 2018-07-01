/**
 * SignUpViewController
 *
 * Created on: June 20, 2018
 * Authors: Ryan Lehman && Nik Murphy
 *
 * Description: Displays a sign up menu that allows an email and password to
 * be sent to a database (firebase) and send an email verfication to the users email. If
 * the user is already a user an alert is prompted. If the data is successfully sent to the database
 * a User instance is called and the user is the generated in the database.
 */

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!

    var emailHolder = true // Allows "RPI.edu" to only be appended once to the users email
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        confirmButton.addTarget(self, action: #selector(self.signUp(_:)), for: .touchUpInside)
        emailField.delegate = self
    }
    
   /**
    * Triggered from interaction with a textfield, RPI is appened after the text
    *
    * @param Textfield interaction trigger
    *
    * @return
    */
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if emailHolder {
            textField.text = textField.text! + "@rpi.edu"
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.beginningOfDocument)
        }
        emailHolder = false
    }
    
   /**
    * Checks to see if the email entered has valid characters for a
    * valid email address and uses an RPI email
    *
    * @param An email taken in as a string
    *
    * @return Boolean value if email is valid or not
    */
    func isValidEmail(testStr:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@rpi.edu"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: testStr)
    }

   /**
    * Creates a new instance of a user and sets corresponding values.
    * Prompts an alert to the user based on response base and if succcessful performs
    * a segue back to the login screen
    *
    * @param UIButton press
    *
    * @return
    */
    @objc func signUp(_ sender:UIButton!)
    {
        let new_User = User(email: emailField.text!, password: passwordField.text!, name: nameField.text!) // Creates a new instance of  user
        new_User.add_User() // Calls the add function on the user
        /*
            CBT - Alerts need to change based on (if successful, user already exists, invalid email, etc) as of right now it only returns successful, need to changed based in Model_Root folder and this file
        */
        let alertArray = new_User.getter_alert() // Get an alert from User class to see if adding user was successful
        let alert = UIAlertController(title: alertArray[0], message: alertArray[1], preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.performSegue(withIdentifier: "to_home", sender: self) // Be directed back to login view controller
        }
        
        // Link to alert controller
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil) // Display alert to the user
        
    }
}
