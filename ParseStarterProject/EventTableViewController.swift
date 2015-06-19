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
    
    @IBAction func logoutButton(sender: AnyObject) {
        displayAlertLogout("Would you like to log out?", error: "")
    }
    
    func addEvent(sender: AnyObject) {
        performSegueWithIdentifier("addEventSegue", sender: nil)
    }
    
    var imageList: [PFFile] = []
    var events: [String] = []
    
    //test
    var eventObjs: [PFObject] = []
    
    var eventWithPhotos = [String:[PFFile]]()
    var eventWithPhotosID = [String:[PFFile]]()
    
    var logoutButton = UIImage(named: "settings-icon") as UIImage!
    var addButton = UIImage(named: "add-icon") as UIImage!

    
    var eventId: [String] = []
    var venues: [String] = []
    
//    Enable UI Navigation Itemr
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir-Medium",size: 18)!]
        self.tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //--------------- Draw UI ---------------
        
//        // Hide UI controller item
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        
//        // Nav Bar positioning
//        let navBar = UINavigationBar(frame: CGRectMake(0,0,self.view.frame.size.width, 64))
//        navBar.backgroundColor =  UIColor.whiteColor()
//        
//        // Removes faint line under nav bar
//        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        navBar.shadowImage = UIImage()
//        
//        // Set the Nav bar properties
//        let navBarItem = UINavigationItem()
//        navBarItem.title = "Event History"
//        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Avenir-Medium",size: 18)!]
//        navBar.items = [navBarItem]
//        
//        // Left nav bar button item
//        let logout = UIButton.buttonWithType(.System) as! UIButton
//        logout.setBackgroundImage(logoutButton, forState: .Normal)
//        logout.frame = CGRectMake(15, 31, 22, 22)
//        logout.addTarget(self, action: "logoutButton", forControlEvents: .TouchUpInside)
//        navBar.addSubview(logout)
//        
//        // Right nav bar button item
//        let add = UIButton.buttonWithType(.System) as! UIButton
//        add.setBackgroundImage(addButton, forState: .Normal)
//        add.frame = CGRectMake(self.view.frame.size.width-37,31,22,22)
//        add.addTarget(self, action: "addEvent", forControlEvents: .TouchUpInside)
//        navBar.addSubview(add)
//        
//        self.view.addSubview(navBar)

        var getUploadedImages = PFQuery(className: "Photo")
        getUploadedImages.limit = 40
        
        var objects = getUploadedImages.findObjects()
        for object in objects! {
            self.imageList.append(object["thumbnail"] as! PFFile)
        }

        updateEvents()
        
        //updatePhotosForEvent("4b71Y7QbXH")

    }
    
    
    func displayAlertLogout(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .Default, handler: { action in
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            
            
            PFUser.logOut()
            Digits.sharedInstance().logOut()
            
            self.performSegueWithIdentifier("logoutEventView", sender: self)
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func updateEvents(){
        //var query = PFQuery(className: "Event")

        let query = PFUser.query()
        query?.includeKey("savedEvents")
        query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
            self.eventObjs.removeAll(keepCapacity: true)
            //self.eventObjs = object["savedEvents"]// as! [PFObject]
            
            self.eventObjs = object!.objectForKey("savedEvents") as! [PFObject]
            for event in self.eventObjs {
                println(event)
                self.eventWithPhotos[event.objectId!] = self.updatePhotosForEvent(event.objectId!)
            }
            
        })
        
        //query event names, venues, and objectId
//        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
//            
//            self.events.removeAll(keepCapacity: true)
//            
//            for object in objects! {
//                
//                var eventName = object["eventName"] as! String
//                var objectId = object.objectId! as String!
//                var venue = object["venue"] as! String
//                
//                self.eventWithPhotos[eventName] = self.updatePhotosForEvent(objectId)
//                //self.eventWithPhotosID[objectId] = self.updatePhotosForEvent(objectId)
//                
//                self.events.append(eventName)
//                self.eventId.append(objectId)
//                self.venues.append(venue)
//                
//            }
//            print(self.eventWithPhotos)
//            self.tableView.reloadData()
//        })
        
        
    }
    
    func updatePhotosForEvent(objectId: String) -> [PFFile] {
        /*
        var query = PFQuery(className: "Event")
        query.orderByAscending("createdAt")
        
        query.includeKey("photos")
        query.whereKey("objectId", equalTo: "4b71Y7QbXH")
        */
        
        //var innerQuery = PFQuery(className: "Photo")
        //innerQuery.whereKeyExists("objectId")
        
        //Workspace - Get's photos liked by user
        /*
        var query = PFQuery(className: "EventAttendance")
        query.whereKey(<#key: String#>, matchesQuery: <#PFQuery#>)
        */
        
        ///////////////////////
        
        var query = PFQuery(className: "Event")
        query.whereKey("objectId", equalTo: objectId)
        
        var photoListForEvent: [PFFile] = []
        
        //query.whereKey("photos", equalTo: PFObject(withoutDataWithClassName: "Photo", objectId: "4b71Y7QbXH"))
        
        //TODO: Sort the photos to display the top 4 liked photos
        query.limit = 4
        var object = query.findObjects()?.first as! PFObject
        
        var photos = object["photos"] as! PFRelation
        
        var photoList = photos.query()?.findObjects() as! [PFObject]
        
        for photo in photoList {
            var image = photo["thumbnail"] as! PFFile
            photoListForEvent.append(image)
        }
        
        return photoListForEvent
        
        
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
        println("===================")
        println(Array(self.eventWithPhotos.keys))
        return Array(self.eventWithPhotos.keys).count
    }

    /*
    func getImageWithColor() -> UIImage {
        
        var color = CGColor
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
*/
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        
        let tableCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! EventTableViewCell
                //let albumCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AlbumViewCell
        tableCell.selectionStyle = UITableViewCellSelectionStyle.None
        println(self.eventWithPhotos)
        var key : String = Array(self.eventWithPhotos.keys)[indexPath.row]
        println("KEY-----------------")
        println(key)
        
        //var eventObjectId = self.eventId[indexPath.row]
        var listPhotos = self.eventWithPhotos[key] as [PFFile]!
        //var eventName = self.event
        println(self.events[indexPath.row])
//        println(self.events[indexPath.row])
//        println(key)
//        println(listPhotos)
//        println(self.eventWithPhotos)
        
        /*
        for (index,photo) in enumerate(listPhotos) {
            var imageData = listPhotos[index].getData()
            tableCell.image
            
        }
        
*/
        
        print(listPhotos.count)
        print(indexPath.row)
        
        var currentEvent = eventObjs[indexPath.row]
        println("REACHESHERE______________________")
        
        if listPhotos.count == 0 {
            tableCell.imageOne!.image = UIImage ()
            tableCell.imageTwo!.image = UIImage ()
            tableCell.imageThree!.image = UIImage ()
            tableCell.imageFour!.image = UIImage ()
            
            tableCell.eventName.text = key//"Event Name" + String(indexPath.row)
            tableCell.eventLocation.text = self.venues[indexPath.row]
            return tableCell
        }
        
        if listPhotos.count == 1 {
            var imageData1 = listPhotos[0].getData()
            tableCell.imageOne!.image = UIImage (data: imageData1!)
            
            tableCell.imageTwo!.image = UIImage ()
            tableCell.imageThree!.image = UIImage ()
            tableCell.imageFour!.image = UIImage ()
            
            tableCell.eventName.text = key//"Event Name" + String(indexPath.row)
            tableCell.eventLocation.text = self.venues[indexPath.row]
            
            return tableCell
        }
        
        if listPhotos.count == 2 {
            var imageData1 = listPhotos[0].getData()
            tableCell.imageOne!.image = UIImage (data: imageData1!)
            
            var imageData2 = listPhotos[1].getData()
            tableCell.imageTwo!.image = UIImage (data: imageData2!)
            
            tableCell.imageThree!.image = UIImage ()
            tableCell.imageFour!.image = UIImage ()
            
            
            tableCell.eventName.text = key //"Event Name" + String(indexPath.row)
            tableCell.eventLocation.text = self.venues[indexPath.row]
            
            return tableCell
        }
        
        if listPhotos.count == 3 {
            var imageData1 = listPhotos[0].getData()
            tableCell.imageOne!.image = UIImage (data: imageData1!)
            
            var imageData2 = listPhotos[1].getData()
            tableCell.imageTwo!.image = UIImage (data: imageData2!)
            
            var imageData3 = listPhotos[2].getData()
            tableCell.imageThree!.image = UIImage (data: imageData3!)
            
            tableCell.imageFour!.image = UIImage ()
            
            tableCell.eventName.text = key//"Event Name" + String(indexPath.row)
            tableCell.eventLocation.text = self.venues[indexPath.row]
            
            return tableCell
        }
        
        if listPhotos.count >= 4 {
            var imageData1 = listPhotos[0].getData()
            tableCell.imageOne!.image = UIImage (data: imageData1!)
            
            var imageData2 = listPhotos[1].getData()
            tableCell.imageTwo!.image = UIImage (data: imageData2!)
            
            var imageData3 = listPhotos[2].getData()
            tableCell.imageThree!.image = UIImage (data: imageData3!)
            
            var imageData4 = listPhotos[3].getData()
            tableCell.imageFour!.image = UIImage (data: imageData4!)
            
            tableCell.eventName.text = key//"Event Name" + String(indexPath.row)
            tableCell.eventLocation.text = self.venues[indexPath.row]
            return tableCell

        }
        
        
        
        /*
        var imageData1 = self.imageList[indexPath.row].getData()
        tableCell.imageOne!.image = UIImage (data: imageData1!)
        
        var imageData2 = self.imageList[indexPath.row+1].getData()
        tableCell.imageTwo!.image = UIImage (data: imageData2!)
        
        var imageData3 = self.imageList[indexPath.row+2].getData()
        tableCell.imageThree!.image = UIImage (data: imageData3!)
        
        var imageData4 = self.imageList[indexPath.row+2].getData()
        tableCell.imageFour!.image = UIImage (data: imageData4!)


        tableCell.eventName.text = self.events[indexPath.row]//"Event Name" + String(indexPath.row)
        tableCell.eventLocation.text = self.venues[indexPath.row]
        */
        
        return tableCell
    }
    
    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Facebook share feature
        alert.addAction(UIAlertAction(title: "Facebook", style: .Default, handler: { action in
            
           
        }))
        
        // Twitter share feature
        alert.addAction(UIAlertAction(title: "Twitter", style: .Default, handler: { action in
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
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
                println(events[selectedPath.row])
                println(eventId[selectedPath.row])
                //moveVC.eventId = Array(self.eventWithPhotosID.keys)[selectedPath.row]
                //moveVC.eventTitle = Array(self.eventWithPhotos.keys)[selectedPath.row]
                moveVC.eventId = eventId[selectedPath.row]
                moveVC.eventTitle = events[selectedPath.row]
                println("------------------------")
                println(moveVC.eventTitle)
                println(moveVC.eventId)
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
