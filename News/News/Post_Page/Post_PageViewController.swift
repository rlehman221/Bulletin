//
//  Post_PageViewController.swift
//  News
//
//  Created by Ryan Lehman on 3/31/18.
//

import UIKit

class Post_PageViewController: UIViewController {

    @IBOutlet weak var post_data: UITextView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var date: UILabel!
    
    var receivedName = ""
    var receivedPostData = ""
    var receivedSubject = ""
    var receivedDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = receivedName
        post_data.text = receivedPostData
        subject.text = receivedSubject
        date.text = receivedDate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
