//
//  All_Feeds_ViewController.swift
//  News
//
//  Created by Ryan Lehman on 7/1/18.
//

import UIKit
import Firebase

struct MyVariables {
    static var yourVariable = "0"
}

class All_Feeds_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var filter_button: UIButton!
    @IBOutlet weak var segemented_filters: UISegmentedControl!

    var feed_data: [[String:String]] = []
    var post_time = ""
    var search_text = ""
    var filter = "both"
    var ref: DatabaseReference! // Reference to database
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var selected_Post = 0
    var refreshControl: UIRefreshControl!
    var counter = 0
    @IBOutlet weak var filter_view: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
        spinner.isHidden = false
        
        filter_view.layer.cornerRadius = 10
        filter_view.clipsToBounds = true
        setWidthToSegmentControl(view: filter_view)
        // Used for dismissing keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        search_bar.addGestureRecognizer(tap)
        filter_button.addTarget(self, action: #selector(All_Feeds_ViewController.filter_pressed(_:)), for: .touchUpInside)
        let textFieldInsideSearchBar = search_bar.value(forKey: "searchField") as? UITextField
        let placeholderField = search_bar.value(forKey: "placeholder") as? UITextField
        segemented_filters.addTarget(self, action: #selector(segmented_control_changed), for: .valueChanged)

        placeholderField?.font = UIFont(name: "Apple SD Gothic Neo", size: (placeholderField?.font?.pointSize)!)
        textFieldInsideSearchBar!.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textFieldInsideSearchBar?.font = UIFont(name: "Apple SD Gothic Neo", size: (textFieldInsideSearchBar?.font?.pointSize)!)
        textFieldInsideSearchBar?.textColor = UIColor.black
        search_bar.layer.cornerRadius = 5
        search_bar.setImage(UIImage(named: "search"), for: UISearchBarIcon.search, state: .normal)
        table_view.dataSource = self
        table_view.delegate = self
        search_bar.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        table_view.addSubview(refreshControl!)
        do {
            try load_database()
            
        } catch {
            print("All_Feed: Load database error")
        }
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the search to resign the first responder status.
        search_bar.endEditing(true)
    }
    
    @objc func refreshData()
    {
        do {
            try load_database()
        } catch {
            print("All_Feed: Load database error")
        }
        
        reloadDuration()
        
        self.table_view.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("My Varaible is")
        print(MyVariables.yourVariable)
        if (MyVariables.yourVariable == "1") {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setRootViewController()
            MyVariables.yourVariable = "0"
        }
        
    }
    
    @objc func segmented_control_changed()
    {
        let filter_data = segemented_filters.selectedSegmentIndex
            
        switch (filter_data){
            case (0):
                self.filter = "event"
                self.refreshData()
                break
            case (1):
                self.filter = "announcement"
                self.refreshData()
                break
            case (2):
                self.filter = "both"
                self.refreshData()
                break
            default:
                break
            }
        filter_view.alpha = 0
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.feed_data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        spinner.stopAnimating()
        spinner.isHidden = true
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! All_Feed_TableViewCell
        cell.selectionStyle = .none // Allows the box selected to not have a grey outline
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.club_name.text = self.feed_data[indexPath.item]["Name"]
        cell.Subject.text = self.feed_data[indexPath.item]["Subject"]
        cell.time_duration.text = self.feed_data[indexPath.item]["Duration"]
        cell.image_view.layer.masksToBounds = true
        cell.image_view.layer.cornerRadius = CGFloat(roundf(Float(4)))
        if (self.feed_data[indexPath.item]["Type"]! == "Event"){
            cell.post_type_label.text = "Event"
            cell.post_type_label.font = UIFont(name: "Arial Rounded MT Bold", size: 18.0) // set fontName and Size
        } else {
            cell.post_type_label.text = "Announcement"
        }
       
        cell.backgroundColor = UIColor.white // make cell more visible in our example project
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.selected_Post = indexPath.item
        self.performSegue(withIdentifier: "post_page", sender: self)
    }
    
    func load_database() throws
    {
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
                    do {
                        try self.post_time = table_view_helper().timeDuration(date: self.feed_data[0]["Date"]!)
                    } catch {
                        print("Major Error In Date")
                    }
                    self.feed_data[0]["Duration"] = self.post_time
                }
            }
            
            self.table_view.reloadData()
        })
    }
    
    func reloadDuration(){
        if (feed_data.count == 0) {
            return
        }
        for index in 0...(feed_data.count - 1) {
            do {
                try post_time = table_view_helper().timeDuration(date: self.feed_data[index]["Date"]!)
            } catch {
                print("Major Error In Date")
            }
            self.feed_data[index]["Duration"] = post_time
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier != "back_to_it") {
            let navVC = segue.destination as? UINavigationController
            let real_dst = navVC?.viewControllers.first as! Post_PageViewController
            
            real_dst.receivedPostData = (self.feed_data[selected_Post]["Body"])!
            real_dst.receivedName = (self.feed_data[selected_Post]["Name"])!
            real_dst.receivedSubject = (self.feed_data[selected_Post]["Subject"])!
            real_dst.receivedDate = (self.feed_data[selected_Post]["Duration"])!
            real_dst.senderInfo = 0
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search_bar.resignFirstResponder()
        search_text = search_bar.text!
        self.refreshData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.placeholder = ""
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.placeholder = "Search"
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search_text = search_bar.text!
        if (search_text == "") {
            filter_button.alpha = 1
        }
        else {
            filter_button.alpha = 0
        }
        self.refreshData()
    }
    
    @objc func filter_pressed(_ sender: UIButton!) {
        if (filter_view.alpha == 1){
            filter_view.alpha = 0
            
            let filter_data = segemented_filters.selectedSegmentIndex
            
            switch (filter_data){
                case (0):
                    self.filter = "event"
                    self.refreshData()
                    break
                case (1):
                    self.filter = "announcement"
                    self.refreshData()
                    break
                case (2):
                    self.filter = "both"
                    self.refreshData()
                    break
            default:
                break
            }

        } else {
            filter_view.alpha = 1
        }
    }
    
    func setWidthToSegmentControl(view: UIView) {
        let subviews = view.subviews
        for subview in subviews {
            if subview is UILabel {
                let label: UILabel? = (subview as? UILabel)
                label?.adjustsFontSizeToFitWidth = true
                label?.minimumScaleFactor = 0.1
            }
            else {
                setWidthToSegmentControl(view: subview)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

