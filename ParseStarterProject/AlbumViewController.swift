//
//  albumViewController.swift
//  ParseStarterProject
//
//  Created by Jonathan Arlauskas on 2015-06-01.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MobileCoreServices
import AssetsLibrary
import Foundation
import Photos
import MessageUI
import AVFoundation
import DigitsKit

let reuseIdentifier = "albumCell"

class AlbumViewController: UICollectionViewController,UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate,BFCImagePickerControllerDelegate {
    
    var refresher: UIRefreshControl!
    
    
    //------------------Camera Att.-----------------
    var loopAllImagesBool = false
    @IBOutlet weak var thumbnailButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    var testCamera = UIImagePickerController()
    
    var imageViewContent = UIImage()
    var overlayView: UIView?
    var image = UIImage()
    var picker = UIImagePickerController()
    var zoomImage = (camera: true, display: true)
    var newMedia: Bool = true
    
    // Title and ID of event passed from previous VC, based on selected row
    var eventId : String?
    var eventTitle: String?
    
    // Keeps track of photo source and only downloads newly taken images
    var downloadToCameraRoll = true
    
    var spinner : UIActivityIndicatorView = UIActivityIndicatorView()
    
    // Variable for storing PFFile as image, pass through segue
    var images = [UIImage]()
    var postLogo = UIImage(named: "liked.png") as UIImage!
    var goBack = UIImage(named: "back") as UIImage!
    var share = UIImage(named: "share-icon") as UIImage!
    var cam = UIImage(named:"goto-camera") as UIImage!
    var newCam = UIImage(named:"goto-camera-full") as UIImage!
    
    var flashOff = UIImage(named:"flash-icon-large") as UIImage!
    var flashOn = UIImage(named:"flashon-icon-large") as UIImage!
    
    // Arrays of image files full size
    var timesImages = [UIImage]()
    var likeImages = [UIImage]()
    var myImages = [UIImage]()
    
    
    // Tuple for sorting
    var imageFilesTemp : [(image: PFFile , likes: Int , id: String,date: NSDate)] = []
    
    // Arrays for like sort selected
    var imageFilesLikes = [PFFile]()
    var objectIdLikes = [String]()
    var datesLikes = [NSDate]()
    
    // Arrays for time sort selected
    var imageFilesTime = [PFFile]()
    var objectIdTime = [String]()
    var datesTime = [NSDate]()
    
    //Arrays for when my photos is selected
    var myPhotos = [PFFile]()
    var myObjectId = [String]()
    var myDate = [NSDate]()
    
    // Checker for sort button. Sort in chronological order by default.
    var sortedByLikes = true
    var myPhotoSelected = false
    var fullScreen = false
    var posted = false
    
    // Display alert function for when an album timer is going to run out
    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayNoInternetAlert() {
        var alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to the internet to log in.")
        self.presentViewController(alert, animated: true, completion: nil)
        println("no internet")
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewChanger (sender: UISegmentedControl) {
        
        if NetworkAvailable.networkConnection() == true {
            switch sender.selectedSegmentIndex {
                
                // Rating Sort
            case 0 :    sortedByLikes = true
            myPhotoSelected = false
            updatePhotos()
                
                // Time Sort
            case 1:     sortedByLikes = false
            myPhotoSelected = false
            updatePhotos()
                
                
                
                // My Photos
            case 2 :    myPhotoSelected = true
            displayMyPhotos()
                
                
                
            default:
                println("default")
                
            }
        } else {
            
            var alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to internet to access content.")
            self.presentViewController(alert, animated: true, completion: nil)
            println("no internet")
            
        }
    }
    
    // Occurs for when a user adds a photo, we want the photo to show up instantly
    override func viewDidAppear(animated: Bool) {
        
        
        if NetworkAvailable.networkConnection() == true {
            // fullscreen is false, posted is true
            if posted == true {
                
                //let qos = (Int(QOS_CLASS_BACKGROUND.value))
                
                if myPhotoSelected == false {
                    //dispatch_async(dispatch_get_global_queue(qos, 0)) {
                    self.updatePhotos()
                    //}
                    
                } else {
                    //dispatch_async(dispatch_get_global_queue(qos,0)) {
                    self.displayMyPhotos()
                    //}
                    
                    
                }
                
                //self.collectionView?.reloadData()
            }
        } else {
            
            var alert = NetworkAvailable.networkAlert("Error", error: "Connect to internet to access content")
            self.presentViewController(alert, animated: true, completion: nil)
            println("no internet")
            
        }
        
    }
    
    // Segway back to event history page
    func seg() {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    
    func smsShare() {
        
        var user = "filler"
        if (PFUser.currentUser() != nil) {
            user = PFUser.currentUser()!.objectId!
        }
        var params = [ "referringUsername": "\(user)", "referringOut": "AVC", "eventId":"\(self.eventId!)", "eventTitle": "\(self.eventTitle!)"]
        
        Branch.getInstance().getShortURLWithParams(params, andChannel: "SMS", andFeature: "Referral", andCallback: { (url: String!, error: NSError!) -> Void in
            if (error == nil) {
                if MFMessageComposeViewController.canSendText() {
                    
                    let messageComposer = MFMessageComposeViewController()
                    
                    messageComposer.body = String(format: "Check out these photos on Backflip! %@", url)
                    
                    messageComposer.messageComposeDelegate = self
                    
                    self.presentViewController(messageComposer, animated: true, completion:{(Bool) in
                    })
                } else {
                    
                    var alert = UIAlertController(title: "Error", message: "Your device does not allow sending SMS or iMessages.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Pull down to refresh
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView!.addSubview(refresher)
        self.collectionView?.alwaysBounceVertical = true
        
        spinner.frame = CGRectMake(0.0, 0.0, 50.0, 50.0)
        spinner.center = self.view.center
        spinner.hidden = false
        self.view.addSubview(spinner)
        self.view.bringSubviewToFront(spinner)
        
        spinner.startAnimating()
        
        
        
        // Initial load of images
        if NetworkAvailable.networkConnection() == true {
            // fullscreen is false, posted is true
            if fullScreen == false || posted == true {
                
                //let qos = (Int(QOS_CLASS_BACKGROUND.value))
                
                if myPhotoSelected == false {
                    //dispatch_async(dispatch_get_global_queue(qos, 0)) {
                    
                    //dispatch_async(dispatch_get_main_queue()) {
                    
                    
                    //}
                    self.updatePhotos()
                    
                    //}
                    
                } else {
                    //dispatch_async(dispatch_get_global_queue(qos,0)) {
                    self.displayMyPhotos()
                    //}
                    //dispatch_async(dispatch_get_main_queue()) {
                    
                    //}
                    
                }
                
                //self.collectionView?.reloadData()
            }
        } else {
            
            var alert = NetworkAvailable.networkAlert("Error", error: "Connect to internet to access content")
            self.presentViewController(alert, animated: true, completion: nil)
            println("no internet")
            
        }
        
        // Booleans for determining if view needs to be reloaded
        self.fullScreen = false
        self.posted = false
        
        //--------------- LIKE/TIME/MY PHOTOS ---------------
        
        // Initialize segmented control button
        let items = ["SORT BY LIKES", "SORT BY TIME", "MY PHOTOS"]
        let segC = UISegmentedControl(items: items)
        
        // Persistence of segmented control selection
        if sortedByLikes == true && myPhotoSelected == false {
            
            segC.selectedSegmentIndex = 0
            
        }
        
        if sortedByLikes == false && myPhotoSelected == false {
            
            segC.selectedSegmentIndex = 1
            
        }
        
        if myPhotoSelected == true  {
            
            segC.selectedSegmentIndex = 2
            
        }
        
        // Defines where seg control is positioned
        let frame: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = frame.width
        let screenHeight = frame.height
        var superCenter = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds))
        segC.frame = CGRectMake(CGRectGetMinX(frame),64,screenWidth,30)
        
        // Set characteristics of segmented controller
        var backColor : UIColor = UIColor(red: 114/255, green: 114/255, blue: 114/255, alpha: 1)
        var titleFont : UIFont = UIFont(name: "Avenir", size: 12.0)!
        
        // Implement base colors on our segmented control
        segC.tintColor = UIColor.clearColor()
        
        // Attributes for non selected segments
        var segAttributes = [
            
            NSForegroundColorAttributeName : backColor,
            
            NSFontAttributeName : titleFont,
            
        ]
        
        // Attributes for when segment is selected
        var underline  =  NSUnderlineStyle.StyleSingle.rawValue
        var underlineColor : UIColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        
        var segAttributes1 = [
            
            NSForegroundColorAttributeName : backColor,
            
            NSFontAttributeName : titleFont,
            
            NSUnderlineStyleAttributeName : underline,
            
            NSUnderlineColorAttributeName : underlineColor
            
        ]
        
        // Implement the above attributes on our segmented control
        segC.setTitleTextAttributes(segAttributes as [NSObject:AnyObject],forState: UIControlState.Normal)
        segC.setTitleTextAttributes(segAttributes1 as [NSObject:AnyObject], forState: UIControlState.Selected)
        
        // Add targets, initialize segmented control
        segC.addTarget(self, action: "viewChanger:", forControlEvents: .ValueChanged)
        
        //--------------- Draw UI ---------------
        
        // Hide UI controller item
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Nav Bar positioning
        let navBar = UINavigationBar(frame: CGRectMake(0,0,self.view.frame.size.width, 94))
        navBar.backgroundColor =  UIColor.whiteColor()
        
        // Set the Nav bar properties
        let navBarItem = UINavigationItem()
        
        navBarItem.title = eventTitle
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Avenir-Medium",size: 18)!]
        let verticalOffset: CGFloat = -30
        navBar.setTitleVerticalPositionAdjustment(verticalOffset, forBarMetrics: .Default)
        navBar.items = [navBarItem]
        
        // Left nav bar button item
        let back = UIButton.buttonWithType(.System) as! UIButton
        back.setImage(goBack, forState: .Normal)
        back.tintColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        back.frame = CGRectMake(-10, 20, 72, 44)
        back.addTarget(self, action: "seg", forControlEvents: .TouchUpInside)
        navBar.addSubview(back)
        
        // Right nav bar button item
        let shareAlbum = UIButton.buttonWithType(.System) as! UIButton
        shareAlbum.setImage(share, forState: .Normal)
        shareAlbum.tintColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        shareAlbum.frame = CGRectMake(self.view.frame.size.width-62, 20, 72, 44)
        shareAlbum.addTarget(self, action: "smsShare", forControlEvents: .TouchUpInside)
        navBar.addSubview(shareAlbum)
        
        navBar.addSubview(segC)
        self.view.addSubview(navBar)
        
        // Post photo button new
        let postPhoto = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        postPhoto.setImage(cam, forState: .Normal)
        postPhoto.frame = CGRectMake(0, self.view.frame.size.height-55, self.view.frame.size.width, 75)
        postPhoto.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        postPhoto.addTarget(self, action: "takePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(postPhoto)
        
        // Set VC color
        self.collectionView!.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        // Pushes collection view down, higher value pushes collection view downwards, and push from bottom of screen (3rd number)
        collectionView?.contentInset = UIEdgeInsetsMake(94.0,0.0,80.0,0.0)
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        if NetworkAvailable.networkConnection() == true {
            // Initialize date comparison components
            let currentTime = NSDate()
            let cal = NSCalendar.currentCalendar()
            let components = NSDateComponents()
            components.hour = 48
            let components2 = NSDateComponents()
            components2.hour = 24
            var eventQuery = PFQuery(className: "Event")
            
            eventQuery.selectKeys(["endTime"])
            
            eventQuery.getObjectInBackgroundWithId(eventId!){ (objects, error) -> Void in
                if error == nil {
                    if let endTime: AnyObject = objects?.objectForKey("endTime") {
                        //endDate has been set and is valid
                        
                        //TODO: determine how this can be set automatically
                        let endTime = objects?.objectForKey("endTime") as! NSDate
                        
                        //date is the end time of event plus 48hours
                        let date = cal.dateByAddingComponents(components, toDate: endTime, options: NSCalendarOptions.allZeros)
                        
                        // Event is still active (currentTime < expiry time)
                        if currentTime.compare(date!) == NSComparisonResult.OrderedAscending {
                            
                            // Event is no longer active (currentTime > expiry time)
                        } else if currentTime.compare(date!) == NSComparisonResult.OrderedDescending {
                            
                        }
                        
                    } else {
                        //endDate has not been set or was invalid
                    }
                    
                    
                } else {
                    
                    println(error)
                    
                }
            }
        } else {
            displayNoInternetAlert()
        }
    }
    
    func refresh(sender: AnyObject) {
        
        if NetworkAvailable.networkConnection() == true {
            if myPhotoSelected == false {
                
                updatePhotos()
                self.refresher.endRefreshing()
                
            } else {
                
                displayMyPhotos()
                self.refresher.endRefreshing()
            }
            
        } else {
            displayNoInternetAlert()
            self.refresher.endRefreshing()
        }
        
    }
    
    
    func displayMyPhotos() {
        
        
        // Clean the arrays for use again
        self.imageFilesTemp.removeAll(keepCapacity: true)
        
        self.myPhotos.removeAll(keepCapacity: true)
        self.myObjectId.removeAll(keepCapacity: true)
        
        self.imageFilesLikes.removeAll(keepCapacity: true)
        self.objectIdLikes.removeAll(keepCapacity: true)
        self.datesLikes.removeAll(keepCapacity: true)
        
        self.imageFilesTime.removeAll(keepCapacity: true)
        self.objectIdTime.removeAll(keepCapacity: true)
        self.datesTime.removeAll(keepCapacity: true)
        
        self.images.removeAll(keepCapacity: true)
        
        let qos = (Int(QOS_CLASS_USER_INITIATED.value))
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            
            // Load information from parse db -- purely for flag checking
            var getUploadedImages = PFQuery(className: "Event")
            getUploadedImages.limit = 1
            getUploadedImages.selectKeys(["photos"])
            getUploadedImages.whereKey("objectId", equalTo: self.eventId!)
            
            // Retrieval from corresponding photos from relation to event
            var eventNames = getUploadedImages.findObjects() //as! PFObject
            
            if (eventNames == nil || eventNames!.count == 0) {
                
                println("error")
                
            } else {
                
                var object = eventNames!.first as! PFObject
                var photos = object["photos"] as! PFRelation
                var photoList = photos.query()!.findObjects()
                
                if (photoList == nil || photoList!.count == 0) {
                    
                    println("no photos")
                    
                } else {
                    
                    // End flag checking load
                    
                    var query = PFQuery(className: "EventAttendance")
                    query.whereKey("attendeeID", equalTo: PFUser.currentUser()!.objectId!)
                    query.whereKey("eventID", equalTo: self.eventId!)
                    query.selectKeys(["photosLiked", "photosLikedID", "flagged", "blocked"])
                    
                    var queryResult = query.findObjects()
                    dispatch_async(dispatch_get_main_queue()) {
                        if (queryResult == nil || queryResult!.count == 0) {
                            
                            println("no photos")
                            
                        } else {
                            
                            
                            //TODO: Check if this is an actual issue when events & users are properly linked up
                            if (queryResult!.count != 0) {
                                println(queryResult!.count)
                                var eventAttendance = queryResult!.first as! PFObject
                                
                                var pList = eventAttendance["photosLiked"] as! [PFFile]
                                var ids = eventAttendance["photosLikedID"] as! [String]
                                
                                
                                // STRANGE BEHAVIOUR : Keep this in mind, when myPhotos was 0, would not enter the for loop until a photo was liked
                                if pList.count == 0 {
                                    
                                    self.collectionView?.reloadData()
                                    self.myPhotos = []
                                    self.myObjectId = []
                                }
                                
                                println("COUNT")
                                println(pList.count)
                                
                                var index = 0
                                for photo in pList {
                                    // Ensure the image wasn't flagged or blocked
                                    // TODO: Look into this temp fix for array out of bounds issue with flagged photos
                                    if (index < ids.count) {
                                        var id = ids[index]
                                        var hidden = false
                                        for p in photoList! {
                                            if (p.objectId == ids[index] && ((p["flagged"] as! Bool) == true || (p["blocked"] as! Bool) == true)) {
                                                hidden = true
                                            }
                                        }
                                        
                                        if (!hidden) {
                                            
                                            self.collectionView?.reloadData()
                                            self.myPhotos.append(photo)
                                            self.myObjectId.append(ids[index])
                                            
                                        }
                                    }
                                    
                                    index++
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // TODO: Smart loading of photos - only reload photos which are new/were modified
    func updatePhotos() {
        
        
        // Clean all our arrays for use again
        self.imageFilesTemp.removeAll(keepCapacity: true)
        
        self.myPhotos.removeAll(keepCapacity: true)
        self.myObjectId.removeAll(keepCapacity: true)
        
        
        self.imageFilesLikes.removeAll(keepCapacity: true)
        self.objectIdLikes.removeAll(keepCapacity: true)
        self.datesLikes.removeAll(keepCapacity: true)
        
        self.imageFilesTime.removeAll(keepCapacity: true)
        self.objectIdTime.removeAll(keepCapacity: true)
        self.datesTime.removeAll(keepCapacity: true)
        
        self.images.removeAll(keepCapacity: true)
        
        let qos = (Int(QOS_CLASS_USER_INITIATED.value))
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            
            // Load information from parse db
            var getUploadedImages = PFQuery(className: "Event")
            getUploadedImages.limit = 1
            getUploadedImages.selectKeys(["photos"])
            getUploadedImages.whereKey("objectId", equalTo: self.eventId!)
            
            // Retrieval from corresponding photos from relation to event
            //var eventArray = getUploadedImages.findObjects()
            var eventArray: Void = getUploadedImages.findObjectsInBackgroundWithBlock { (eventArObjs:[AnyObject]?, error:NSError?) -> Void in
                
                if (eventArObjs == nil || eventArObjs!.count == 0) {
                    
                    println("No Photos/No Updates")
                    
                } else {
                    var object = eventArObjs!.first as! PFObject
                    var photos = object["photos"] as! PFRelation
                    
                    var photoListQuery = photos.query()!
                    photoListQuery.limit = 300
                    
                    //var photoList = photos.query()!.findObjects()
                    var photoList: Void = photoListQuery.findObjectsInBackgroundWithBlock({ (photoObjs:[AnyObject]?, error:NSError?) -> Void in
                        
                        if (photoObjs == nil || photoObjs!.count == 0) {
                            
                            println("no photos")
                            
                        } else {
                            
                            for photo in photoObjs! {
                                
                                // Ensure the image wasn't flagged or blocked
                                if ((photo["flagged"] as! Bool) == false && (photo["blocked"] as! Bool) == false) {
                                    // Fill our array of tuples for sorting
                                    let tup = (image: photo["thumbnail"] as! PFFile, likes: photo["upvoteCount"] as! Int, id: photo.objectId!! as String,date: photo.createdAt!! as NSDate)
                                    
                                    self.imageFilesTemp.append(tup)
                                }
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.collectionView?.reloadData()
                                
                                // Sort tuple of images by likes, and fill new array with photos in order of likes
                                self.imageFilesTemp.sort{ $0.likes > $1.likes}
                                
                                for (image, likes, id, date) in self.imageFilesTemp {
                                    
                                    self.imageFilesLikes.append(image)
                                    self.objectIdLikes.append(id)
                                    self.datesLikes.append(date)
                                    
                                }
                                
                                // Sort tuple of images, fill the array with photos in order of time
                                self.imageFilesTemp.sort{ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending}
                                
                                for (image, likes, id, date) in self.imageFilesTemp {
                                    
                                    self.imageFilesTime.append(image)
                                    self.objectIdTime.append(id)
                                    self.datesTime.append(date)
                                    
                                }
                            }
                        }
                    })
                }
            }
        }
        self.spinner.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.images.removeAll(keepCapacity: true)
        
        self.collectionView?.reloadData()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        
        if sortedByLikes == true && myPhotoSelected == false {
            
            return imageFilesTime.count
            
        } else if sortedByLikes == false && myPhotoSelected == false{
            
            return imageFilesLikes.count
            
        } else {
            
            // Returns the count of cells, which may be less or more, depending on myphotos array
            return myPhotos.count
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let albumCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AlbumViewCell
        
        // Image view is of type PFImageView, allows parse to do the loading of the files in the cells
        
        if sortedByLikes == false && myPhotoSelected == false {
            
            if imageFilesTime.count == 0 {
                
                println("No Photos/No Update")
                
            } else {
                
                // Temp image until actual image loads CAUSES MEMORY WARNING ON MANY REFRESH
                albumCell.imageView.image = UIImage(contentsOfFile: "backfliplogo80.png")
                
                albumCell.imageView.file = imageFilesTime[indexPath.row]
                albumCell.imageView.loadInBackground()
                
            }
            
        } else if sortedByLikes == true && myPhotoSelected == false {
            
            if imageFilesLikes.count == 0 {
                
                println("No Photos/No Update")
                
            } else {
                
                
                // Temp image until actual image loads
                albumCell.imageView.image = UIImage(contentsOfFile: "backfliplogo80.png")
                
                albumCell.imageView.file = imageFilesLikes[indexPath.row]
                albumCell.imageView.loadInBackground()
                
                
                
            }
            
        } else if myPhotoSelected == true {
            
            if myPhotos.count == 0 {
                
                println("No Photos/No Update")
                // TODO: Check if necessary
                // albumCell.imageView.image = nil
                
                
            } else {
                
                // Temp image until actual image loads
                albumCell.imageView.image = UIImage(contentsOfFile: "backfliplogo80.png")
                
                albumCell.imageView.file = myPhotos[indexPath.row]
                albumCell.imageView.loadInBackground()
            }
        }
        
        albumCell.layer.shouldRasterize = true
        albumCell.layer.rasterizationScale = UIScreen.mainScreen().scale
        return albumCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if NetworkAvailable.networkConnection() == true {
            if segue.identifier == "toFull" {
                
                var moveVC: FullScreenViewController = segue.destinationViewController as! FullScreenViewController
                var selectedCellIndex = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell)
                moveVC.eventId = eventId!
                moveVC.eventTitle = eventTitle!
                fullScreen = true
                
                // Sorted by time (from newest to oldest)
                if self.sortedByLikes == false && self.myPhotoSelected == false {
                    if self.objectIdTime.count == 0 || self.datesTime.count == 0 {
                        displayNoInternetAlert()
                    } else {
                        moveVC.tempArray = objectIdTime
                        moveVC.tempDate = self.datesTime[selectedCellIndex!.row]
                        moveVC.selectedIndex = selectedCellIndex!.row
                    }
                    
                } else if self.sortedByLikes == true && self.myPhotoSelected == false {
                    // Sorted by like count
                    if self.objectIdLikes.count == 0 || self.datesLikes.count == 0 {
                        displayNoInternetAlert()
                    } else {
                        
                        moveVC.tempArray = objectIdLikes
                        moveVC.tempDate = self.datesLikes[selectedCellIndex!.row]
                        moveVC.selectedIndex = selectedCellIndex!.row
                        
                    }
                } else {
                    
                    if self.myObjectId.count == 0 {
                        displayNoInternetAlert()
                    } else {
                        
                        moveVC.tempArray = myObjectId
                        //moveVC.tempDate = self.datesLikes[selectedCellIndex!.row]
                        moveVC.selectedIndex = selectedCellIndex!.row
                    }
                }
            }
        } else {
            displayNoInternetAlert()
        }
    }
    
    //--------------- Camera ---------------
    //initialize camera
    func takePhoto(sender: UIButton) {
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "capture:", name:  "AVSystemController_SystemVolumeDidChangeNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "capture:", name: "_UIApplicationVolumeUpButtonDownNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "capture:", name: "_UIApplicationVolumeDownButtonDownNotification", object: nil)
        if NetworkAvailable.networkConnection() == true {
            let query = PFUser.query()
            query?.selectKeys(["blocked"])
            query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                if error == nil {
                    if (object!.valueForKey("blocked") as! Bool) {
                        PFUser.logOut()
                        Digits.sharedInstance().logOut()
                        self.performSegueWithIdentifier("logOutBlocked", sender: self)
                    } else {
                        self.fullScreen = false
                        self.posted = true
                        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                            println("Button capture")
                            
                            //primary delegate for the picker
                            self.picker.delegate = self
                            
                            self.picker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                            self.picker.sourceType = .Camera
                            self.picker.mediaTypes = [kUTTypeImage]
                            self.picker.allowsEditing = false
                            self.picker.cameraViewTransform = CGAffineTransformMakeTranslation(0.0, 71.0)
                            self.picker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0, 71.0), 1.333333, 1.333333)
                            // resize
                            if (self.zoomImage.camera) {
                                var screenBounds: CGSize = UIScreen.mainScreen().bounds.size
                                var cameraAspectRatio: CGFloat = 4.0/3.0
                                var cameraViewHeight = screenBounds.width * cameraAspectRatio
                                var scale = screenBounds.height / cameraViewHeight
                                self.picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - cameraViewHeight) / 2.0)
                                self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, scale, scale)
                                self.zoomImage.camera = false
                            }
                            
                            // custom camera overlayview
                            self.picker.showsCameraControls = false
                            NSBundle.mainBundle().loadNibNamed("OverlayView", owner:self, options:nil)
                            self.overlayView!.frame = self.picker.cameraOverlayView!.frame
                            self.picker.cameraOverlayView = self.overlayView
                            self.overlayView = nil
                            
                            self.presentViewController(self.picker, animated:true, completion:{})
                            self.setLastPhoto()
                            self.updateThumbnail()
                            self.newMedia = true
                        } else {
                            if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
                                var picker = UIImagePickerController()
                                picker.delegate = self;
                                picker.sourceType = .PhotoLibrary
                                picker.mediaTypes = [kUTTypeImage]
                                picker.allowsEditing = false
                                
                                self.presentViewController(picker, animated:true, completion:{})
                                
                                self.newMedia = false
                                self.setLastPhoto()
                                self.updateThumbnail()
                            }
                        }
                        
                        self.testCalled()
                        
                        self.setLastPhoto()
                        self.updateThumbnail()
                        
                        
                    }
                } else {
                    
                    println(error)
                }
            })
        } else {
            displayNoInternetAlert()
        }
    }
    
    func imageFixOrientation(img:UIImage) -> UIImage {
        
        if (img.imageOrientation == UIImageOrientation.Up) {
            return img;
        }
        
        var transform:CGAffineTransform = CGAffineTransformIdentity
        
        if (img.imageOrientation == UIImageOrientation.Down
            || img.imageOrientation == UIImageOrientation.DownMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.width, img.size.height)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        }
        
        if (img.imageOrientation == UIImageOrientation.Left
            || img.imageOrientation == UIImageOrientation.LeftMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.width, 0)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        }
        
        if (img.imageOrientation == UIImageOrientation.Right
            || img.imageOrientation == UIImageOrientation.RightMirrored) {
                
                transform = CGAffineTransformTranslate(transform, 0, img.size.height);
                transform = CGAffineTransformRotate(transform,  CGFloat(-M_PI_2));
        }
        
        if (img.imageOrientation == UIImageOrientation.UpMirrored
            || img.imageOrientation == UIImageOrientation.DownMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.width, 0)
                transform = CGAffineTransformScale(transform, -1, 1)
        }
        
        if (img.imageOrientation == UIImageOrientation.LeftMirrored
            || img.imageOrientation == UIImageOrientation.RightMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.height, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
        }
        
        var ctx:CGContextRef = CGBitmapContextCreate(nil, Int(img.size.width), Int(img.size.height), CGImageGetBitsPerComponent(img.CGImage), 0, CGImageGetColorSpace(img.CGImage), CGImageGetBitmapInfo(img.CGImage))
        
        CGContextConcatCTM(ctx, transform)
        
        if (img.imageOrientation == UIImageOrientation.Left
            || img.imageOrientation == UIImageOrientation.LeftMirrored
            || img.imageOrientation == UIImageOrientation.Right
            || img.imageOrientation == UIImageOrientation.RightMirrored
            ) {
                
                CGContextDrawImage(ctx, CGRectMake(0,0,img.size.height,img.size.width), img.CGImage)
        } else {
            CGContextDrawImage(ctx, CGRectMake(0,0,img.size.width,img.size.height), img.CGImage)
        }
        
        var cgimg:CGImageRef = CGBitmapContextCreateImage(ctx)
        var imgEnd:UIImage = UIImage(CGImage: cgimg)!
        
        return imgEnd
    }
    
    func saveImageAlert()
    {
        var alert:UIAlertView = UIAlertView()
        alert.title = "Saved!"
        alert.message = "Saved to Camera Roll"
        alert.delegate = self
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    @IBAction func loadFromLibrary(sender: AnyObject) {
        var picker = UIImagePickerController()
        picker.sourceType =
            UIImagePickerControllerSourceType.SavedPhotosAlbum
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        //image stored in local variable to contain lifespan in method
        var imageShortLife:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imageViewContent = imageShortLife
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        //Retake and crop options------------------------------------------------------------------------
        let previewViewController = PreviewViewController(nibName: "PreviewViewController", bundle: nil);
        previewViewController.cropCompletionHandler = {
            self.imageViewContent = $0!
            previewViewController.dismissViewControllerAnimated(true, completion: nil)
        }
        previewViewController.cancelCompletionHandler = {
            //retake image
            
            self.presentViewController(picker, animated:true, completion:{})
            self.setLastPhoto()
            self.updateThumbnail()
            self.flashButton.hidden = false
            self.setLastPhoto()
            self.updateThumbnail()
            
        }
        
        if self.picker.cameraDevice == UIImagePickerControllerCameraDevice.Front{
            previewViewController.imageToCrop = imageViewContent
            //UIImage(CGImage: imageViewContent.CGImage, scale: 1.0, orientation: .LeftMirrored)
            //UIImage(CGImage: initialImage.CGImage, scale: 1, orientation: initialImage.imageOrientation)!
        }
        else{
            previewViewController.imageToCrop = imageViewContent
        }
        
        previewViewController.eventId = self.eventId
        previewViewController.eventTitle = self.eventTitle
        previewViewController.downloadToCameraRoll = downloadToCameraRoll
        
        self.presentViewController(previewViewController, animated: true, completion: nil);
        setLastPhoto()
        updateThumbnail()
        
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage)!
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)!
        
        return image
    }
    
    func testCalled()
    {
        
        let sourceType = UIImagePickerControllerSourceType.Camera
        if (!UIImagePickerController.isSourceTypeAvailable(sourceType))
        {
            var alert:UIAlertView = UIAlertView()
            alert.title = "Cannot access camera!"
            alert.message = " "
            alert.delegate = self
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        
        let frontCamera = UIImagePickerControllerCameraDevice.Front
        let rearCamera = UIImagePickerControllerCameraDevice.Rear
        if (!UIImagePickerController.isCameraDeviceAvailable(frontCamera))
        {
            var alert:UIAlertView = UIAlertView()
            alert.title = "Cannot access front-facing camera!"
            alert.message = " "
            alert.delegate = self
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        if (!UIImagePickerController.isCameraDeviceAvailable(rearCamera))
        {
            var alert:UIAlertView = UIAlertView()
            alert.title = "Cannot access rear-facing camera!"
            alert.message = " "
            alert.delegate = self
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        
        var status : AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if (status == AVAuthorizationStatus.Authorized) {
            println("authorized")
        } else if(status == AVAuthorizationStatus.Denied){
            var alert:UIAlertView = UIAlertView()
            alert.title = "Camera Disabled"
            alert.message = "Please enable camera access in the iOS settings for Backflip or upload from your camera roll."
            alert.delegate = self
            alert.addButtonWithTitle("Ok")
            alert.show()
        } else if(status == AVAuthorizationStatus.Restricted){
            var alert:UIAlertView = UIAlertView()
            alert.title = "Camera Disabled"
            alert.message = "Please enable camera access in the iOS settings for Backflip or upload from your camera roll."
            alert.delegate = self
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
    
    @IBAction func reverseCamera(sender: UIButton) {
        //TO-DO: add transition when reversed
        if self.picker.cameraDevice == UIImagePickerControllerCameraDevice.Front{
            
            var screenBounds: CGSize = UIScreen.mainScreen().bounds.size
            var cameraAspectRatio: CGFloat = 4.0/3.0
            var cameraViewHeight = screenBounds.width * cameraAspectRatio
            var scale = screenBounds.height / cameraViewHeight
            picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - cameraViewHeight) / 2.0)
            picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale)
            self.zoomImage.camera = false
            
            
            UIView.transitionWithView(self.picker.view, duration: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.TransitionFlipFromLeft , animations: { () -> Void in
                self.picker.cameraDevice = UIImagePickerControllerCameraDevice.Rear
                }, completion: nil)
            
            self.flashButton.hidden = false
        }else{
            
            //----------------------------------------------------------------------------
            self.picker.cameraViewTransform = CGAffineTransformMakeTranslation(0.0, -5.0)
            self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, 1.0, 1.0)
            
            // resize
            if (zoomImage.camera) {
                self.zoomImage.camera = false
            }
            //----------------------------------------------------------------------------
            
            UIView.transitionWithView(self.picker.view, duration: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.TransitionFlipFromRight , animations: { () -> Void in
                self.picker.cameraDevice = UIImagePickerControllerCameraDevice.Front
                }, completion: nil)
            
            self.flashButton.hidden = true
        }
    }
    
    @IBAction func showCameraRoll(sender: UIButton) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
//        downloadToCameraRoll = false
//        
//        var controller = UIImagePickerController()
//        controller.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
//        controller.mediaTypes = [kUTTypeImage]
//        controller.delegate = self
//        self.presentViewController(controller, animated:true, completion:nil)
        
        let pickerController = BFCImagePickerController()
        pickerController.pickerDelegate = self
        self.presentViewController(pickerController, animated: true) {}
    }
    
    //********call back functions for ^^^^**********
    func imagePickerControllerDidSelectedAssets(assets: [BFCAsset]!) {
        //Send assets to parse
        for (index, asset) in enumerate(assets) {
            let imageView = UIImageView(image: asset.fullResolutionImage)
            //----->imageView.contentMode = UIViewContentMode.ScaleAspectFit
            uploadImages(imageView.image!)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerCancelled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func capture(sender: UIButton) {
        picker.takePicture()
        
        downloadToCameraRoll = true
        
        updateThumbnail()
    }
    
    func updateThumbnail(){
        thumbnailButton.setBackgroundImage(image, forState: .Normal)
        thumbnailButton.layer.borderColor = UIColor.whiteColor().CGColor
        thumbnailButton.layer.borderWidth=1.0
        
    }
    @IBAction func toggleTorch(sender: UIButton) {
        if self.picker.cameraFlashMode == UIImagePickerControllerCameraFlashMode.On{
            self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.Off
            
            self.flashButton.setImage(flashOff, forState: .Normal)
            
        }else{
            self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.On
            self.flashButton.setImage(flashOn, forState: .Normal)
        }
    }
    
    //TO-DO: restriction through geotagged image
    func setLastPhoto(){
        var fetchOptions: PHFetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        var fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        
        if (fetchResult.lastObject != nil) {
            
            var lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
            
            var sizeIM = CGSizeMake(50,50)
            PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: sizeIM , contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions()) { (result, info) -> Void in
                self.thumbnailButton.setBackgroundImage(result, forState: .Normal)
                self.thumbnailButton.layer.borderColor = UIColor.whiteColor().CGColor
                self.thumbnailButton.layer.borderWidth = 1.0
                self.thumbnailButton.layer.cornerRadius = 5
            }
            
        }
    }
    
    @IBAction func cancelCamera(sender: AnyObject) {
        
        println("here on cancel")
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func captureTest(sender : UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            println("Button capture")
            
            testCamera.delegate = self
            testCamera.sourceType = UIImagePickerControllerSourceType.Camera;
            testCamera.mediaTypes = [kUTTypeImage]
            testCamera.allowsEditing = false
            
            self.presentViewController(testCamera, animated: true, completion: nil)
        }
    }
    
    func uploadImages(uImage: UIImage){
        if NetworkAvailable.networkConnection() == true {
            
            var capturedImage = uImage as UIImage!
            
            var imageData = compressImage(uImage, shrinkRatio: 1.0)
            var imageFile = PFFile(name: "image.png", data: imageData)
            
            var thumbnailData = compressImage(cropToSquare(image: uImage), shrinkRatio: 0.5)
            var thumbnailFile = PFFile(name: "image.png", data: thumbnailData)
            
            
            //Upload photos to database
            var photo = PFObject(className: "Photo")
            photo["caption"] = "Camera roll upload"
            photo["image"] = imageFile
            photo["thumbnail"] = thumbnailFile
            photo["upvoteCount"] = 1
            photo["usersLiked"] = [PFUser.currentUser()!.username!]
            photo["uploader"] = PFUser.currentUser()!
            photo["uploaderName"] = PFUser.currentUser()!.username!
            photo["flagged"] = false
            photo["reviewed"] = false
            photo["blocked"] = false
            photo["reporter"] = ""
            photo["reportMessage"] = ""
            
            var photoACL = PFACL(user: PFUser.currentUser()!)
            photoACL.setPublicWriteAccess(true)
            photoACL.setPublicReadAccess(true)
            photo.ACL = photoACL
            
            
            var query2 = PFQuery(className: "EventAttendance")
            query2.whereKey("attendeeID", equalTo: PFUser.currentUser()!.objectId!)
            query2.whereKey("eventID", equalTo: eventId!)
            
            //var photoObjectList = query2.findObjects()
            var photoObjectList: Void = query2.findObjectsInBackgroundWithBlock({ (objs:[AnyObject]?, error:NSError?) -> Void in
                if (objs != nil && objs!.count != 0) {
                    var photoObject = objs!.first as! PFObject
                    
                    photoObject.addUniqueObject(thumbnailFile, forKey:"photosUploaded")
                    photoObject.addUniqueObject(thumbnailFile, forKey: "photosLiked")
                    
                    var queryEvent = PFQuery(className: "Event")
                    queryEvent.whereKey("objectId", equalTo: self.eventId!)
                    //var objects = queryEvent.findObjects()
                    var objects: Void = queryEvent.findObjectsInBackgroundWithBlock({ (sobjs:[AnyObject]?, error:NSError?) -> Void in
                        
                        if (sobjs != nil && sobjs!.count != 0) {
                            var eventObject = sobjs!.first as! PFObject
                            
                            let relation = eventObject.relationForKey("photos")
                            
                            //photo.save()
                            photo.saveInBackgroundWithBlock({ (valid:Bool, error:NSError?) -> Void in
                                if valid {
                                    relation.addObject(photo)
                                    photoObject.addUniqueObject(photo.objectId!, forKey: "photosUploadedID")
                                    photoObject.addUniqueObject(photo.objectId!, forKey: "photosLikedID")
                                }
                                //issue
                                eventObject.saveInBackground()
                                
                                //issue
                                photoObject.saveInBackground()
                            })
       
                        } else {
                            self.displayNoInternetAlert()
                        }
                    })
                }
                else {
                    self.displayNoInternetAlert()
                    println("Object Issue")
                }
                
            })
            
        } else {
            displayNoInternetAlert()
        }

    }
    
    func compressImage(image:UIImage, shrinkRatio: CGFloat) -> NSData {
        var imageHeight:CGFloat = image.size.height
        var imageWidth:CGFloat = image.size.width
        var maxHeight:CGFloat = 3264 * shrinkRatio//2272 * shrinkRatio//1136.0 * shrinkRatio
        var maxWidth:CGFloat = 1838 * shrinkRatio//1280 * shrinkRatio//640.0 * shrinkRatio
        var imageRatio:CGFloat = imageWidth/imageHeight
        var scalingRatio:CGFloat = maxWidth/maxHeight
        
        //lowest quality rating with acceptable encoding
        var quality:CGFloat = 0.3
        
        if (imageHeight > maxHeight || imageWidth > maxWidth){
            if(imageRatio < scalingRatio){
                /* To ensure aspect ratio is maintained adjust
                witdth of image in relation to scaling height */
                imageRatio = maxHeight / imageHeight;
                imageWidth = imageRatio * imageWidth;
                imageHeight = maxHeight;
            }
            else if(imageRatio > scalingRatio){
                /* To ensure aspect ratio is maintained adjust
                height of image in relation to scaling width */
                imageRatio = maxWidth / imageWidth;
                imageHeight = imageRatio * imageHeight;
                imageWidth = maxWidth;
            }
            else{
                /* If image is equivalent to scaling ratio
                image should not be compressed any further
                scaled down to max resolution*/
                imageHeight = maxHeight;
                imageWidth = maxWidth;
                quality = 1;
            }
        }
        
        var rect = CGRectMake(0.0, 0.0, imageWidth, imageHeight);
        //bit-map based graphic context and set the boundaries of still image
        UIGraphicsBeginImageContext(rect.size);
        image.drawInRect(rect)
        var imageCompressed = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(imageCompressed, quality);
        UIGraphicsEndImageContext();
        
        return imageData;
    }

}
