//
//  Image_ViewController.swift
//  News
//
//  Created by Ryan Lehman on 5/29/18.
//
/* Details:
 Provides the user with the ablility to upload images to the storage server for validation
 and later to be pulled down on the bulletin board interface.
 - Uses the UIImagePicker to allow the users to pick images from their camera roll
 - Uses the "take_picture" function to execute the UIImagePicker screen
 - Allows for a "retake_image" function to have the user select the image again
 - Allows for a "send_image" function as a helper for uploading the image
 - Creates a "uploadImage" function to upload the selected image to the
 storage validation server while saving that address in the database
 */
import UIKit
import Firebase

class Image_ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Initializes instances and global varaibles
    
    var validTimePost = 1 // Variable to see if user has posted in the last 24 hours
    var storage2: Storage! // Reference to firebase storage server
    var ref = Database.database().reference() // Reference to firebase database
    @IBOutlet weak var user_image: UIImageView! // Storyboard reference for the selected user photo to appear as confirmation before uploading to storage server
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup after loading the view.
        storage2 = Storage.storage() // Initlaizes the storage server as a reference
        take_picture() // Executres a function to display the image picker screen to the user
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Creates a instance of an image picker screen to allow the user to
    // choose an image from their selected camera roll
    func take_picture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // Storyboard action button that is a helper method for uploading the image selected
    // by the user
    @IBAction func send_image(_ sender: Any) {
        uploadImage()
    }
    
    // Storyboard action button that is a helper method for displaying the camera roll again
    @IBAction func retake_image(_ sender: Any) {
        take_picture()
    }
    
    // Allows for the image picker to select the image they want from their camera roll.
    // If the image is selected correctly the photo is set on the user interface and the
    // function to upload the image to the server is called
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            user_image.image = selectedImage // Sets the interface UIImage to the choosen image in the camera roll
            uploadImage() // calls a higher order function to upload the image to the server
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Function that is called if the image picker is cancelled which will then
    // return the user to the bulletin board feed by a viewcontroller segue
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    
        if let vc = UIStoryboard(name: "User_Board", bundle: nil).instantiateViewController(withIdentifier: "secondBoard") as? User_Board_ViewController
        {
            self.present(vc, animated: true, completion: nil)
        }
        dismiss(animated: true, completion: nil)
    }
    
    /* Takes the image that was selected by the user and creates a PNG reference to it.
     The address for the image is then created using the current users UID. Before upload
     an UI alert is shown to confirm that the user wants to upload the image.
     The address is then stored in the validation storage server along with the image that
     was selected by the user. The url to this refernce is then also sent to the database to be
     stored for later down stream functionaloty. If the upload was successful a view controller
     segue is used to transfer the user back to the bulletin board feed.
    */
    func uploadImage(){
        
        // Generate intializre varibles for establishign both refernces and address's
        let uploadData = UIImagePNGRepresentation(self.user_image.image!)
        let uid = Auth.auth().currentUser?.uid
        let storageRef = storage2.reference().child("myFiles/\(uid!)")
        print("2Val is" + String(self.validTimePost))
        self.getUserLastPost {
            print("3Val is" + String(self.validTimePost))
            if (self.validTimePost == 0) {
                // Create a call to the storage server and have the image choosen uploaded along with the users UID as the address
                storageRef.putData(uploadData as! Data).observe(.success) { (snapshot) in
                    
                    // When the image has successfully uploaded, the download URL is taken to be stored in the database
                    storageRef.downloadURL(completion: { (URL, Error) in
                        
                        // if their is an error while the image is being uploaded then an alert is displayed to the user
                        if (Error != nil){
                            let fail_alert = UIAlertController(title: "Upload Has Failed", message: "please try uploading your photo again", preferredStyle: UIAlertControllerStyle.alert)
                            
                            // Add ok action to alert
                            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                                NSLog("Next Story Board")
                            }
                            
                            // Link to alert controller
                            fail_alert.addAction(okAction)
                            self.present(fail_alert, animated: true, completion: nil) // Display alert to the user
                            
                            // If the upload to the server and database were successful then alert the user of the confirmation and change view controllers
                        } else {
                            
                            let currentDate = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let finalDate = dateFormatter.string(from: currentDate)
                            
                            self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).child("Last Post").setValue(finalDate)
                            // Local varaible for the image refernce in string form
                            let downloadURL = URL?.absoluteString
                            
                            // Write the download URL to the Realtime Database along with a destingated timestamp
                            let data = ["URL": downloadURL, "time": ServerValue.timestamp()] as [String : Any]
                            self.ref.child("pendingFiles/\(uid!)").setValue(data)
                            
                            let success_alert = UIAlertController(title: "Upload Successful", message: "", preferredStyle: UIAlertControllerStyle.alert)
                            
                            // Add ok action
                            let okAction = UIAlertAction(title: "Great", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                                // The user will be re-directed the the bulletin board feed after image upload has been completed
                                
                                if let vc = UIStoryboard(name: "User_Board", bundle: nil).instantiateViewController(withIdentifier: "secondBoard") as? User_Board_ViewController
                                {
                                    self.present(vc, animated: true, completion: nil)
                                }
                            }
                            
                            // Link to alert controller
                            success_alert.addAction(okAction)
                            self.present(success_alert, animated: true, completion: nil) // Display alert to the user
                        }
                    })
                }
            } else {
                let fail_alert = UIAlertController(title: "Upload Has Failed", message: "Please wait 24 hours to post a new image", preferredStyle: UIAlertControllerStyle.alert)
                
                // Add ok action to alert
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    NSLog("Next Story Board")
                }
                
                // Link to alert controller
                fail_alert.addAction(okAction)
                self.present(fail_alert, animated: true, completion: nil) // Display alert to the user
            }
        }
        
    }
    
    func getUserLastPost (finished: @escaping () -> Void) {
        let uid = Auth.auth().currentUser?.uid
   
        ref.child("Users").child(uid!).child("Last Post").observe(.value) { (snapshot) in
            var ret = 1
            var lastPost = snapshot.value! as! String
            ret = self.checkLastPostDate(date: lastPost)
            self.validTimePost = ret
            print("1Val is" + String(self.validTimePost))
            finished()
        }
    }
    
    // Returns 0 if successful
    func checkLastPostDate (date: String) -> Int {
        // Get the current Date and Time
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let finalDate = dateFormatter.string(from: currentDate)
        
        if (date == "0"){
            return 0
        } else {
            let compareDateString = date
            let compareDate2 = dateFormatter.date(from:compareDateString)
            let timeComponents: Set = [Calendar.Component.month,Calendar.Component.day,Calendar.Component.hour, Calendar.Component.minute]
            var time_interval = NSCalendar.current.dateComponents(timeComponents, from: compareDate2!, to: currentDate)
            print(time_interval.day!)
            if (time_interval.day! >= 1){
                return 0
            } else {
                return 1
            }
        }
    }
}
