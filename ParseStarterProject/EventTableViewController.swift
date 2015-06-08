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
    

    
    var events = [""]
//    var following = [Bool]()
    
    var refresher: UIRefreshControl! //allows us to control the pull to refresh function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
                println(self.events)
                
                self.tableView.reloadData()

                
//                var user: PFUser = object as! PFUser
//
////                var isFollowing: Bool
//                
//                if user.username != PFUser.currentUser()?.username {
//                    
////                    self.users.append(user.username!)
//                    
//                    isFollowing = false
//                    
//                    var query = PFQuery(className:"followers")
//                    query.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
//                    query.whereKey("following", equalTo: user.username!)
//                    
//                    query.findObjectsInBackgroundWithBlock {
//                        (objects, error) -> Void in
//                        
//                        if error == nil {
//                            
//                            for object in objects! {
//                                
//                                isFollowing = true
//                            }
//                            
//                            self.following.append(isFollowing)
//                            
//                            self.tableView.reloadData()
//                            
//                        } else {
//                            println(error)
//                        }
//                        
//                        //stop animation when finished
//                        self.refresher.endRefreshing()
//
//                    }
//                }
                
            }
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
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
//        if following.count > indexPath.row{
//        
//            if following[indexPath.row] == true {
//                
//                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
//            }
//    
//        }
        
        cell.textLabel?.text = events[indexPath.row]

        return cell
    }
    
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println(indexPath.row)
        
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
    
        self.performSegueWithIdentifier("toAlbum", sender: self)

    
        //.self explanation: http://stackoverflow.com/questions/26108843/in-swift-what-is-the-difference-between-the-two-different-usages-of-self
    
//        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark.self {
//            
//            cell.accessoryType = UITableViewCellAccessoryType.None
//            
//            var query = PFQuery(className:"followers")
//            query.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
//            query.whereKey("following", equalTo: cell.textLabel!.text!)
//            
//            query.findObjectsInBackgroundWithBlock {
//                (objects: [AnyObject]?, error: NSError?) -> Void in
//                
//                if error == nil {
//                    for object in objects! {
//                            
//                        object.deleteInBackground()
//                        
//                    }
//                } else {
//                    println(error)
//                }
//            }
//            
//        } else {
//    
//            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
//            
//            var following = PFObject(className: "followers")
//            
//            following["following"] = cell.textLabel?.text
//            following["follower"] = PFUser.currentUser()!.username
//            
//            following.saveInBackground() //save our selections
//        }
    
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
