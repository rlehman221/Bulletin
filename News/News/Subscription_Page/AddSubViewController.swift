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
    var subscribersCount = 0
    var refreshControl: UIRefreshControl!
    
    var ref: DatabaseReference!
    var subList = [Int : (String , Bool)] ()
    
    override func viewDidLoad() {
        let textFieldInsideSearchBar = search_bar.value(forKey: "searchField") as? UITextField
        let placeholderField = search_bar.value(forKey: "placeholder") as? UITextField
        
        placeholderField?.font = UIFont(name: "Apple SD Gothic Neo", size: (placeholderField?.font?.pointSize)!)
        placeholderField?.textColor = UIColor.black
        textFieldInsideSearchBar?.font = UIFont(name: "Apple SD Gothic Neo", size: (textFieldInsideSearchBar?.font?.pointSize)!)
        textFieldInsideSearchBar?.textColor = UIColor.black
        search_bar.layer.cornerRadius = 5
        search_bar.setImage(UIImage(named: "search_black"), for: UISearchBarIcon.search, state: .normal)
        textFieldInsideSearchBar?.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
        tableView.dataSource = self
        tableView.delegate = self
        search_bar.delegate = self
        getInfo()
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        tableView.tableHeaderView = search_bar
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
        if (self.subList.count == 0) {
            return 1
        }
        return self.subList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.subList.count == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "allsub_cell", for: indexPath as IndexPath) as! AllSubTableViewCell
            cell.allsub_label.text = "No clubs found."
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "addsub_cell", for: indexPath as IndexPath) as? SubscribeTableViewCell
        cell!.club_name.text = self.subList[indexPath.section]!.0
        cell!.club_name.tag = indexPath.section
        return cell!
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Write action code for the trash
        let TrashAction = UIContextualAction(style: .normal, title:  "Add", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("add")
            self.subscribe(index: indexPath.section)
            success(true)
        })
        TrashAction.backgroundColor = UIColor.init(red: 0, green: 0.7, blue: 0, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [TrashAction])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    func getInfo() {
        let UID = (Auth.auth().currentUser?.uid)
        ref = Database.database().reference()
        ref.child("Users").child(UID!).child("Subscribed").observe(.value, with: { (snapshot) in
            self.subList.removeAll()
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
    
    func subscribe(index: Int)
    {
        let UID = (Auth.auth().currentUser?.uid)
        ref = Database.database().reference()
        let clubChoosen = ((tableView.cellForRow(at: IndexPath(row: 0, section: index)) as! SubscribeTableViewCell).club_name.text)!
        let club = (tableView.cellForRow(at: IndexPath(row: 0, section: index)) as! SubscribeTableViewCell).club_name.text!
        ref.child("Users").child(UID!).child("Subscribed").child(club).setValue(true) {
            (error:Error?, ref:DatabaseReference) -> Void in
            if error != nil {
                print("Data could not be saved")
            }
            else {
                print("Data saved successfully")
            }
        }
        
        let topicString = clubChoosen.replacingOccurrences(of: " ", with: "")
        
        Messaging.messaging().subscribe(toTopic: topicString)
        
        updateClub(finished: {
            self.ref.child("Clubs").child(clubChoosen).child("Subscribers").setValue(self.subscribersCount)
        }, clubChoosen: clubChoosen)
        
        self.refreshData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search_text = searchBar.text!
        self.refreshData()
    }
    
    // Allows for the search bar to automatically update as the user is typing
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search_text = searchBar.text!
        self.refreshData()
    }
    
    
    func updateClub (finished: @escaping () -> Void, clubChoosen: String) {
        
        ref.child("Clubs").child(clubChoosen).child("Subscribers").observeSingleEvent(of: .value) { (snapshot) in
            if let count = snapshot.value as? Int {
                self.subscribersCount = count
            }
            else {
                self.subscribersCount = 0
            }
            self.subscribersCount += 1
            finished()
        }
    }
}
