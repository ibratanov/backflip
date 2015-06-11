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

class FullScreenViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var likeCount: UILabel!
    
    @IBOutlet var eventTitle: UILabel!
    
    @IBOutlet var eventInfo: UILabel!
    
    @IBOutlet var fullScreenImage: UIImageView!
    
    @IBOutlet var likeButtonLabel: UIButton!
    
    
    var cellImage : UIImage!
    var tempTitle : String = ""
    var objectIdTemp : String = ""
    var likeActive = false
    var liked = UIImage(named: "liked.png") as UIImage!
    var unliked = UIImage(named: "unliked.png") as UIImage!
    
    
    // function to handle double tap on image
    func handleTap (sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended {
            
            likeButton(self)
            likeToggle(self)
            
        }
    }
    
    
    
    
    
    // toggles the like button from "like" to "unlike" when clicked
    @IBAction func likeToggle(sender: AnyObject) {
        
        // adjust font size based on like count
        if (likeCount.text)!.toInt() > 9 {
            
            likeCount.font.fontWithSize(10)
            
        } else if (likeCount.text)!.toInt() > 99 {
            
            likeCount.font.fontWithSize(8)
        }

        
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
                    self.likeCount.text = String(array.count)
                    
                    objects!.saveInBackground()
                    
                } else {
                    
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
            
            // add photo ID to users list of photos liked
            var query2 = PFUser.query()
            
            query2?.getObjectInBackgroundWithId (PFUser.currentUser()!.objectId!) { (objects, error) -> Void in
                
                if error == nil {
                    
                    objects?.addUniqueObject(self.objectIdTemp, forKey:"photosLiked")

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
                    
                    self.likeCount.text = String(array.count)
 
                    objects!.saveInBackground()

                } else {
                    
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
            
            // remove photo ID to user photo liked list
            var query4 = PFUser.query()
            
            query4?.getObjectInBackgroundWithId (PFUser.currentUser()!.objectId!) { (objects, error) -> Void in
                
                if error == nil {
                    
                    objects?.removeObject(self.objectIdTemp, forKey:"photosLiked")
                    

                    objects!.saveInBackground()

                } else {
                    
                    println("Error: \(error!) \(error!.userInfo!)")
                    
                }
            }
        }
    }

 
    
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

        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))

        self.presentViewController(alert, animated: true, completion: nil)
    
    }
    
    

    
    
    @IBAction func share(sender: AnyObject) {
        
         displayAlert("Share:", error: "Select an option")
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


    
    override func viewDidLoad() {
       
        super.viewDidLoad()

        var photoQuery = PFQuery(className: "Photo")
        
        photoQuery.getObjectInBackgroundWithId(objectIdTemp) { (objects, error) -> Void in
            
            if error == nil {
                
                var tempImage = objects?.objectForKey("image") as! PFFile
                self.eventTitle.text = objects?.objectForKey("caption") as? String
                var tempDate = objects?.createdAt! as NSDate!

                // check for date from previous VC, format and display the date
                if tempDate != nil {
                    
                    //formatting to display date how we want it
                    let formatter = NSDateFormatter()
                    
                    formatter.dateStyle = NSDateFormatterStyle.LongStyle
                    
                    formatter.timeStyle = .MediumStyle
                    
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
                self.likeCount.text = String(array.count)
                
            } else {
                
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //self.navigationController?.navigationBarHidden = true
        
        
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
