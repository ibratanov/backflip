//
//  feedViewController.swift
//  ParseStarterProject
//
//  Created by Jonathan Arlauskas on 2015-05-13.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UITableViewController {

//we need to create a new class for each image
//various arrays for storing data
    
    var captions = [String]()
    var usernames = [String]()
    var images = [UIImage]()
    var imageFiles = [PFFile]()
    var dates = [NSDate]()
    var objectIDs = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var getUploadedImages = PFQuery(className: "Photo")
        getUploadedImages.findObjectsInBackgroundWithBlock {

            (objects, error) -> Void in

            if error == nil {

                for object in objects! {

                    self.captions.append(object["caption"] as! String)
                    self.imageFiles.append(object["image"] as! PFFile)
                    self.usernames.append(object["uploaderName"] as! String)
                    self.dates.append(object.createdAt as NSDate!)

                    self.objectIDs.append(object.objectId!! as String)

                    self.tableView.reloadData()

                }
                
            } else {
                println(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
        return 1
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return captions.count
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 240
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var myCell:FeedViewCell = self.tableView.dequeueReusableCellWithIdentifier("myCell") as! FeedViewCell
      
        myCell.title.text = captions[indexPath.row]
        myCell.username.text = usernames[indexPath.row]
        
        //gets image file of what we are interested in
        imageFiles[indexPath.row].getDataInBackgroundWithBlock{
            (imageData, error) -> Void in
            
            if error == nil{
                
                let image = UIImage(data: imageData!)
                self.images.append((image)!)
                
                myCell.postedImage.image = image
            }
            
            
        }
        
        return myCell
    }
    
   override  func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toFullScreen" {
            
            var moveVC: FullScreenViewController = segue.destinationViewController as! FullScreenViewController
            
            //get the selected row number
            var selectedRowIndex = self.tableView.indexPathForSelectedRow()

            moveVC.cellImage = images[selectedRowIndex!.row]
            moveVC.objectIdTemp = objectIDs[selectedRowIndex!.row]
       
        }
    }

}
