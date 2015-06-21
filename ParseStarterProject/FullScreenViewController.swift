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


class FullScreenViewController: UIViewController, UIGestureRecognizerDelegate,MFMessageComposeViewControllerDelegate {
    
    let mixpanel = Mixpanel.sharedInstance()
    @IBOutlet var likeCount: UILabel!
    
    @IBOutlet var eventInfo: UILabel!
    
    @IBOutlet var fullScreenImage: UIImageView!
    
    @IBOutlet var likeButtonLabel: UIButton!
    
    var tempDate: NSDate?
    
    
    var cellImage : UIImage!
    var objectIdTemp : String = ""
    var likeActive = false
    
    // Icon image variables
    var liked = UIImage(named: "heart-icon-filled.pdf") as UIImage!
    var unliked = UIImage(named: "heart-icon-empty.pdf") as UIImage!
    var back = UIImage(named: "back.pdf") as UIImage!
    var share = UIImage(named: "share-icon.pdf") as UIImage!

    
    // Title passed from previous VC
    var eventId : String?
    var eventTitle : String?
    
    // Function to handle double tap on image
    func handleTap (sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended {
    
            likeButton(self)
            likeToggle(self)
            
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    //delegate method for the MessageComposeViewController
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // toggles the like button from "like" to "unlike" when clicked
    @IBAction func likeToggle(sender: AnyObject) {
        
        // adjust heart image
        if likeActive == false {
        
            likeActive = true

            likeButtonLabel.setImage(liked, forState: .Normal)

        
        } else {
        
            likeActive = false
            
            likeButtonLabel.setImage(unliked, forState:.Normal)
        
        }
    }

    
    // Like button fills 4 arays in database with IDs and thumbnails. Four arrays are in Event Attendance class
    @IBAction func likeButton(sender: AnyObject) {
        
        if likeActive == false {
            
            
            //----------- Query for Adjusting DB in the case of liking a photo ----------
            var likeQuery = PFQuery(className: "Event")
            
            likeQuery.whereKey("objectId", equalTo: eventId!)
            
            var likeEvents = likeQuery.findObjects()?.first as! PFObject
            var likeRelation = likeEvents["photos"] as! PFRelation
            
            // User like list that will be filled
            var likeList : [String]
            var upVote : Int
            var thumbnail : PFFile
            
            // Finds associated photo object in relation
            var retrieveLikes = likeRelation.query()?.getObjectWithId(objectIdTemp)
            
            // Add user to like list, add 1 to the upvote count
            retrieveLikes?.addUniqueObject(PFUser.currentUser()!.username!, forKey: "usersLiked")
            retrieveLikes?.incrementKey("upvoteCount", byAmount: 1)
            
            // Grab specific element fromobject
            likeList = (retrieveLikes!.objectForKey("usersLiked") as? [String])!
            thumbnail = (retrieveLikes!.objectForKey("thumbnail") as? PFFile)!
            
            let counter = likeList.count
            if counter == 1 {
                
                self.likeCount.text = String(counter) + " likes"
                
            } else {
                
                self.likeCount.text = String(counter) + " likes"
            }
                    
            // Add both photo object (thumbnail) and id to arrays in user class
            var query2 = PFQuery(className: "EventAttendance")
            query2.whereKey("attendeeID", equalTo: PFUser.currentUser()!.objectId!)
            query2.whereKey("eventID", equalTo: eventId!)
            
            query2.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
                        
                if error == nil {

                    object?.addObject(thumbnail, forKey: "photosLiked")
                            
                    object?.addUniqueObject(self.objectIdTemp, forKey:"photosLikedID")
                            
                    object!.saveInBackground()
                            
                            
                } else {
                            
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
                    
            retrieveLikes!.saveInBackground()
            
        } else {
            
            //----------- Query for Adjusting DB in the case of an unlike----------
            var likeQuery = PFQuery(className: "Event")
            likeQuery.whereKey("objectId", equalTo: eventId!)
            
            var likeEvents = likeQuery.findObjects()?.first as! PFObject
            var likeRelation = likeEvents["photos"] as! PFRelation
            
            // User like list that will be filled
            var likeList : [String]
            var upVote : Int
            var thumbnail : PFFile
            
            // Finds associated photo object in relation
            var retrieveLikes = likeRelation.query()?.getObjectWithId(objectIdTemp)
            
            // Add user to like list, add 1 to the upvote count
            retrieveLikes?.removeObject(PFUser.currentUser()!.username!, forKey: "usersLiked")
            retrieveLikes?.incrementKey("upvoteCount", byAmount: -1)

            
            // Grab specific element from object.
            likeList = (retrieveLikes!.objectForKey("usersLiked") as? [String])!
            thumbnail = (retrieveLikes!.objectForKey("thumbnail") as? PFFile)!
            
            //Set appropriate labal on the view
            let counter = likeList.count
            if counter == 1 {
                
                self.likeCount.text = String(counter) + " likes"
                
            } else {
                
                self.likeCount.text = String(counter) + " likes"
            }
            
            // Add both photo object and id to arrays in user class
            var query2 = PFQuery(className: "EventAttendance")
            query2.whereKey("attendeeID", equalTo: PFUser.currentUser()!.objectId!)
            query2.whereKey("eventID", equalTo: eventId!)
            
            query2.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
                
                if error == nil {
                    
                    object?.removeObject(thumbnail, forKey: "photosLiked")
                    
                    object?.removeObject(self.objectIdTemp, forKey:"photosLikedID")
                    
                    object!.saveInBackground()
                    
                    
                } else {
                    
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
            
            retrieveLikes!.saveInBackground()

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
                        
                        
                        self.mixpanel.track("Facebook Share")
                        self.dismissViewControllerAnimated(false, completion: nil)
                        self.displaySuccess("Posted!", error: "Not appearing on Facebook? Check the iOS settings for Facebook and make sure you are logged in.")

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
                        
                        self.mixpanel.track("Twitter Share")
                        self.dismissViewControllerAnimated(false, completion: nil)
                        self.displaySuccess("Posted!", error: "Successfully posted to Twitter.")
    
                    }
                }
                
            
            } else {
                
                var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            }))
        
        
        // SMS sharing feature
        alert.addAction(UIAlertAction(title: "Invite friends to album (SMS)", style: .Default, handler: { action in
            
            var params = [ "referringUsername": "friend", "referringOut": "FSVC", "eventId":"\(self.eventId!)", "eventTitle": "\(self.eventTitle!)"]
            //var params = [ "referringUsername": "friend", "referringOut": "FSVC", "eventId": "\(self.objectIdTemp)", "albumId":"\(self.eventId!)", "eventTitle": "\(self.eventTitle!)"]
            //        [ "referringUsername": "friend", "referringUserId": "6",  "eventId": "\(self.eventId)", "pictureId": "\(self.objectIdTemp)", "pictureCaption": "\(self.eventTitle)" ]
            
            // This is making an asynchronous call to Branch's servers to generate the link and attach the information provided in the params dictionary --> so inserted spinner code to notify user program is running
            
            self.spinner.startAnimating()
            //disable button
            
            Branch.getInstance().getShortURLWithParams(params, andChannel: "SMS", andFeature: "Referral", andCallback: { (url: String!, error: NSError!) -> Void in
                if (error == nil) {
                    if MFMessageComposeViewController.canSendText() {
                        
                        let messageComposer = MFMessageComposeViewController()
                        
                        messageComposer.body = String(format: "Check out these photos on Backflip! %@", url)
                        
                        messageComposer.messageComposeDelegate = self
                        
                        self.presentViewController(messageComposer, animated: true, completion:{(Bool) in
                            // stop spinner on main thread
                            self.spinner.stopAnimating()
                        })
                    } else {
                        
                        self.spinner.stopAnimating()
                        
                        var alert = UIAlertController(title: "Error", message: "Your device does not allow sending SMS or iMessages.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            })
        }))

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

    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        //--------------- Draw UI ---------------

        // Hide UI controller item
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        // Nav Bar positioning
        let navBar = UINavigationBar(frame: CGRectMake(0,0,self.view.frame.size.width, 64 ))
        navBar.backgroundColor =  UIColor.whiteColor()
        
//        // Removes faint line under nav bar
//        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        navBar.shadowImage = UIImage()
        
        // Set the Nav bar properties
        let navBarItem = UINavigationItem()
//        var shortTitle: String?
//        if (count(eventTitle) > 25) {
//            shortTitle = eventTitle?.substringToIndex(25) + " . . ."
//            navBarItem.title = shortTitle
//        }
        navBarItem.title = eventTitle
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Avenir-Medium",size: 18)!]
        //navBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
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

        //----------- Query for image display----------
        var getUploadedImages = PFQuery(className: "Event")
        getUploadedImages.limit = 1
        getUploadedImages.whereKey("objectId", equalTo: eventId!)
        
        // Retrieval from corresponding photos from relation to event
        var object = getUploadedImages.findObjects()?.first as! PFObject
        
        var photos = object["photos"] as! PFRelation
        var tempImage: PFFile?
        // Finds associated photo object in relation
        var photoList = photos.query()?.getObjectWithId(objectIdTemp)
        self.tempDate = photoList?.createdAt
        
        // Once retrieved from relation, set the UIImage view for fullscreen view
        tempImage = photoList!.objectForKey("image") as? PFFile

        tempImage!.getDataInBackgroundWithBlock{ (imageData, error) -> Void in
                    
                    if error == nil {
                        
                        self.fullScreenImage.image = UIImage(data: imageData!)
                        
                    } else {
                        
                        println(error)
                    }
            }
        
        //----------- Query for Like Image label----------
        var query5 = PFQuery(className: "Event")
        
        query5.whereKey("objectId", equalTo: eventId!)
        
        var eventObject = query5.findObjects()?.first as! PFObject
        var relation = eventObject["photos"] as! PFRelation
        
        // User like list that will be filled
        var likeList : [String]
        
        // Finds associated photo object in relation
        var likeRetrieve = relation.query()?.getObjectWithId(objectIdTemp)
        
        // Fill the like list with the user liked list array from photo relation
        likeList = (likeRetrieve!.objectForKey("usersLiked") as? [String])!
        
        // Iterate through the like list to check if user has liked it
        for users in likeList {
            
            if users == PFUser.currentUser()?.username {
                
                self.likeActive = true
                self.likeButtonLabel.setImage(self.liked, forState: .Normal)
                
            } else {
                
                self.likeActive = false
                self.likeButtonLabel.setImage(self.unliked, forState: .Normal)
                
            }
            
        }
        let count = likeList.count

        if (count == 1) {
            self.likeCount.text = String(count) + " like"
        } else {
            self.likeCount.text = String(count) + " likes"
        }
        
        
//        //----------- Query for Like Count Label----------
//        var query6 = PFQuery(className: "Event")
//        
//        query6.whereKey("objectId", equalTo: eventId!)
//        
//        var events = query5.findObjects()?.first as! PFObject
//        var relations = eventObject["photos"] as! PFRelation
//        
//        // User like list that will be filled
//        var likeUserList : [String]
//        
//        // Finds associated photo object in relation
//        var likesRetrieved = relation.query()?.getObjectWithId(objectIdTemp)
//        
//        // Fill the like list with the user liked list array from photo relation
//        likeUserList = (likesRetrieved!.objectForKey("usersLiked") as? [String])!
//        
//        let count = likeUserList.count
//        
//        if (count == 1) {
//            
//            self.likeCount.text = String(count) + " like"
//            
//        } else {
//            
//            self.likeCount.text = String(count) + " likes"
//        }
        
        
        if tempDate != nil {
            
            //formatting to display date how we want it
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.timeStyle = .ShortStyle
            let dateStamp = formatter.stringFromDate(tempDate!)
    
            eventInfo.text = "Photo taken on \(dateStamp)"
            
        }
        
        
        
        // gesture implementation
        var gesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        gesture.numberOfTapsRequired = 2
        
        fullScreenImage.userInteractionEnabled = true
        fullScreenImage.addGestureRecognizer(gesture)
        
        self.view.bringSubviewToFront(likeCount)

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
