//
//  fullScreenViewController.swift
//  ParseStarterProject
//
//  Created by Jonathan Arlauskas on 2015-05-18.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Social

class fullScreenViewController: UIViewController {
    
    @IBOutlet var eventTitle: UILabel!
    
    var cellImage : UIImage!
    
    @IBOutlet var fullScreenImage: UIImageView!
    
    func displayAlert(title:String,error: String) {
    
    var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
    //Facebook share feature
    alert.addAction(UIAlertAction(title: "Facebook", style: .Default, handler: { action in
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            var facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Share on Facebook")
            
            //facebookSheet.addImage(image)
            
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
            
            //twitterSheet.addImage(image)
            
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        }))

    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
    
    //set to false, to prevent login screen flashes on failed login attempt
    self.dismissViewControllerAnimated(false, completion: nil)
    
    }))

    self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func share(sender: AnyObject) {
        
        displayAlert("Share:", error: "Select an option")
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if((fullScreenImage.image) != nil) {
            
        self.fullScreenImage.image = cellImage
            
        }

        // Do any additional setup after loading the view.
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
