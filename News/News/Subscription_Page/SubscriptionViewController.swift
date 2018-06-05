//
//  SubscriptionViewController.swift
//  News
//
//  Created by Nik Murthy on 4/2/18.
//

import UIKit
import Firebase

class SubscriptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var ref: DatabaseReference!
    var subList = [Int : (String , Bool)] ()

    override func viewDidLoad() {
        getInfo()
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1) {
            if (self.subList.count == 0) {
                return 1
            }
            return self.subList.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addsub_cell", for: indexPath as IndexPath) as! AddSubTableViewCell
            cell.addsub_label.text = "Add Subscriptions"
            return cell
        }
        if (self.subList.count == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nosub_cell", for: indexPath as IndexPath) as! NoSubTableViewCell
            cell.nosub_label.text = "You don't have any active subscriptions!"
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as? SubscriptionTableViewCell
            cell!.clubName.text = subList[indexPath.row]!.0
            cell!.unsub_button.tag = indexPath.row
            cell!.unsub_button.addTarget(self, action: "unsubscribe:", for: .touchUpInside)
            return cell!
        }
    }

    func getInfo() {
        subList.removeAll()
        let UID = (Auth.auth().currentUser?.uid)
        ref = Database.database().reference()
        ref.child("Users").child(UID!).child("Subscribed").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            let subs = snapshot.value as? [String:Bool]
            var count = 0
            for (name,val) in subs! {
                if (val) {
                    self.subList[count] = (name , val)
                    count += 1;
                }
            }
            self.tableView.reloadData()
            print("went here")
        })
    }
    
    @objc func unsubscribe(_ sender:UIButton!) {
        let UID = (Auth.auth().currentUser?.uid)
        ref = Database.database().reference()
        ref.child("Users").child(UID!).child("Subscribed").child((tableView.cellForRow(at: IndexPath(row: sender.tag, section: 1)) as! SubscriptionTableViewCell).clubName.text!).setValue(false)
        self.refreshData()
    }
}