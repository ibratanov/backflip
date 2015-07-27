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
        let barTint = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
        UITabBar.appearance().barTintColor = barTint
        
        // Set the color of the image and text when the tab is selected
        let selectedColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        UITabBar.appearance().tintColor = selectedColor
        
        // Set background selected image
        UITabBar.appearance().selectionIndicatorImage = UIImage(named: "tabBar-selectionIndicatorImage.pdf")
        
        // Choose and set the images for the tab bar icons
        first.image = UIImage(named: "tabBar-locator.pdf")
        second.image = UIImage(named: "tabBar-currentEvent.pdf")
        third.image = UIImage(named: "tabBar-eventHistory.pdf")
        
        
        // Set the titles underneath the tab bar icons
        first.title = "Check In"
        second.title = "Current Event"
        third.title = "Event History"
        
        // When selected, change the image icon to something else
        first.selectedImage = UIImage(named: "tabBar-locator-filled.pdf")
        second.selectedImage = UIImage(named: "tabBar-currentEvent-filled.pdf")
        third.selectedImage = UIImage(named: "tabBar-eventHistory-filled.pdf")

        
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
