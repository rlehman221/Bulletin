//
//  View that displays to the user a sign up menu, allowing a new user to enter
//  an email and password to be submitted 
//
//  Created by Ryan Lehman on 2/15/18.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    // sets the inital UI
    let initView = SignUpView()
    var confirmButton: UIButton = UIButton()
    var backButton: UIButton = UIButton()
    var emailField: UITextField = UITextField()
    var nameField: UITextField = UITextField()
    var passwordField: UITextField = UITextField()
    var textE: UILabel = UILabel()
    var emailHolder = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        init_all()
    }
    
    // initialize all UI elements and add them to the view
    func init_all(){
        
        backButton = initView.back_button(input_button: backButton)
        confirmButton = initView.signUp_button(input_button: confirmButton)
        emailField = initView.email_box(input_field: emailField)
        nameField = initView.name_box(input_field: nameField)
        passwordField = initView.password_box(input_field: passwordField)
        confirmButton.addTarget(self, action: #selector(self.signUp(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(self.goBack(_:)), for: .touchUpInside)
        // loading the view.
        
        emailField.delegate = self
        self.view.addSubview(confirmButton)
        self.view.addSubview(backButton)
        self.view.addSubview(emailField)
        self.view.addSubview(nameField)
        self.view.addSubview(passwordField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if emailHolder {
            textField.text = textField.text! + "@rpi.edu"
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.beginningOfDocument)
        }
        emailHolder = false
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@rpi.edu"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    // activates on button pressing to allow text field
    // information to be setup as a new user
    
    @objc func signUp(_ sender:UIButton!){
        let newUser = User(email: emailField.text!, password: passwordField.text!, name: nameField.text!) // Creates a new instance of  user
        newUser.add_User() // Calls the add function on the user
        /*
            CBT - Alerts need to change based on (if successful, user already exists, invalid email, etc) as of right now it only returns successful, need to changed based in Model_Root folder and this file
        */
        let alertArray = newUser.getter_alert() // Get an alert from User class to see if adding user was successful
        
        let alert = UIAlertController(title: alertArray[0], message: alertArray[1], preferredStyle: UIAlertControllerStyle.alert)

        // Add the actions
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("Next Story Board")
            self.performSegue(withIdentifier: "backTo_sign_in_segue", sender: self) // Be directed back to login view controller
        }
        
        // Link to alert controller
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil) // Display alert to the user
        
        
        
    }
    
    // go back to login view from button press
    @objc func goBack(_ sender:UIButton!){
        self.performSegue(withIdentifier: "backTo_sign_in_segue", sender: self)
    }

}
