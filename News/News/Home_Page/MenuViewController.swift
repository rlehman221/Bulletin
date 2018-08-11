//
//  MenuViewController.swift
//  News
//
//  Created by Ryan Lehman on 7/16/18.
//

import UIKit
import Firebase

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var table_view: UITableView!
    let reuseIdentifier = "cell"
    var ref: DatabaseReference! // Reference to database
    var isClub : String!
    var username : String!
    
    struct SectionObjects {
        var sectionLabel : String!
        var sectionObjects : [SectionRow]!
    }
    
    struct SectionRow {
        var cellLabel : String!
        var cellImage : UIImage!
    }
    
    // First index is for user profile and if they are club member
    var objectArray = [SectionObjects]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table_view.dataSource = self
        table_view.delegate = self
        initialize()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectArray[section].sectionObjects.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return objectArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return nil
        } else if (section == 1) {
            //return objectArray[section].sectionLabel
            return " "
        } else {
            return objectArray[section].sectionLabel
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MenuTableViewCell
        cell.label.text = objectArray[indexPath.section].sectionObjects[indexPath.row].cellLabel
        cell.Icon_Image.image = objectArray[indexPath.section].sectionObjects[indexPath.row].cellImage
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identifierLabel = objectArray[indexPath.section].sectionObjects[indexPath.row].cellLabel!
        
        if (identifierLabel == "Settings") {
            self.performSegue(withIdentifier: identifierLabel, sender: self)
        } else if (identifierLabel == "Subscriptions") {
            self.performSegue(withIdentifier: identifierLabel, sender: self)
        } else if (identifierLabel == "Logout") {
            signOut()
        } else if (identifierLabel == "Events") {
            print("Need to go to events")
        } else if (identifierLabel == "Feedback") {
            requestFeedback()
        }
    }
    
    func signOut() {
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "loginScreen", sender: self)
    }
    
    func requestFeedback(){
        let uuid = UUID().uuidString
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Feedback", message: "Please enter your feedback", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))")
            self.ref.child("Feedback").child(uuid).setValue(textField?.text) // Creates user with email and attaches all the clubs as false values
        }))
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        
        alert.addAction(cancelAction)
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func initialize() {
        
        isAdmin {
            
            self.getUser {
                var profileList = [SectionRow]()
                if (self.isClub != "None") {
                    profileList.append(SectionRow(cellLabel: self.username, cellImage: nil))
                    profileList.append(SectionRow(cellLabel: self.isClub, cellImage: nil))
                } else {
                    profileList.append(SectionRow(cellLabel: self.username, cellImage: nil))
                }
                self.objectArray.append(SectionObjects(sectionLabel: "Profile", sectionObjects: profileList))
                var otherList = [SectionRow]()
                otherList.append(SectionRow(cellLabel: "Events", cellImage: #imageLiteral(resourceName: "calendar")))
                otherList.append(SectionRow(cellLabel: "Subscriptions", cellImage: #imageLiteral(resourceName: "Subscriptions")))
                otherList.append(SectionRow(cellLabel: "Settings", cellImage: #imageLiteral(resourceName: "Shape")))
                otherList.append(SectionRow(cellLabel: "Feedback", cellImage: #imageLiteral(resourceName: "feedback")))
                otherList.append(SectionRow(cellLabel: "Logout", cellImage: #imageLiteral(resourceName: "logout_menu")))
                self.objectArray.append(SectionObjects(sectionLabel: "Other", sectionObjects: otherList))
                
                self.table_view.reloadData()
            }
        }
    }
    
    func getUser(finished: @escaping () -> Void) {
        ref = Database.database().reference()
        ref.child("Users").child((Auth.auth().currentUser?.uid)!).child("Name").observe(.value) { (snapshot) in
            
            if !snapshot.exists() { return }
            let data = snapshot.value as? String
            // This can be used to see if the user is allowed to see the posting screen "Plus" button at top end
            self.username = data
            finished()
        }
    }
    
    
    func isAdmin(finished: @escaping () -> Void) {
        ref = Database.database().reference()
        isClub = "None"
        ref.child("Users").child((Auth.auth().currentUser?.uid)!).child("Admin").observe(.value) { (snapshot) in
            
            if !snapshot.exists() { return }
            let data = snapshot.value as? [String:String]
            // This can be used to see if the user is allowed to see the posting screen "Plus" button at top end
            if (data!["Valid"]! == "true"){
                
                self.isClub = data!["Club"]!
            }
            finished()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
