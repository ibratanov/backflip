//
//  UserTableViewController.swift
//  ParseStarterProject
//
//  Created by Zachary Lefevre on 2015-05-11.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import DigitsKit

class EventTableViewController: UITableViewController {
    
    
    var imageList: [PFFile] = []
    var events: [String] = []
    var eventId: [String] = []

    var refresher: UIRefreshControl! //allows us to control the pull to refresh function
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        var getUploadedImages = PFQuery(className: "Photo")
        getUploadedImages.limit = 40
        
        var objects = getUploadedImages.findObjects()
        for object in objects! {
            self.imageList.append(object["thumbnail"] as! PFFile)
        }

        
        updateEvents()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh") //text that appears
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged) //run this method when value is changed

        self.tableView.addSubview(refresher)

    }
    
    func updateEvents(){
        var query = PFQuery(className: "Event")
        
        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            self.events.removeAll(keepCapacity: true)
            
            for object in objects! {

                self.events.append((object["eventName"] as! String))
                self.eventId.append(object.objectId! as String!)
                println(self.events)
                
                self.tableView.reloadData()
                
            }
            //dump(self.events)
            self.refresher.endRefreshing()
        })
    }
    
    func refresh() {
        
        println("refreshed")
        
        updateEvents()
        
    }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //println(PFUser.currentUser())

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println(following)
        return events.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        let tableCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! EventTableViewCell
                //let albumCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AlbumViewCell
    
        var imageData1 = self.imageList[indexPath.row].getData()
        tableCell.imageOne!.image = UIImage (data: imageData1!)
        
        var imageData2 = self.imageList[indexPath.row+1].getData()
        tableCell.imageTwo!.image = UIImage (data: imageData2!)
        
        var imageData3 = self.imageList[indexPath.row+2].getData()
        tableCell.imageThree!.image = UIImage (data: imageData3!)
        
        var imageData4 = self.imageList[indexPath.row+2].getData()
        tableCell.imageFour!.image = UIImage (data: imageData4!)
        
        tableCell.eventName.text = "Event Name" + String(indexPath.row)
        tableCell.eventLocation.text = "Event Location" + String(indexPath.row)
        
        
        return tableCell
    }
    
   /*override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println(indexPath.row)
        
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
    
        self.performSegueWithIdentifier("toAlbum", sender: self)
    }*/

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toAlbum" {
            
            let moveVC = segue.destinationViewController as! AlbumViewController
            //self.navigationController?.popViewControllerAnimated(true)
            
            if let selectedPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                moveVC.eventId =  eventId[selectedPath.row]
            }
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
