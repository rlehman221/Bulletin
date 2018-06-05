//
//  LoginView.swift
//  News
//
//  Created by Ryan Lehman on 2/15/18.
//

import Foundation
import UIKit
import Firebase

class SignUpView {
    
    // button interface for signing up new user
    func signUp_button(input_button: UIButton) -> UIButton{
        
        let button = input_button
        let xPostion:CGFloat = 115
        let yPostion:CGFloat = 400
        let buttonWidth:CGFloat = 150
        let buttonHeight:CGFloat = 45
        button.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        button.backgroundColor = UIColor.lightGray
        button.setTitle("Sign Up", for: UIControlState.normal)
        button.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        return button
    }
    
    // button interface for going back to login view
    func back_button(input_button: UIButton) -> UIButton{
        
        let button = input_button
        let xPostion:CGFloat = 155
        let yPostion:CGFloat = 450
        let buttonWidth:CGFloat = 75
        let buttonHeight:CGFloat = 40
        button.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        button.backgroundColor = UIColor.lightGray
        button.setTitle("Back", for: UIControlState.normal)
        button.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        return button
    }
    
    // text field interface for email
    func email_box(input_field: UITextField) -> UITextField {
        
        let txtField = input_field
        let xPostion:CGFloat = 70
        let yPostion:CGFloat = 200
        let buttonWidth:CGFloat = 250
        let buttonHeight:CGFloat = 45
        txtField.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        txtField.backgroundColor = UIColor.gray
        txtField.placeholder = "Email"
        txtField.layer.cornerRadius = 15.0
        txtField.textAlignment = .center
        txtField.textColor = UIColor.black
        return txtField
    }
    
    // text field interface for password
    func password_box(input_field: UITextField) -> UITextField {
        
        let txtField = input_field
        let xPostion:CGFloat = 70
        let yPostion:CGFloat = 300
        let buttonWidth:CGFloat = 250
        let buttonHeight:CGFloat = 45
        txtField.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        txtField.backgroundColor = UIColor.gray
        txtField.placeholder = "Password"
        txtField.layer.cornerRadius = 15.0
        txtField.textAlignment = .center
        txtField.textColor = UIColor.black
        txtField.isSecureTextEntry = true
        return txtField
    }
    
    // text field interface for display name
    func name_box(input_field: UITextField) -> UITextField {
        
        let txtField = input_field
        let xPostion:CGFloat = 70
        let yPostion:CGFloat = 250
        let buttonWidth:CGFloat = 250
        let buttonHeight:CGFloat = 45
        txtField.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        txtField.backgroundColor = UIColor.gray
        txtField.placeholder = "Display Name"
        txtField.layer.cornerRadius = 15.0
        txtField.textAlignment = .center
        txtField.textColor = UIColor.black
        return txtField
    }
    
    
}


