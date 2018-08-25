//
//  SubscriptionNewViewController.swift
//  News
//
//  Created by Ryan Lehman on 7/8/18.
//

import UIKit
import Firebase

class SubscriptionNewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    
    var refreshControl: UIRefreshControl!
    var subscribersCount = 0
    var ref: DatabaseReference!
    var subList = [Int : (String , Bool)] ()
    let cellSpacingHeight: CGFloat = 10
    
    override func viewDidLoad() {
        getInfo()
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
        
        self.refreshData()

        // Do any additional setup after loading the view.
    }
    
    @objc func refreshData() {
        getInfo()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.subList.count == 0 {
            return 1
        }
        return self.subList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
 
        if self.subList.count != 0 {
            let TrashAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

                self.unsubscribe(index: indexPath.section)
                success(true)
            })
            TrashAction.backgroundColor = .red
            return UISwipeActionsConfiguration(actions: [TrashAction])
        }
        else {
            let swipeAction = UISwipeActionsConfiguration(actions: [])
            return swipeAction
        }
    }
    
    @IBAction func return_button_pressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        performSegue(withIdentifier: "return", sender: self)
    }
    
    @IBAction func add_sub_button_pressed(_ sender: Any) {
        performSegue(withIdentifier: "add_Sub_view", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.subList.count == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nosub_cell", for: indexPath as IndexPath) as! NoSubTableViewCell

            cell.nosub_label.text = "You don't have any active subscriptions!"
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! SubscriptionTableViewCell
            cell.clubName.text = subList[indexPath.section]!.0
            return cell
        }
    }
    
    func getInfo() {
        let UID = (Auth.auth().currentUser?.uid)
        ref = Database.database().reference()
        ref.child("Users").child(UID!).child("Subscribed").observe(.value, with: { (snapshot) in
            self.subList.removeAll()
            let subs = snapshot.value as? [String:Bool]
            var count = 0
            for (name,val) in subs! {
                if (val) {
                    self.subList[count] = (name , val)
                    count += 1;
                }
            }
            self.tableView.reloadData()
        })
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    func unsubscribe(index: Int) {
        let UID = (Auth.auth().currentUser?.uid)
        ref = Database.database().reference()
        let clubChoosen = ((tableView.cellForRow(at: IndexPath(row: 0, section: index)) as! SubscriptionTableViewCell).clubName.text)!
        let club = (tableView.cellForRow(at: IndexPath(row: 0, section: index)) as! SubscriptionTableViewCell).clubName.text!
        ref.child("Users").child(UID!).child("Subscribed").child(club).setValue(false) {
            (error:Error?, ref:DatabaseReference) -> Void in
            if error != nil {
                print("Data could not be saved")
            }
            else {
                print("Data saved successfully")
            }
        }
        
        let topicString = clubChoosen.replacingOccurrences(of: " ", with: "")
        
        Messaging.messaging().unsubscribe(fromTopic: topicString)
        
        updateClub(finished: {
            self.ref.child("Clubs").child(clubChoosen).child("Subscribers").setValue(self.subscribersCount)
            self.refreshData()
        }, clubChoosen: clubChoosen)
        
        self.refreshData()
    }
    
    func updateClub (finished: @escaping () -> Void, clubChoosen: String) {
        ref.child("Clubs").child(clubChoosen).child("Subscribers").observeSingleEvent(of: .value) { (snapshot) in
            
            self.subscribersCount = (snapshot.value)! as! Int
            if (self.subscribersCount != 0){
                self.subscribersCount -= 1
                self.refreshData()
            }
            
            finished()
        }
    }

}
