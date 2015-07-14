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
    var newScroll : Bool?
    
    // Index of cell selected, and index/page scrollView is currently on
    var selectedIndex : Int?
    var pageIndex : Int = 0
    
    // Icon image variables
    var liked = UIImage(named: "heart-icon-filled.pdf") as UIImage!
    var unliked = UIImage(named: "heart-icon-empty.pdf") as UIImage!
    var back = UIImage(named: "back.pdf") as UIImage!
    var share = UIImage(named: "share-icon.pdf") as UIImage!
    
    // Title passed from previous VC
    var eventId : String?
    var eventTitle : String?
    
    // Arrays of objectIds, and dates
    var tempDate: [NSDate?] = []
    var tempArray :[String]?
    
    // Scroll View variables
    var pageViews : [UIImageView?] = []
    var imageFiles : [PFFile?] = []
    
    // Function to handle double tap on an image to like
    func handleTap (sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            likeButton(self)
            likeToggle(self)
        }
    }

//    func handleSwipe (gesture: UISwipeGestureRecognizer) {
//        
//        if let swipeGesture: UISwipeGestureRecognizer = gesture as UISwipeGestureRecognizer! {
//            
//            switch swipeGesture.direction {
//                
//            case UISwipeGestureRecognizerDirection.Right:
//                
//                if selectedIndex! != 0 {
//                    selectedIndex! = selectedIndex! - 1
//                    displayUpdate()
//                } else  {
//                    break
//                }
//                
//            case UISwipeGestureRecognizerDirection.Left:
//                
//                if tempArray?.count != selectedIndex! + 1 {
//                    selectedIndex! = selectedIndex! + 1
//                    displayUpdate()
//                } else {
//                    break
//                }
//                
//            default :
//                break
//            }
//        }
//    }
    
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
                        var thumbnail : PFFile
                        
                        // Finds associated photo object in relation
                        var retrieveLikes = likeRelation.query()?.getObjectWithId(self.tempArray![self.pageIndex])
                        
                        if retrieveLikes != nil {
                            
            
                            // Add user to like list, add 1 to the upvote count
                            retrieveLikes?.addUniqueObject(PFUser.currentUser()!.username!, forKey: "usersLiked")
                            retrieveLikes?.incrementKey("upvoteCount", byAmount: 1)
                            
                            // Grab specific element fromobject
                            likeList = (retrieveLikes!.objectForKey("usersLiked") as? [String])!
                            thumbnail = (retrieveLikes!.objectForKey("thumbnail") as? PFFile)!
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                let counter = likeList.count
                                if counter == 1 {
                                    
                                    self.likeCount.text = String(counter) + " likes"
                                    
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

                                    object?.addObject(thumbnail, forKey: "photosLiked")
                                            
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
                        var thumbnail : PFFile
                        
                        // Finds associated photo object in relation
                        var retrieveLikes = likeRelation.query()?.getObjectWithId(self.tempArray![self.pageIndex])
                    
                        if retrieveLikes != nil {
                            
                            // Add user to like list, add 1 to the upvote count
                            retrieveLikes?.removeObject(PFUser.currentUser()!.username!, forKey: "usersLiked")
                            retrieveLikes?.incrementKey("upvoteCount", byAmount: -1)
                            
                            // Grab specific element from object.
                            likeList = (retrieveLikes!.objectForKey("usersLiked") as? [String])!
                            thumbnail = (retrieveLikes!.objectForKey("thumbnail") as? PFFile)!
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                //Set appropriate labal on the view
                                let counter = likeList.count
                                if counter == 1 {
                                    self.likeCount.text = String(counter) + " likes"
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
                                    object?.removeObject(thumbnail, forKey: "photosLiked")
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

    // Alerts for sharing to Facebook and Twitter
    func displayAlert(title:String,error: String) {
        
            var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
            // Facebook share feature
            alert.addAction(UIAlertAction(title: "Facebook", style: .Default, handler: { action in
                
                if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
                    var facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                    
                    facebookSheet.addImage(self.fullScreenImage.image!)
                    
                    self.presentViewController(facebookSheet, animated: true, completion: nil)
                    
                    facebookSheet.completionHandler = { (result: SLComposeViewControllerResult) -> Void in
                        switch(result) {
                            
                        case SLComposeViewControllerResult.Cancelled:
                            
                            println("cancelled")
                            
                        case SLComposeViewControllerResult.Done:
                            
                            if NetworkAvailable.networkConnection() == true {
                                self.mixpanel.track("Facebook Share")
                                self.dismissViewControllerAnimated(false, completion: nil)
                                self.displaySuccess("Posted!", error: "Not appearing on Facebook? Check the iOS settings for Facebook and make sure you're logged in.")
                            }
                            else {
                                self.displayNoInternetAlert()
                            }

                        }
                        
                    }
               
                } else {
                    var alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }))

        
            // Twitter share feature
            alert.addAction(UIAlertAction(title: "Twitter", style: .Default, handler: { action in
                
                if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
                    
                    var twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                    
                    twitterSheet.addImage(self.fullScreenImage.image)
                    
                    self.presentViewController(twitterSheet, animated: true, completion: nil)

                    twitterSheet.completionHandler = { (result: SLComposeViewControllerResult) -> Void in
                        switch(result) {
                            
                        case SLComposeViewControllerResult.Cancelled:
                            
                            println("cancelled")
                            
                        case SLComposeViewControllerResult.Done:

                            if NetworkAvailable.networkConnection() == true {
                                self.mixpanel.track("Twitter Share")
                                self.dismissViewControllerAnimated(false, completion: nil)
                                self.displaySuccess("Posted!", error: "Successfully posted to Twitter.")
                            }
                            else {
                                self.displayNoInternetAlert()
                            }
                        }
                    }
                    
                
                } else {
                    
                    var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
                }))
        
        if NetworkAvailable.networkConnection() == true {
            // SMS sharing feature
            alert.addAction(UIAlertAction(title: "Invite friends to album (SMS)", style: .Default, handler: { action in
                
                var params = [ "referringUsername": "friend", "referringOut": "FSVC", "eventId":"\(self.eventId!)", "eventTitle": "\(self.eventTitle!)"]
                
                // This is making an asynchronous call to Branch's servers to generate the link and attach the information provided in the params dictionary --> so inserted spinner code to notify user program is running
                
                self.spinner.startAnimating()
                //disable button
                
                Branch.getInstance().getShortURLWithParams(params, andChannel: "SMS", andFeature: "Referral", andCallback: { (url: String!, error: NSError!) -> Void in
                    if (error == nil) {
                        if MFMessageComposeViewController.canSendText() {
                                if NetworkAvailable.networkConnection() == true {
                                    let messageComposer = MFMessageComposeViewController()
                                    
                                    messageComposer.body = String(format: "Check out these photos on Backflip! %@", url)
                                    
                                    messageComposer.messageComposeDelegate = self
                                    
                                    self.presentViewController(messageComposer, animated: true, completion:{(Bool) in
                                        // stop spinner on main thread
                                        self.spinner.stopAnimating()
                                
                                    })
                                }
                                else {
                                    self.displayNoInternetAlert()
                                }
                        } else {
                            
                            self.spinner.stopAnimating()
                            
                            var alert = UIAlertController(title: "Error", message: "Your device does not allow sending SMS or iMessages.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                })
            }))
        }

            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))

            self.presentViewController(alert, animated: true, completion: nil)

        
        
    }
    
    // Alert pop up with Twitter, Facebook and SMS options
    @IBAction func share(sender: AnyObject) {
         displayAlert("Share", error: "How do you want to share this photo?")
    }
    
    
    // Alert for successful posting to Twitter or Facebook
    func displaySuccess(title: String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
  
    // Download to camera roll button
    @IBAction func downloadImage(sender: AnyObject) {
        
        
        if fullScreenImage.image != nil {
            
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
        dispatch_async(dispatch_get_global_queue(qos,0)) {
            
            if NetworkAvailable.networkConnection() == true {

        //----------- Query for image display---------------
                /*var getRelatedEvents = PFQuery(className: "Event")
                getRelatedEvents.limit = 1
                getRelatedEvents.whereKey("objectId", equalTo: self.eventId!)
                
                // Retrieval from corresponding photos from relation to event
                
                var object = getRelatedEvents.findObjects()?.first as! PFObject
                
                var photos = object["photos"] as! PFRelation
                var tempImage: PFFile?
                // Finds associated photo object in relation
                var photoList = photos.query()?.getObjectWithId(self.tempArray![self.selectedIndex!])
                self.tempDate = photoList?.createdAt
                
                // UI updates on the main queue
                dispatch_async(dispatch_get_main_queue()) {
                    // Once retrieved from relation, set the UIImage view for fullscreen view
                    tempImage = photoList!.objectForKey("image") as? PFFile
                    
                    self.fullScreenImage.file = tempImage
                    self.fullScreenImage.loadInBackground()
                }*/
                
        //----------- Query for Like Image label--------------
                var query5 = PFQuery(className: "Event")
                query5.whereKey("objectId", equalTo: self.eventId!)
                
                var eventObject = query5.findObjects()?.first as! PFObject
                var relation = eventObject["photos"] as! PFRelation
                
                // User like list that will be filled
                var likeList : [String]
                
                // Finds associated photo object in relation
                var likeRetrieve = relation.query()?.getObjectWithId(self.tempArray![self.pageIndex])
                
                // Fill the like list with the user liked list array from photo relation
                likeList = (likeRetrieve!.objectForKey("usersLiked") as? [String])!

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
                let count = likeList.count
                
                if (count == 1) {
                    self.likeCount.text = String(count) + " like"
                } else {
                    self.likeCount.text = String(count) + " likes"
                }
                
                
        //----------- Format and display photo date -------------
                if self.tempDate.count != 0 {
                    
                    // Formatting to display date how we want it
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = NSDateFormatterStyle.LongStyle
                    formatter.timeStyle = .ShortStyle
                    let dateStamp = formatter.stringFromDate(self.tempDate[self.pageIndex]!)
                    
                    self.eventInfo.text = "Photo taken on \(dateStamp)"
                    
                }
            }

                
            } else {
                self.displayNoInternetAlert()
            }
        }
    }
    
    //---------Scroll view functions------------
    
    func loadVisiblePages () {

        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        pageControl.currentPage = page
        
        let firstPage = page - 1
        let lastPage = page + 1
        
        for var index = 0; index < firstPage; ++index {
            cleanPage(index)
        }
        
        for index in firstPage ... lastPage {
            loadPage(index)
        }
        
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
            frame = CGRectInset(frame, 10.0, 0.0)
            
            let newPageView = PFImageView()
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            newPageView.file = imageFiles[page]
            newPageView.loadInBackground()
            scrollView.addSubview(newPageView)
            pageViews[page] = newPageView
        }
    }
    
    func cleanPage (page: Int) {
        if page < 0 || page >= imageFiles.count {
            
            return
        }
        
    }

    // When a user stops on a photo, load the appropriate information
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageIndex = pageControl.currentPage

        displayUpdate()
        
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
        //pageControl.hidden = true
        fullScreenImage.hidden = true
        scrollView.showsHorizontalScrollIndicator = false

        
        let pageCount = imageFiles.count
        //pageControl.currentPage = self.selectedIndex!
        pageControl.numberOfPages = pageCount
        
        // Sets up our pageViews array to hold the views
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // Sets the overall content size of our scroll view
        let pageScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSizeMake(pageScrollViewSize.width * CGFloat(imageFiles.count), pageScrollViewSize.height)
        
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
        
        // Right nav bar button item
        let shareImage = UIButton.buttonWithType(.Custom) as! UIButton
        shareImage.setImage(self.share, forState:.Normal)
        shareImage.tintColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        shareImage.frame = CGRectMake(self.view.frame.size.width-62, 20, 72, 44)
        shareImage.addTarget(self, action: "share:", forControlEvents: .TouchUpInside)
        navBar.addSubview(shareImage)
        
        self.view.addSubview(navBar)
        
        
//        //-------------Gesture implementation----------
//        var gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
//        gesture.numberOfTapsRequired = 2
//        
//        fullScreenImage.userInteractionEnabled = true
//        self.view.addGestureRecognizer(gesture)
//        
//        self.view.bringSubviewToFront(likeCount)
//        
//        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
//        
//        
//        var swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
//        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
//        
//        self.view.addGestureRecognizer(swipeLeft)
//        self.view.addGestureRecognizer(swipeRight)
        
        // Load information from the database
        displayUpdate()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
