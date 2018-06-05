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
    var post_time = "";
    var counter2 = 0;
    
    var refreshControl: UIRefreshControl!
    
    var ref: DatabaseReference! // Reference to database
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var selected_Post = 0;
    
    override func viewDidLoad() {
        load_database()
        super.viewDidLoad()
        //refreshControl = UIRefreshControl()
        //refreshControl.addTarget(self, action:  #selector(refreshData), for: UIControlEvents.valueChanged)
        //refreshControl.backgroundColor = UIColor.redColor
        // refreshControl.tintColor = UIColor.yellowColor
        //collectionview.addSubview(refreshControl)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func refreshData() {
        reloadDuration()
        
        self.collectionview.reloadData()
        refreshControl?.endRefreshing()
    }
    
    
    func timeDuration(date: String) -> String {
        
        let compareDateString = date
        
        let dateFormatter = ISO8601DateFormatter()
        let currentDate = Date();
        let compareDate = dateFormatter.date(from:compareDateString)!
        let timeComponents: Set = [Calendar.Component.month,Calendar.Component.day,Calendar.Component.hour, Calendar.Component.minute]
        var time_interval = NSCalendar.current.dateComponents(timeComponents, from: compareDate, to: currentDate)
        
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
        self.performSegue(withIdentifier: "post_screen_segue2", sender: self)
        
    }
    
    func load_database() {
        
        ref = Database.database().reference() // Reference to database
        ref.child("Feed").observe(.value) { (snapshot) in
            self.counter2 = Int(snapshot.childrenCount)
        }
        ref.child("Feed").queryOrdered(byChild: "Date").observe(.childAdded, with: { (snapshot) -> Void in
            
            let posts = snapshot.value
            let all_posts = posts as? [String: String]
            
            self.counter2 -= 1
            self.feed_data[self.counter2] = all_posts
            self.post_time = self.timeDuration(date: self.feed_data[self.counter2]!["Date"]!)
            self.feed_data[self.counter2]!["Duration"] = self.post_time
            
            
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
