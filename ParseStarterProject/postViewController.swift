//
//  postViewController.swift
//  ParseStarterProject
//
//  Created by Jonathan Arlauskas on 2015-05-13.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class postViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    var photoSelected:Bool = false
    
    //define activity indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    

    //function for displaying our pop up alerts
    func displayAlert(title:String,error: String) { //takes a title and an error
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //We can set placeholder image here if we want
    @IBOutlet var imageToPost: UIImageView!
    
    
    @IBAction func logout(sender: AnyObject) {
        
        //disables current user
        PFUser.logOut()
        
        self.performSegueWithIdentifier("logout", sender: self)
        
        println(PFUser.currentUser())
        
    }
  
    
    @IBAction func chooseImage(sender: AnyObject) {
        
        
    //necessary code for accessing image from our camera roll
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary //cant use camera on simulator, switch for camera to open camera
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil) //opens up the photo library for selection
        
    }
    
    @IBOutlet var shareText: UITextField!
    
    
    @IBAction func postImage(sender: AnyObject) {
        //need to check that they have selected an image, and that text has been added
        
        var error = ""
        
        if photoSelected == false {
            
            error = "Please select an image to post"
            
            
        } else if (shareText.text == "") { //not necessary if we dont want captions
            
            error = "Please enter a caption"
        }
        
        if (error != "") {
            
            displayAlert("Error: Cannot post Image", error: error) //displays the error pop up
            
        } else {
            
            //activity indicator code, posting photo
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()

            
            
            var post = PFObject(className: "Post")
            post["Title"] = shareText.text //save the text, and object, then add image to it
            post["username"] = PFUser.currentUser()!.username
            
            post.saveInBackgroundWithBlock{(success, error) -> Void in
            
            if success == false {
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                
                //closure, we need self.
                self.displayAlert("Could Not Post Image", error: "Please try again")
            
            
            
            } else{
                
                //takes image stored in "imagetoPost" and stores to variable
                let imageData = UIImagePNGRepresentation(self.imageToPost.image)
                
                //create file for parse to upload to service
                let imageFile = PFFile(name: "image.png", data: imageData)
                
                post["imageFile"] = imageFile
                
                post.saveInBackgroundWithBlock{(success, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if success == false{
                        
                        self.displayAlert("Could Not Post Image", error: "Please try again")
                        
                    } else {
                        
                        self.displayAlert("Image Posted!", error: "Your image has been posted!")
                        
                        self.photoSelected = false
                        
                        self.imageToPost.image = nil
                        //sets image back to original one
                        //can do UIImage(named: "file_name")
                        
                        self.shareText.text = ""
                        
                        
                        
                        println("post successfully")
                        
                        
                    }
                }
                
            }
            
        }
    }
        
    }
    
    
    //puts selected image in the placeholder
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        println("Image Selected")
        self.dismissViewControllerAnimated(true, completion: nil) //dismiss the popped up view controller
        
        imageToPost.image = image //image in the center is replaced with selected image
    
        photoSelected = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoSelected = false
        
        //nothing in placeholder
        imageToPost.image = nil
       
        //sets image back to original one
        shareText.text = ""

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
