//
//  AddSubViewController.swift
//  News
//
//  Created by Nik Murthy on 5/24/18.
//

import UIKit
import Firebase

class AddSubViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var search_bar: UISearchBar!
    
    var search_text = ""
    
    var refreshControl: UIRefreshControl!
    
    var ref: DatabaseReference!
    var subList = [Int : (String , Bool)] ()
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        search_bar.delegate = self
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.subList.count == 0) {
            return 1
        }
        return self.subList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.subList.count == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "allsub_cell", for: indexPath as IndexPath) as! AllSubTableViewCell
            cell.allsub_label.text = "No clubs found."
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "addsub_cell", for: indexPath as IndexPath) as? SubscribeTableViewCell
        cell!.club_button.setTitle(self.subList[indexPath.row]!.0, for: UIControlState.normal)
        cell!.club_button.tag = indexPath.row
        cell!.subscribe_button.tag = indexPath.row
        cell!.subscribe_button.addTarget(self, action: #selector(AddSubViewController.subscribe(_:)), for: .touchUpInside)
        return cell!
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
                if (!val) {
                    if (self.search_text == "" || name.lowercased().range(of: self.search_text.lowercased()) != nil) {
                        self.subList[count] = (name , val)
                        count += 1;
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    @objc func subscribe(_ sender:UIButton!) {
        let UID = (Auth.auth().currentUser?.uid)
        ref = Database.database().reference()
        ref.child("Users").child(UID!).child("Subscribed").child(((tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! SubscribeTableViewCell).club_button.titleLabel!.text)!).setValue(true)
        
        
        var subscribersCount = 0
        let clubChoosen = ((tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! SubscribeTableViewCell).club_button.titleLabel!.text)!
        let topicString = clubChoosen.replacingOccurrences(of: " ", with: "")
        
        Messaging.messaging().subscribe(toTopic: topicString)
        ref.child("Clubs").child(clubChoosen).child("Subscribers").observe(.value) { (snapshot) in
            
            subscribersCount = (snapshot.value)! as! Int
            subscribersCount += 1
            self.ref.child("Clubs").child(clubChoosen).child("Subscribers").setValue(subscribersCount)
            
        }
        self.refreshData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search_text = searchBar.text!
        self.refreshData()
    }
}
