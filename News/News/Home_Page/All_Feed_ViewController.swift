//
//  Home_Screen_ViewController.swift
//  News
//
//  Created by Ryan Lehman on 3/30/18.
//

import UIKit
import Firebase

class All_Feed_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var filter_button: UIButton!
    
    var feed_data: [[String:String]] = []
    var post_time = ""
    var search_text = ""
    var filter = "both"
    
    var refreshControl: UIRefreshControl!
    
    var ref: DatabaseReference! // Reference to database
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var selected_Post = 0
    
    override func viewDidLoad() {
        search_bar.delegate = self
        load_database()
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshData), for: UIControlEvents.valueChanged)
        //refreshControl.backgroundColor = UIColor.redColor
       // refreshControl.tintColor = UIColor.yellowColor
        collectionView.addSubview(refreshControl)
        
        filter_button.addTarget(self, action: #selector(All_Feed_ViewController.changeFilters(_:)), for: .touchUpInside)
    }
    
    @objc func refreshData() {
        load_database()
        reloadDuration()
        
        self.collectionView.reloadData()
        refreshControl?.endRefreshing()
    }
 
    
    func timeDuration(date: String) -> String {
        
        let compareDateString = date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let compareDate2 = dateFormatter.date(from:compareDateString)
       
        let currentDate = Date()
        
        let timeComponents: Set = [Calendar.Component.month,Calendar.Component.day,Calendar.Component.hour, Calendar.Component.minute]
        var time_interval = NSCalendar.current.dateComponents(timeComponents, from: compareDate2!, to: currentDate)
        
        if time_interval.day != 0 {
            return "\(String(describing: time_interval.day!))d ago"
        } else if time_interval.hour != 0 {
            return "\(String(describing: time_interval.hour!))h ago"
        } else {
            return "\(String(describing: time_interval.minute!))m ago"
        }
    }
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feed_data.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! All_Feed_CollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.label.text = self.feed_data[indexPath.item]["Name"]
        cell.subject.text = self.feed_data[indexPath.item]["Subject"]
        
        cell.time_duration.text = self.feed_data[indexPath.item]["Duration"]
        cell.imageView.layer.masksToBounds = true
        cell.imageView.layer.cornerRadius = CGFloat(roundf(Float(4)))
        let i = arc4random() % 3
        if i == 0 {
            cell.imageView.image = UIImage(named: "CS_Club")
        } else if i == 1 {
            cell.imageView.image = UIImage(named: "Archery_Club")
        } else {
            cell.imageView.image = UIImage(named: "RPI")
        }
    
        cell.backgroundColor = UIColor.white // make cell more visible in our example project
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        self.selected_Post = indexPath.item
        self.performSegue(withIdentifier: "post_screen_segue", sender: self)

    }
    
    func load_database() {
        self.feed_data.removeAll()
        ref = Database.database().reference() // Reference to database
        
        ref.child("Feed").queryOrdered(byChild: "Date").observe(.childAdded, with: { (snapshot) -> Void in
            
            let posts = snapshot.value
            let all_posts = posts as? [String: String]
            if (self.search_text == ""
                || all_posts!["Name"]?.lowercased().range(of: self.search_text.lowercased()) != nil
                || all_posts!["Subject"]?.lowercased().range(of: self.search_text.lowercased()) != nil
                || all_posts!["Body"]?.lowercased().range(of: self.search_text.lowercased()) != nil) {
                
                if (self.filter == "both"
                    || (self.filter == "event" && all_posts!["Type"] == "Event")
                    || (self.filter == "announcement" && all_posts!["Type"] == "Announcement")) {
                    self.feed_data.insert(all_posts!, at: 0)
                    self.post_time = self.timeDuration(date: self.feed_data[0]["Date"]!)
                    self.feed_data[0]["Duration"] = self.post_time
                }
            }
            self.collectionView.reloadData()
        })
    }
    
    func reloadDuration(){
        if (feed_data.count == 0) {
            return
        }
        for index in 0...(feed_data.count - 1) {
            post_time = self.timeDuration(date: self.feed_data[index]["Date"]!)
            self.feed_data[index]["Duration"] = post_time
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dataToSend = segue.destination as? Post_PageViewController
        dataToSend?.receivedPostData = (self.feed_data[selected_Post]["Body"])!
        dataToSend?.receivedName = (self.feed_data[selected_Post]["Name"])!
        dataToSend?.receivedSubject = (self.feed_data[selected_Post]["Subject"])!
    }
  
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search_bar.resignFirstResponder()
        search_text = search_bar.text!
        self.refreshData()
    }
    
    @objc func changeFilters(_ sender: UIButton!) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Events Only", style: .default, handler: { _ in
            self.filter = "event"
            self.refreshData()
        }))
        alert.addAction(UIAlertAction(title: "Announcements Only", style: .default, handler: { _ in
            self.filter = "announcement"
            self.refreshData()
        }))
        alert.addAction(UIAlertAction(title: "Events & Announcements", style: .default, handler: { _ in
            self.filter = "both"
            self.refreshData()
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
