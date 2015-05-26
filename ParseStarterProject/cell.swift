//
//  cell.swift
//  ParseStarterProject
//
//  Created by Jonathan Arlauskas on 2015-05-13.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class cell: UITableViewCell, UIGestureRecognizerDelegate {

//cell class, each photo is a class, feedViewController uses instances of cell class
    @IBOutlet var username: UILabel!
    
    @IBOutlet var title: UILabel!

    @IBOutlet var postedImage: UIImageView!
    

   /* @IBAction func fullView(sender: AnyObject) {
    
        func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
            
            println ("test")
            if segue.identifier == "toFullScreen" {
                
                println("test")
                if let destViewController = segue.destinationViewController as? fullScreenViewController{
                println("test2")
                destViewController.cellImage = postedImage.image
                println("test3")
                destViewController.eventTitle.text = testString
                }
                
            }
        }
    
    }*/
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        /*let tapGesture = UITapGestureRecognizer(target: self, action: "tapGesture:")
        
        postedImage.addGestureRecognizer(tapGesture)
        postedImage.userInteractionEnabled = true*/
    }
    
    /*func tapGesture(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if let postedImage = gesture.view as? UIImageView {  // if you subclass UIImageView, then change "UIImageView" to your subclass
            
            // if you subclass UIImageView, then you could get the filename here.
        }
    }*/
    
    /*func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    
    println("test")
    
        if segue.identifier == "toFullScreen" {
            
            var destViewController = segue.destinationViewController as! fullScreenViewController

                destViewController.cellImage = postedImage.image
                destViewController.eventTitle.text = test
            
            
            
        }
    }*/

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
