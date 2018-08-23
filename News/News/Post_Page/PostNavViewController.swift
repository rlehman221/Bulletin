//
//  PostNavViewController.swift
//  News
//
//  Created by Ryan Lehman on 8/20/18.
//

import UIKit

class PostNavViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NAv Controller")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Appreaered")
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
