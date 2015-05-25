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


class fullScreenViewController: UIViewController {
    
    @IBOutlet var likeCount: UILabel!
    
    @IBOutlet var eventTitle: UILabel!
    
    @IBOutlet var eventInfo: UILabel!
    
    @IBOutlet var fullScreenImage: UIImageView!
    
    @IBOutlet var likeButtonLabel: UIButton!
    
    var cellImage : UIImage!
    var tempTitle : String = ""
    var tempDate : NSDate!
    var objectIdTemp : String = ""
    var likeActive = false
    
    
    //toggles the like button from "like" to "unlike" when clicked
    @IBAction func likeToggle(sender: AnyObject) {
        
        if likeActive == false {
        
            likeActive = true

            likeButtonLabel.setTitle("Unlike", forState: UIControlState.Normal)
        
        } else {
        
            likeActive = false
            
            likeButtonLabel.setTitle("Like", forState: UIControlState.Normal)
        
        }
    }

    
    
    @IBAction func likeButton(sender: AnyObject) {
        
        if likeActive == false {
        
            
            //add username to photos list of users who liked
            var query3 = PFQuery(className: "Post")
            
            query3.getObjectInBackgroundWithId (objectIdTemp) { (objects, error) -> Void in
                
                if error == nil {
                    
                    objects?.addUniqueObject(PFUser.currentUser()!.username!, forKey:"photoLikeList")
                   
                    objects!.saveInBackground()
                    dump(objects)
                    

                } else {
                    
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
            
            //add photo ID to users list of photos liked
            var query4 = PFUser.query()
            
            query4?.getObjectInBackgroundWithId (PFUser.currentUser()!.objectId!) { (objects, error) -> Void in
                
                if error == nil {
                    
                    objects?.addUniqueObject(self.objectIdTemp, forKey:"photoLikeList")

                    objects!.saveInBackground()
                    dump(objects)
                    
                } else {
                    
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
            
        } else {
            
            //remove user ID from list of users who liked photo
            var query3 = PFQuery(className: "Post")
            
            query3.getObjectInBackgroundWithId (objectIdTemp) { (objects, error) -> Void in
                
                if error == nil {
                    
                    objects?.removeObject(PFUser.currentUser()!.username!, forKey:"photoLikeList")
 
                    objects!.saveInBackground()
                    dump(objects)
                    
                    
                    
                } else {
                    
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
            
            //remove photo ID to user photo liked list
            var query4 = PFUser.query()
            
            query4?.getObjectInBackgroundWithId (PFUser.currentUser()!.objectId!) { (objects, error) -> Void in
                
                if error == nil {
                    
                    objects?.removeObject(self.objectIdTemp, forKey:"photoLikeList")
                    

                    objects!.saveInBackground()
                    dump(objects)
                    
                    
                    
                } else {
                    
                    println("Error: \(error!) \(error!.userInfo!)")
                    
                }
            }
        }
    }

        
    
    
    
    
    func displayAlert(title:String,error: String) {
    
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
            
        //Facebook share feature
        alert.addAction(UIAlertAction(title: "Facebook", style: .Default, handler: { action in
            
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
                var facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                facebookSheet.setInitialText("Share on Facebook")
                
                facebookSheet.addImage(self.fullScreenImage.image)
                
                self.presentViewController(facebookSheet, animated: true, completion: nil)
           
            } else {
                var alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            }))
            
        //Twitter share feature
        alert.addAction(UIAlertAction(title: "Twitter", style: .Default, handler: { action in
            
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
                
                var twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                twitterSheet.setInitialText("Share on Twitter")
                
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
    
    
    
    func saveImageAlert (title:String, error: String){
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }


    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        //check for image from previous VC, if true, set the image
        if((cellImage) != nil) {
            
            self.fullScreenImage.image = cellImage
            
        } else {
        
        println("empty")
        
        }
        
        //check for title/event name from previous VC, display the title
        if tempTitle != "" {
            
            eventTitle.text = tempTitle
            
        }
        
        //check for date from previous VC, format and display the date
        if tempDate != nil {
            
            //formatting to display date how we want it
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.timeStyle = .MediumStyle
            let dateStamp = formatter.stringFromDate(tempDate)

            eventInfo.text = "Photo taken on \(dateStamp)"
            
        }
        
        
        
        
        

    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
