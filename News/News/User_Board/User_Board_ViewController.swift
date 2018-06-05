//
//  User_Board_ViewController.swift
//  News
//
//  Created by Ryan Lehman on 5/27/18.
//
/* Details:
 Provides the main view for the users to see all the flyers that
 have been posted using a collection view layout. The collection view uses a
 custom layout "gridlayout", storage and database references from firebase,
 a function to downstream the relevant images ("fetchImages"), and a button
 to allow a photo to be captured using a storyboard segue.
 */
import UIKit
import Firebase

class User_Board_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // Initializes instances and global varaibles
    
    @IBOutlet weak var collectionView: UICollectionView! // Creates a instance for the collection view
    var gridLayout: GridLayout = GridLayout(numberOfColumns: 3) // Creates an instance for the how the collection view will be organzied
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var picArray = [UIImage]() // Initlaizes an array to hold the images that will be later displayed onto the collection view
    var ref = Database.database().reference() // Reference to firebase database
    var storage2: Storage! // Reference to firebase storage server
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup after loading the view.
        storage2 = Storage.storage() // Initlaizes the storage server as a reference
        collectionView.collectionViewLayout = gridLayout // Sets the collection view layout to custom grid type
        collectionView.reloadData() // Reloads the database after the layout for the collection view has been set
        fetchImages() // Executres a function to downstream the valid images for the collection view to display
    }
    
    // Uses the firebase database refernece to find all valid download URL's and query them by time created.
    // Then places each download url into an array called "urlArray" to later be used for server calls.
    // A storage server refeenrce is made based on downloaded addresses and the image at each address is
    // downloaded and stored to be later displayed to the user.
    func fetchImages () {
        // Initializes local array
        var tempPics = [UIImage]() // Placeholder array to allow no duplicate images to be transferred over
        
        // Calls firebase database to query all the items in the directroy by time created
        self.ref.child("validatedFiles").queryOrdered(byChild: "time").observe(.value) { (snapshot) in
            let image_data = snapshot.value
            let url_data = image_data as? [String: [String: Any]]
            
            if (url_data?.count != nil) {
                // Loops through each snapshot in the directroy and extracts only the download URL to be
                // as a reference point for the storage server to loop up. The data at that addrress is
                // then downloaded to be stored in the image array while the collection view is updated and reloaded.
                for (data) in (url_data)! {
                    
                    // adds the download URL to the array
                    
                    if let datalink = (data.value["URL"])! as? String {
                        let storageRef = self.storage2.reference(forURL: datalink)
                        
                        // Download the data, assuming a max size of 3MB
                        storageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) -> Void in
                            if (error != nil){
                                print(error!)
                            } else {
                                // Create a UIImage, add it to the array
                                let pic = UIImage(data: data!)
                                tempPics.append(pic!)
                                self.picArray = tempPics
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    // Collection view function to show how many images to display based on the images downloaded from the storage server
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.picArray.count
    }
    
    // Collection view function to display the image at each cell based off of cell helper class
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! Flyer_CollectionViewCell
        cell.user_image.image = self.picArray[indexPath.item]
        return cell
    }
    
    // Collection view layout helper function, to allow the transiton into the custom layout to have a transition
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        gridLayout.invalidateLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
