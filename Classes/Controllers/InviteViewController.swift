//
//  InviteViewController.swift
//  Backflip
//
//  Created by MWars on 2015-06-17.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class InviteViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let imageView = UIImageView()
        self.view.addSubview(imageView)
        
        // post notification and pass imageview in userInfo
        
        NSNotificationCenter.defaultCenter().postNotificationName("MySetImageViewNotification", object: nil, userInfo: ["imageView": imageView])
        imageView.contentMode = .ScaleAspectFit
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let imageView = UIImageView()

        self.view.addSubview(imageView)
        NSNotificationCenter.defaultCenter().postNotificationName("MySetImageViewNotification", object: nil, userInfo: ["imageView": imageView])

    }


    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func downloadImage(sender: AnyObject) {
        
        
        if imageView.image != nil {
            
            UIImageWriteToSavedPhotosAlbum(imageView.image, nil, nil, nil)
            
            var alert = UIAlertController(title: "Success!", message: "Image saved to camera roll", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            
        } else {
            
            var alert = UIAlertController(title: "Error!", message: "No image saved!", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
