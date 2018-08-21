//
//  Post_PageViewController.swift
//  News
//
//  Created by Ryan Lehman on 3/31/18.
//

import UIKit

class Post_PageViewController: UIViewController {

    @IBOutlet weak var scroll_view: UIScrollView!
    @IBOutlet weak var post_data: UITextView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var date: UILabel!
    
    var receivedName = ""
    var receivedPostData = ""
    var receivedSubject = ""
    var receivedDate = ""
    var senderInfo = 0 // Value to determine which segue to take (0)=all_feed (1)=my_feed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scroll_view.backgroundColor = .clear
        name.text = receivedName
        post_data.text = receivedPostData
        subject.text = receivedSubject
        date.text = "Posted:" + receivedDate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back_button_clicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        
        switch senderInfo {
            case 0:
                performSegue(withIdentifier: "all_feed_left", sender: self)
            case 1:
                performSegue(withIdentifier: "my_feed_left", sender: self)
            default: // Used for error checking
                performSegue(withIdentifier: "all_feed_left", sender: self)
            }
    }
}
