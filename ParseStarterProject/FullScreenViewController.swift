//
//  fullScreenViewController.swift
//  ParseStarterProject
//
//  Created by Jonathan Arlauskas on 2015-05-18.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Social
import Parse
import MessageUI
import ParseUI


class FullScreenViewController: UIViewController, UIGestureRecognizerDelegate,MFMessageComposeViewControllerDelegate, UIScrollViewDelegate  {
    
    let mixpanel = Mixpanel.sharedInstance()
    
    @IBOutlet var likeCount: UILabel!
    
    @IBOutlet var eventInfo: UILabel!
    
    @IBOutlet var fullScreenImage: PFImageView!
    
    @IBOutlet var likeButtonLabel: UIButton!
    

    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    
    
    var likeActive = false
    
    // Index of cell selected, and index/page scrollView is currently on
    var selectedIndex : Int?
    var pageIndex : Int = 0
    
    // Icon image variables
    let liked = UIImage(named: "heart-icon-filled.pdf") as UIImage!
    let unliked = UIImage(named: "heart-icon-empty.pdf") as UIImage!
    let back = UIImage(named: "back.pdf") as UIImage!
	
    // Title passed from previous VC
    var eventId : String?
    var eventTitle : String?
    
    // Arrays of objectIds, and dates
    var tempArray :[String]?
    
    // Scroll View variables
    var pageViews : [UIImageView?] = []
    var imageFiles : [PFFile?] = []
    var prevPage : Int?
    
    // Function to handle double tap on an image to like
    func handleTap (sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            likeButton(self)
            likeToggle(self)
        }
    }
    
    func displayNoInternetAlert() {
        var alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to the internet to access content.")
        self.presentViewController(alert, animated: true, completion: nil)
        println("no internet")
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    //delegate method for the MessageComposeViewController
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // toggles the like button from "like" to "unlike" when clicked
    @IBAction func likeToggle(sender: AnyObject) {
      
        if NetworkAvailable.networkConnection() == true {
            // Adjust heart image
            if likeActive == false {
                likeActive = true
                likeButtonLabel.setImage(liked, forState: .Normal)
            } else {
                likeActive = false
                likeButtonLabel.setImage(unliked, forState:.Normal)
            }
        } else {
            displayNoInternetAlert()
        }
    }

    
    // Like button fills 4 arays in database with IDs and thumbnails. Four arrays are in Event Attendance class
    @IBAction func likeButton(sender: AnyObject) {
        
        let qos = (Int(QOS_CLASS_BACKGROUND.value))

        if NetworkAvailable.networkConnection() == true {
            if self.likeActive == false {
                // Dispatch to background thread from main queue
                dispatch_async(dispatch_get_global_queue(qos, 0)) {

                    //----------- Query for Adjusting DB in the case of liking a photo ----------
                    var likeQuery = PFQuery(className: "Event")
                    likeQuery.whereKey("objectId", equalTo: self.eventId!)

                    var likeEventList = likeQuery.findObjects()
                    
                    if (likeEventList != nil && likeEventList!.count != 0) {
                        var likeEvents = likeEventList!.first as! PFObject
                        var likeRelation = likeEvents["photos"] as! PFRelation
                    
                        // User like list that will be filled
                        var likeList : [String]
                        var upVote : Int
                        var hqImage : PFFile
                        
                        // Finds associated photo object in relation
                        var retrieveLikes = likeRelation.query()?.getObjectWithId(self.tempArray![self.pageIndex])
                        
                        if retrieveLikes != nil {
                            
                            // Add user to like list, add 1 to the upvote count
                            retrieveLikes?.addUniqueObject(PFUser.currentUser()!.username!, forKey: "usersLiked")
                            retrieveLikes?.incrementKey("upvoteCount", byAmount: 1)
                            
                            // Grab specific elements from object
                            likeList = (retrieveLikes!.objectForKey("usersLiked") as? [String])!
                            hqImage = (retrieveLikes!.objectForKey("image") as? PFFile)!
                            upVote = (retrieveLikes!.objectForKey("upvoteCount")) as! Int
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                let counter = upVote
                                if counter == 1 {
                                    self.likeCount.text = String(counter) + " like"
                                } else {
                                    self.likeCount.text = String(counter) + " likes"
                                }
                            }
                            
                            // Add both photo object (thumbnail) and id to arrays in user class
                            var query2 = PFQuery(className: "EventAttendance")
                            query2.whereKey("attendeeID", equalTo: PFUser.currentUser()!.objectId!)
                            query2.whereKey("eventID", equalTo: self.eventId!)
                            
                            query2.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
                                            
                                if error == nil {

                                    object?.addObject(hqImage, forKey: "photosLiked")
                                            
                                    object?.addUniqueObject(self.tempArray![self.pageIndex], forKey:"photosLikedID")
                                            
                                    object!.saveInBackground()
                                            
                                    
                                } else {
                                            
                                    println("Error: \(error!) \(error!.userInfo!)")
                                }
                            }
                            
                            retrieveLikes!.saveInBackground()

                        } else {
                            self.displayNoInternetAlert()
                        }
                        
                    } else {
                        self.displayNoInternetAlert()
                    }
                }
            } else {
                // Dispatch to background thread from main queue
                dispatch_async(dispatch_get_global_queue(qos, 0)) {
                
                    //----------- Query for Adjusting DB in the case of an unlike----------
                    var likeQuery = PFQuery(className: "Event")
                    likeQuery.whereKey("objectId", equalTo: self.eventId!)
                    var likedEventList = likeQuery.findObjects()
                
                    if (likedEventList != nil && likedEventList!.count != 0) {
                    
                        var likeEvents = likedEventList!.first as! PFObject
                        var likeRelation = likeEvents["photos"] as! PFRelation
                        
                        // User like list that will be filled
                        var likeList : [String]
                        var upVote : Int
                        var hqImage : PFFile
                        
                        // Finds associated photo object in relation
                        var retrieveLikes = likeRelation.query()?.getObjectWithId(self.tempArray![self.pageIndex])
                    
                        if retrieveLikes != nil {
                            
                            // Add user to like list, add 1 to the upvote count
                            retrieveLikes?.removeObject(PFUser.currentUser()!.username!, forKey: "usersLiked")
                            retrieveLikes?.incrementKey("upvoteCount", byAmount: -1)
                            
                            // Grab specific elements from object.
                            likeList = (retrieveLikes!.objectForKey("usersLiked") as? [String])!
                            hqImage = (retrieveLikes!.objectForKey("image") as? PFFile)!
                            upVote = (retrieveLikes!.objectForKey("upvoteCount")) as! Int

                            // UI label set on the main thread
                            dispatch_async(dispatch_get_main_queue()) {
                                // Set appropriate label on the view
                                let counter = upVote
                                if counter == 1 {
                                    self.likeCount.text = String(counter) + " like"
                                } else {
                                    self.likeCount.text = String(counter) + " likes"
                                }
                            }
                            
                            // Add both photo object and id to arrays in user class
                            var query2 = PFQuery(className: "EventAttendance")
                            query2.whereKey("attendeeID", equalTo: PFUser.currentUser()!.objectId!)
                            query2.whereKey("eventID", equalTo: self.eventId!)
                            query2.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
                                
                                if error == nil {
                                    object?.removeObject(hqImage, forKey: "photosLiked")
                                    object?.removeObject(self.tempArray![self.pageIndex], forKey:"photosLikedID")
                                    object!.saveInBackground()
                                } else {
                                    println("Error: \(error!) \(error!.userInfo!)")
                                }
                            }
                            retrieveLikes!.saveInBackground()
                            
                        } else {
                            self.displayNoInternetAlert()
                        }
                        
                    } else {
                        self.displayNoInternetAlert()
                    }
                }
            }
        } else {
            self.displayNoInternetAlert()
        }
    }

	
	func sharePhoto()
	{
		
		self.fullScreenImage.file = self.imageFiles[self.pageIndex]
		self.fullScreenImage.loadInBackground()
		
		// Twitter
		let twitter = "";
		
		// Facebook
		let facebook = "";
		
		let imageData : UIImage = self.fullScreenImage.image!;
		let image = Image(text: "Check out this photo!");
		
		let reportImage = ReportImageActivity();
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "flagPhoto:", name: "BFImageReportActivitySelected", object: nil)
		
		
		let vc = UIActivityViewController(activityItems: [image, imageData], applicationActivities:[reportImage])
		vc.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePrint]
		self.presentViewController(vc, animated: true, completion: nil)

        vc.completionWithItemsHandler = { activity, success, items, error in
            
            if (success && error == nil) {
                
                var message = ""
                switch (activity) {
                case UIActivityTypePostToFacebook:
                    self.mixpanel.track("Photo Facebook Share")
                    message = "Not appearing on Facebook? Check the iOS settings for Facebook and make sure you're logged in."
                case UIActivityTypePostToTwitter:
                    self.mixpanel.track("Photo Twitter Share")
                    message = "Successfully posted to Twitter."
                case UIActivityTypeMail:
                    self.mixpanel.track("Photo Email Share")
                case UIActivityTypeMessage:
                    self.mixpanel.track("Photo SMS Share")
                case UIActivityTypeSaveToCameraRoll:
                    self.mixpanel.track("Save To Camera Roll")
                default:
                    self.mixpanel.track("Photo Other Action")
                }
                
                if (message != "") {
                    self.displaySuccess("Posted!", error: message)
                }
            } else if (error == nil) {
                println("cancelled")
            } else {
                self.displaySuccess("Failed to post!", error: "Check internet connectivity and try again.")
                println(error)
            }
        }
	}
    
    // Alert pop up with Twitter, Facebook and SMS options
    @IBAction func share(sender: AnyObject) {
		sharePhoto();
    }
    
    
    // Alert for successful posting to Twitter or Facebook
    func displaySuccess(title: String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
  
    // Download to camera roll button
    @IBAction func downloadImage(sender: AnyObject) {
        
        
        if imageFiles.count != 0 {
            
            fullScreenImage.file = imageFiles[pageIndex]
            self.fullScreenImage.loadInBackground()
            UIImageWriteToSavedPhotosAlbum(fullScreenImage.image, nil, nil, nil)
            
            saveImageAlert("Image saved to camera roll", error: "")
            
            
        } else {
            
            saveImageAlert("Oops!", error: "Image failed to save. Please try again.")
        }
    }
	
	
    @IBAction func flagPhoto(sender: AnyObject) {
        
        let qos = (Int(QOS_CLASS_BACKGROUND.value))
        
        // Do object fetching in background
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
        
            var getRelatedEvent = PFQuery(className: "Event")
            getRelatedEvent.limit = 1
            getRelatedEvent.whereKey("objectId", equalTo: self.eventId!)
            
            // Retrieval from corresponding photos from relation to event

            var relatedEvents = getRelatedEvent.findObjects()
            
            if (relatedEvents == nil || relatedEvents!.count == 0) {
                self.displayNoInternetAlert()
            } else {
                var object = relatedEvents!.first as! PFObject
                var photos = object["photos"] as! PFRelation
                
                // Finds associated photo object in relation
                var photoObj = photos.query()?.getObjectWithId(self.tempArray![self.pageIndex])
                
                if photoObj != nil {
                    // UI Alert on main queue
                    dispatch_async(dispatch_get_main_queue()) {
                        var alert = UIAlertController(title: "Flag inappropriate content", message: "What is wrong with this photo?", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in }
                        
                        alert.addAction(UIAlertAction(title: "Flag", style: UIAlertActionStyle.Default, handler: { (action) in
                                var flagEntry = alert.textFields?.first as! UITextField
                                
                                photoObj!["flagged"] = true
                                photoObj!["reviewed"] = false
                                photoObj!["blocked"] = false
                                photoObj!["reporter"] = PFUser.currentUser()?.objectId
                                photoObj!["reportMessage"] = flagEntry.text
                            
                                photoObj?.saveInBackground()
                            
                                print("Photo flagged successfully. Msg: ")
                            
                                self.seg()
                            
                                println(flagEntry.text)
                            }))

                        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                    
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                } else {
                    self.displayNoInternetAlert()
                }
            }
        }
    }
    
    // Alert displayed when an image is successfully saved to camera roll
    func saveImageAlert (title:String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // Back button to album view
    func seg() {

        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func displayUpdate () {
        
        // Put querying operations in a background thread
        let qos = (Int(QOS_CLASS_BACKGROUND.value))
        prevPage = pageControl.currentPage
        dispatch_async(dispatch_get_global_queue(qos,0)) {
            
            if NetworkAvailable.networkConnection() == true {
                
                    //----------- Query for Like Image label--------------
                    var query5 = PFQuery(className: "Event")
                    query5.whereKey("objectId", equalTo: self.eventId!)
                    
                    var eventObject = query5.findObjects()?.first as! PFObject
                    var relation = eventObject["photos"] as! PFRelation

                    // Finds associated photo object in relation
                    var likeRetrieve = relation.query()?.getObjectWithId(self.tempArray![self.pageIndex])
                    
                    // Fill the like list with the user liked list array from photo relation
                    var likeList = (likeRetrieve!.objectForKey("usersLiked") as? [String])!
                    var upVote = (likeRetrieve!.objectForKey("upvoteCount") as? Int)
                    var time = (likeRetrieve!.createdAt! as NSDate)

                    // UI Updates on the main queue
                    dispatch_async(dispatch_get_main_queue()) {
                        var contained = contains(likeList, PFUser.currentUser()!.username!)
                        
                        if contained == true {
                            self.likeActive = true
                            self.likeButtonLabel.setImage(self.liked, forState: .Normal)
                        } else {
                            self.likeActive = false
                            self.likeButtonLabel.setImage(self.unliked, forState: .Normal)
                        }
                        
                        // Set the like and number labels
                        let count = upVote
                        if (count == 1) {
                            self.likeCount.text = String(count!) + " like"
                        } else {
                            self.likeCount.text = String(count!) + " likes"
                        }
                    
                
                    //----------- Format and display photo date -------------
                    if time != 0 {
                        
                        // Formatting to display date how we want it
                        let formatter = NSDateFormatter()
                        formatter.dateStyle = NSDateFormatterStyle.LongStyle
                        formatter.timeStyle = .ShortStyle
                        let dateStamp = formatter.stringFromDate(time)
                        
                        self.eventInfo.text = "Photo taken on \(dateStamp)"
                        
                    }
                }
            } else {
                self.displayNoInternetAlert()
            }
        }
    }
    
    //---------Scroll view functions------------
    
    // We are only loading the page before and after the current photo; more efficient in case user does not browse all photos (3 pages)
    func loadVisiblePages () {

        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        pageControl.currentPage = page
        
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Clean all pages less than the 3 page range
        for var index = 0; index < firstPage; ++index {
            cleanPage(index)
        }
        
        // Load all pages within the three page range
        for index in firstPage ... lastPage {
            loadPage(index)
        }
        
        // Clean all photos greater than 3 page range
        for var index = lastPage + 1; index < imageFiles.count; ++index {
            cleanPage(index)
        }
    }
    
    func loadPage ( page: Int) {
        
        if page < 0 || page >= imageFiles.count {
        // Check if outside range of what will be displayed.
            return
        }
        
        if let pageView = pageViews[page] {
        // Do nothing, view loaded already
        } else {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            // Sets the distance between images in scroll
            frame = CGRectInset(frame, 1.0, 0.0)
            
            // Creates PFImageView instances in scrollView
            let newPageView = PFImageView()
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            newPageView.file = imageFiles[page]
            newPageView.loadInBackground()
            scrollView.addSubview(newPageView)
            pageViews[page] = newPageView
        }
    }
    
    // Updates scroll view to indicate this page no longer exists. Helps for memory
    func cleanPage (page: Int) {
        if page < 0 || page >= imageFiles.count {
            return
        }
        
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    
    // When a user stops on a photo, load the appropriate information
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        pageIndex = pageControl.currentPage
        
        // Check if user actually switched photos. If not, dont reload display
        if pageIndex != prevPage {
            displayUpdate()
        }
    }
    
    // Recognizes when a scroll occurs, and loads the corresponding pages (before and after the image)
    func scrollViewDidScroll(scrollView: UIScrollView) {
        loadVisiblePages()
    }

    //------------------------------------------
    
    override func viewDidLoad() {
       
        super.viewDidLoad()

        //---------Scroll view Set up------------
        
        scrollView.delegate = self
        pageControl.hidden = true
        scrollView.showsHorizontalScrollIndicator = false
        
        // Keep full screen image view in background to load to when sharing or downloading a photo. only loads when necessary
        fullScreenImage.hidden = true

        let pageCount = imageFiles.count
        pageControl.numberOfPages = pageCount
        
        // Cleans the pageViews, filling the array with nil
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // Sets the overall content size of our scroll view
        let pageScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSizeMake(pageScrollViewSize.width * CGFloat(imageFiles.count), pageScrollViewSize.height)
        
        // Start at the appropriate photo based on cell selected from album view
        var frame : CGRect = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(selectedIndex!)
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: true)
        pageIndex = selectedIndex!
        
        // Loading of the pages that are visible on screen
        loadVisiblePages()

        //--------------- Draw UI -----------------
        
        // Hide UI controller item
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        // Nav Bar positioning
        let navBar = UINavigationBar(frame: CGRectMake(0,0,self.view.frame.size.width, 64 ))
        navBar.backgroundColor =  UIColor.whiteColor()
        
        // Set the Nav bar properties
        let navBarItem = UINavigationItem()
        navBarItem.title = eventTitle
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Avenir-Medium",size: 18)!]
        navBar.items = [navBarItem]
        
        // Left nav bar button item
        let back = UIButton.buttonWithType(.Custom) as! UIButton
        back.setTitleColor(UIColor.blackColor(), forState: .Normal)
        back.setImage(self.back, forState: .Normal)
        back.tintColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        back.frame = CGRectMake(-10, 20, 72, 44)
        back.addTarget(self, action: "seg", forControlEvents: .TouchUpInside)
        navBar.addSubview(back)
        
        self.view.addSubview(navBar)
        
        
        //-------------Gesture implementation----------
        
        var gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        gesture.numberOfTapsRequired = 2
        scrollView.userInteractionEnabled = true
        self.scrollView.addGestureRecognizer(gesture)
        
        //------------------------------------------
        
        // Load information from the database for the UI
        displayUpdate()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        // Attempt at solving a memory issue (Error: Message from debugger: Terminated due to Memory Pressure)
        // http://stackoverflow.com/questions/19253365/how-to-debug-ios-crash-due-to-memory-pressure
        if (self.isViewLoaded() && self.view.window == nil) {
            self.view = nil
        }
    }

}
