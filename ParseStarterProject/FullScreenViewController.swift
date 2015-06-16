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
    
    @IBOutlet var likeCount: UILabel!
    
//    @IBOutlet var eventTitle: UILabel!
    
    @IBOutlet var eventInfo: UILabel!
    
    @IBOutlet var fullScreenImage: UIImageView!
    
    @IBOutlet var likeButtonLabel: UIButton!
    
    
    var cellImage : UIImage!
    var objectIdTemp : String = ""
    var likeActive = false
    var liked = UIImage(named: "heart-icon-filled.pdf") as UIImage!
    var unliked = UIImage(named: "heart-icon-empty.pdf") as UIImage!
    var back = UIImage(named: "back.pdf") as UIImage!
    
    // Title passed from previous VC
    var eventId : String?
    
    // function to handle double tap on image
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

    
    // both users and images have associated arrays with list of images liked for users, list of users who liked image, for images
    @IBAction func likeButton(sender: AnyObject) {
        
        if likeActive == false {
            
            // add username to photos list of users who liked
            var query1 = PFQuery(className: "Photo")
            
            query1.getObjectInBackgroundWithId (objectIdTemp) { (objects, error) -> Void in

                if error == nil {
                    
                    objects?.addUniqueObject(PFUser.currentUser()!.username!, forKey:"usersLiked")

                    let array = objects?.objectForKey("usersLiked") as! [String]
                    
                    objects?.incrementKey("upvoteCount", byAmount: 1)
                    
                    //TODO: is this more efficient or is it more efficient to get the upvoteCount value? Same below in "unlike"
                    let count = array.count
                    if (count == 1) {
                        self.likeCount.text = String(count) + " like"
                    } else {
                        self.likeCount.text = String(count) + " likes"
                    }
                    
                    // Add both photo object and id to arrays in user class
                    var query2 = PFUser.query()
                    
                    query2?.getObjectInBackgroundWithId (PFUser.currentUser()!.objectId!) { (object, error) -> Void in
                        
                        if error == nil {
                            
                            //print(image)
                            println(objects)
                            object?.addObject(objects!, forKey: "photoObjects")
                            
                            println("test2")
                            
                            object?.addUniqueObject(self.objectIdTemp, forKey:"photosLiked")
                            
                            object!.saveInBackground()
                            
                            
                        } else {
                            
                            println("Error: \(error!) \(error!.userInfo!)")
                        }
                    }
                    
                    objects!.saveInBackground()
                    
                } else {
                    
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
            
        } else {
            
            // remove user ID from list of users who liked photo
            var query3 = PFQuery(className: "Photo")
            
            query3.getObjectInBackgroundWithId (objectIdTemp) { (objects, error) -> Void in
                
                if error == nil {
                    
                    objects?.removeObject(PFUser.currentUser()!.username!, forKey:"usersLiked")
                    
                    
                    let array = objects?.objectForKey("usersLiked") as! [String]
                    
                    objects?.incrementKey("upvoteCount", byAmount: -1)
                    
                    let count = array.count
                    if (count == 1) {
                        self.likeCount.text = String(count) + " like"
                    } else {
                        self.likeCount.text = String(count) + " likes"
                    }
                    
                    // Remove photo ID to user photo liked list and photo object from photo object array
                    var query4 = PFUser.query()
                    
                    query4?.getObjectInBackgroundWithId (PFUser.currentUser()!.objectId!) { (object, error) -> Void in
                        
                        if error == nil {
                            
                            object?.removeObject(objects!, forKey: "photoObjects")
                            
                            object?.removeObject(self.objectIdTemp, forKey:"photosLiked")
                            
                            object!.saveInBackground()
                            
                        } else {
                            
                            println("Error: \(error!) \(error!.userInfo!)")
                            
                        }
                    }
 
                    objects!.saveInBackground()

                } else {
                    
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
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
            
            } else {
                
                var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            }))
        
        
        // SMS sharing feature
        alert.addAction(UIAlertAction(title: "Invite Friends (SMS)", style: .Default, handler: { action in
            
            var params = [ "referringUsername": "User1",
                "referringUserId": "12345",  "pictureId": "987666",
                "pictureURL": "http://yoursite.com/pics/987666",
                "pictureCaption": "BOOM" ]
            
            // this is making an asynchronous call to Branch's servers to generate the link and attach the information provided in the params dictionary --> so inserted spinner code to notify user program is running
            
            self.spinner.startAnimating()
            //disable button
            
            
            Branch.getInstance().getShortURLWithParams(params, andChannel: "SMS", andFeature: "Referral", andCallback: { (url: String!, error: NSError!) -> Void in
                if (error == nil) {
                    if MFMessageComposeViewController.canSendText() {
                        
                        let messageComposer = MFMessageComposeViewController()
                        
                        messageComposer.body = String(format: "Check this out: %@", url)
                        
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
    
    
    @IBAction func share(sender: AnyObject) {
        
         displayAlert("Share", error: "How do you want to share this photo?")
    }
  
    
    
    @IBAction func downloadImage(sender: AnyObject) {
        
        
        if fullScreenImage.image != nil {
            
            UIImageWriteToSavedPhotosAlbum(fullScreenImage.image, nil, nil, nil)
            
            saveImageAlert("Success!", error: "Image saved to camera roll")
            
            
        } else {
            
            saveImageAlert("Oops!", error: "Image could not save!")
        }
    }
    
    
    
    func saveImageAlert (title:String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
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
        
        // Removes faint line under nav bar
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        
        // Set the Nav bar properties
        let navBarItem = UINavigationItem()
        navBarItem.title = "Event Name"
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Avenir-Medium",size: 18)!]
//        navBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
        navBar.items = [navBarItem]
        
        // Left nav bar button item
        let back = UIButton.buttonWithType(.Custom) as! UIButton
        
        back.setTitleColor(UIColor.blackColor(), forState: .Normal)
        back.setImage(self.back, forState: .Normal)
        //back.setTitle("Back", forState: .Normal)
        back.frame = CGRectMake(15, 31, 22,22)
        back.addTarget(self, action: "seg", forControlEvents: .TouchUpInside)
        navBar.addSubview(back)
        
        // Right nav bar button item
        let shareAlbum = UIButton.buttonWithType(.Custom) as! UIButton
        shareAlbum.setTitleColor(UIColor.blackColor(), forState: .Normal)
        shareAlbum.setTitle("Action", forState: .Normal)
        shareAlbum.frame = CGRectMake(self.view.frame.size.width-37,31,22,22)
        shareAlbum.addTarget(self, action: nil, forControlEvents: .TouchUpInside)
        navBar.addSubview(shareAlbum)
        
        self.view.addSubview(navBar)


        var photoQuery = PFQuery(className: "Photo")
        
        photoQuery.getObjectInBackgroundWithId(objectIdTemp) { (objects, error) -> Void in
            
            if error == nil {
                
                var tempImage = objects?.objectForKey("image") as! PFFile
                var tempDate = objects?.createdAt! as NSDate!

                // check for date from previous VC, format and display the date
                if tempDate != nil {
                    
                    //formatting to display date how we want it
                    let formatter = NSDateFormatter()
                    
                    formatter.dateStyle = NSDateFormatterStyle.MediumStyle
                    
                    formatter.timeStyle = .ShortStyle
                    
                    let dateStamp = formatter.stringFromDate(tempDate)
                    
                    self.eventInfo.text = "Photo taken on \(dateStamp)"
                    
                } else {
                    
                    println("no date")
                    
                }
                
                tempImage.getDataInBackgroundWithBlock{ (imageData, error) -> Void in
                    
                    if error == nil {
                        
                        self.fullScreenImage.image = UIImage(data: imageData!)
                        
                    } else {
                        
                        println(error)
                    }

                }
                
            }
            
        }
        println(objectIdTemp)
        
        // block to check if user has already liked photo, and set button label accordingly
        var query5 = PFUser.query()
        
        query5?.whereKey("photosLiked", equalTo: objectIdTemp)
        
        query5?.getObjectInBackgroundWithId (PFUser.currentUser()!.objectId!) { (objects, error) -> Void in
            
            if error == nil {
                
                let array = objects?.objectForKey("photosLiked") as! [String]
                
                if contains(array, self.objectIdTemp) == true {
                    
                    self.likeActive = true
                    self.likeButtonLabel.setImage(self.liked, forState: .Normal)
                    
                } else {
                    self.likeActive = false
                    self.likeButtonLabel.setImage(self.unliked, forState: .Normal)
                    
                }
            }
        }
        
        
        // block to display current like count based on array size when view is loaded
        
        var query6 = PFQuery(className: "Photo")
        
        query6.getObjectInBackgroundWithId (objectIdTemp) { (objects, error) -> Void in
            
            if error == nil {
                
                let array = objects?.objectForKey("usersLiked") as! [String]
                let count = array.count
                if (count == 1) {
                    self.likeCount.text = String(count) + " like"
                } else {
                    self.likeCount.text = String(count) + " likes"
                }
                
            } else {
                
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
        
        // gesture implementation
        var gesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        gesture.numberOfTapsRequired = 2
        
        fullScreenImage.userInteractionEnabled = true
        fullScreenImage.addGestureRecognizer(gesture)
        
        self.view.bringSubviewToFront(likeCount)
    }
    
    /*@IBAction func shareButtonBeta(sender:UIButton){
        var params = [ "referringUsername": "User1",
            "referringUserId": "12345",  "pictureId": "987666",
        "pictureURL": "http://yoursite.com/pics/987666",
        "pictureCaption": "BOOM" ]
        
        // this is making an asynchronous call to Branch's servers to generate the link and attach the information provided in the params dictionary --> so inserted spinner code to notify user program is running
        
        self.spinner.startAnimating()
        //disable button
        
        
        Branch.getInstance().getShortURLWithParams(params, andChannel: "SMS", andFeature: "Referral", andCallback: { (url: String!, error: NSError!) -> Void in
            if (error == nil) {
                if MFMessageComposeViewController.canSendText() {
                    
                    let messageComposer = MFMessageComposeViewController()
                    
                    messageComposer.body = String(format: "Check this out: %@", url)
                    
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
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
