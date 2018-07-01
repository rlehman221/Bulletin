//
//  My_Feed_ViewController.swift
//  News
//
//  Created by Ryan Lehman on 4/7/18.
//

import UIKit
import Firebase

class My_Feed_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionview: UICollectionView!
    var feed_data = [Int : [String : String]] ()
    var clubHolder = [String]()
    var post_time = "";
    var counter2 = 0;
    
    var refreshControl: UIRefreshControl!
    
    var ref: DatabaseReference! // Reference to database
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var selected_Post = 0;
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshData), for: UIControlEvents.valueChanged)
        //refreshControl.backgroundColor = UIColor.redColor
        // refreshControl.tintColor = UIColor.yellowColor
        collectionview.addSubview(refreshControl)
        loadClubs {
            self.load_database()
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func refreshData() {
        reloadDuration()
        
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! My_Feed_CollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.label.text = self.feed_data[indexPath.item]?["Name"]
        cell.subject.text = self.feed_data[indexPath.item]?["Subject"]
        
        cell.time_duration.text = self.feed_data[indexPath.item]?["Duration"]
        cell.imageView.layer.masksToBounds = true
        cell.imageView.layer.cornerRadius = CGFloat(roundf(Float(4)))
        cell.imageView.image = UIImage(named: cell.label.text!)
        
        cell.backgroundColor = UIColor.white // make cell more visible in our example project
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        self.selected_Post = indexPath.item
        self.performSegue(withIdentifier: "post_screen_segue2", sender: self)
        
    }
    
    // Loads only clubs that the user has subscribed to into an array for later comparison
    func loadClubs (finished: @escaping () -> Void) {
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
  
    func load_database() {
        print("Went here")
        ref = Database.database().reference() // Reference to database
        
        ref.child("Feed").queryOrdered(byChild: "Date").observe(.childAdded, with: { (snapshot) -> Void in
            
            let posts = snapshot.value
            let all_posts = posts as? [String: String]
            if (self.clubHolder.contains(all_posts!["Name"]!)){
                print("Went here")
                self.counter2 -= 1
                self.feed_data[self.counter2] = all_posts
                self.post_time = self.timeDuration(date: self.feed_data[self.counter2]!["Date"]!)
                self.feed_data[self.counter2]!["Duration"] = self.post_time
                
            }
            self.collectionview.reloadData()
            
        })
        
    }
    
    func reloadDuration(){
        for index in 0...(feed_data.count - 1) {
            post_time = self.timeDuration(date: self.feed_data[index]!["Date"]!)
            self.feed_data[index]!["Duration"] = post_time
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dataToSend = segue.destination as? Post_PageViewController
        dataToSend?.receivedPostData = (self.feed_data[selected_Post]?["Body"])!
        dataToSend?.receivedName = (self.feed_data[selected_Post]?["Name"])!
        dataToSend?.receivedSubject = (self.feed_data[selected_Post]?["Subject"])!
    }
    

}
