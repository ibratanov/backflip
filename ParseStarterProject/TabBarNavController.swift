//
//  TabBarNavController.swift
//  
//
//  Created by Jonathan Arlauskas on 2015-07-22.
//
//

import UIKit

class TabBarNavController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //----------------- Tab Bar UI -----------------------
        
        // Corresponding items in the tab bar
        var first = self.tabBar.items?[0] as! UITabBarItem
        var second = self.tabBar.items?[1] as! UITabBarItem
        var third = self.tabBar.items?[2] as! UITabBarItem
        
        // Change the tab bar background color
        let barTint = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        UITabBar.appearance().barTintColor = barTint
        
        // Set the color of the image and text when the tab is selected
        let selectedColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        UITabBar.appearance().tintColor = selectedColor
        
        // Choose and set the images for the tab bar icons
        let firstImage = UIImage(named: "heart-icon-empty.pdf")
        let secondImage = UIImage(named: "back.pdf")
        let thirdImage = UIImage(named: "heart-icon-filled.pdf")

        first.image = firstImage
        second.image = secondImage
        third.image = thirdImage
        
        
        // Set the titles underneath the tab bar icons
        first.title = "Check In"
        second.title = "Create Event"
        third.title = "Past Events"
        
        // When selected, change the image icon to something else
        first.selectedImage = secondImage
        second.selectedImage = thirdImage
        third.selectedImage = firstImage

        
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
