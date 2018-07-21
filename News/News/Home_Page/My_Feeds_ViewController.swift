//
//  My_Feeds_ViewController.swift
//  News
//
//  Created by Ryan Lehman on 7/2/18.
//

import UIKit
import Firebase

class My_Feeds_ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var table_view: UITableView!
    
    @IBOutlet weak var search_bar: UISearchBar!
    
    @IBOutlet weak var filter_button: UIButton!
    
    @IBOutlet weak var filter_label: UILabel!
    
    var feed_data = [Int : [String : String]] ()
    var clubHolder = [String]()
    var post_time = "";
    var counter2 = 0;
    
    var refreshControl: UIRefreshControl!
    
    var ref: DatabaseReference! // Reference to database
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var selected_Post = 0;

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        table_view.dataSource = self
        table_view.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshData), for: UIControlEvents.valueChanged)
        //refreshControl.backgroundColor = UIColor.redColor
        // refreshControl.tintColor = UIColor.yellowColor
        table_view.addSubview(refreshControl)
        loadClubs {
            self.load_database()
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func refreshData()
    {
        
        loadClubs {
            self.load_database()
        }
        reloadDuration()
        
        self.table_view.reloadData()
        refreshControl?.endRefreshing()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("went into tableview2")
        return self.feed_data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print("went into tableview")
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! My_Feed_TableViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.club_name.text = self.feed_data[indexPath.item]?["Name"]
        cell.Subject.text = self.feed_data[indexPath.item]?["Subject"]
        cell.time_duration.text = self.feed_data[indexPath.item]?["Duration"]
        cell.image_view.layer.masksToBounds = true
        cell.image_view.layer.cornerRadius = CGFloat(roundf(Float(4)))
        
        cell.backgroundColor = UIColor.white // make cell more visible in our example project
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        print("You selected cell #\(indexPath.item)!")
        self.selected_Post = indexPath.item
        self.performSegue(withIdentifier: "go_to_post", sender: self)
    }

    // Loads only clubs that the user has subscribed to into an array for later comparison
    func loadClubs (finished: @escaping () -> Void)
    {
        ref = Database.database().reference() // Reference to database
        let uid = Auth.auth().currentUser?.uid
        ref.child("Users").child(uid!).child("Subscribed").observeSingleEvent(of: .value) { (snapshot) in
            let subClubs = snapshot.value
            let all_clubs = subClubs as? [String: Bool]
            for (club, value) in all_clubs! {
                if (value) {
                    self.clubHolder.append(club)
                }
            }
            
            self.counter2 = self.clubHolder.count
            
            finished()
        }
    }
    
    func load_database()
    {
        ref = Database.database().reference() // Reference to database
        
        ref.child("Feed").queryOrdered(byChild: "Date").observe(.childAdded, with: { (snapshot) -> Void in
            
            let posts = snapshot.value
            let all_posts = posts as? [String: String]
            if (self.clubHolder.contains(all_posts!["Name"]!)){
                
                self.counter2 -= 1
                self.feed_data[self.counter2] = all_posts
                self.post_time = table_view_helper().timeDuration(date: self.feed_data[0]!["Date"]!)
                self.feed_data[self.counter2]!["Duration"] = self.post_time
            }
            self.table_view.reloadData()
            print(self.feed_data.count)
        })
    }
    
    // Fix - Thread 1: Fatal error: Can't form Range with upperBound < lowerBound
    func reloadDuration()
    {
        for index in 0...(feed_data.count - 1) {
            post_time = table_view_helper().timeDuration(date: self.feed_data[index]!["Date"]!)
            self.feed_data[index]!["Duration"] = post_time
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let dataToSend = segue.destination as? Post_PageViewController
        dataToSend?.receivedPostData = (self.feed_data[selected_Post]?["Body"])!
        dataToSend?.receivedName = (self.feed_data[selected_Post]?["Name"])!
        dataToSend?.receivedSubject = (self.feed_data[selected_Post]?["Subject"])!
        dataToSend?.receivedDate = (self.feed_data[selected_Post]?["Duration"])!
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
