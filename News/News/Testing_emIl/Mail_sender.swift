//
//  Mail_sender.swift
//  News
//
//  Created by Ryan Lehman on 5/27/18.
//

import Foundation
import MessageUI
import UIKit

class emailClass: UIViewController, MFMailComposeViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        sendEmail()
    }
    
    func sendEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["address@example.com"])
        composeVC.setSubject("Hello!")
        composeVC.setMessageBody("Hello this is my message body!", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
