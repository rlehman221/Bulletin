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
    
    var receivedName = ""
    var receivedPostData = ""
    var receivedSubject = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = receivedName
        post_data.text = receivedPostData
        subject.text = receivedSubject  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
