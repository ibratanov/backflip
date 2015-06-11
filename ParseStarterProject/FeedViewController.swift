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
    
    //let information = (title: String(), user: String(), image: PFFile(), date: NSDate(), id: String())
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var getUploadedImages = PFQuery(className: "Photo")
        //getUploadedImages.whereKey("username", equalTo: followedUser)
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
            moveVC.tempTitle = captions[selectedRowIndex!.row]
            //moveVC.tempDate = dates[selectedRowIndex!.row]
            moveVC.objectIdTemp = objectIDs[selectedRowIndex!.row]
       
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
