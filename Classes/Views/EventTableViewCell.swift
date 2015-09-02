//
//  TableViewCell.swift
//  Backflip
//
//  Created by Cody Mazza-Anthony on 2015-06-12.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import ParseUI

class EventTableViewCell: UITableViewCell, UIGestureRecognizerDelegate {

    let imageOne = UIImageView()
    let imageTwo = UIImageView()
    let imageThree = UIImageView()
    let imageFour = UIImageView()
    let imageFive = UIImageView()

    @IBOutlet var eventName: UILabel!

    @IBOutlet var eventLocation: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageOne.image = nil
        self.imageTwo.image = nil
        self.imageThree.image = nil
        self.imageFour.image = nil
        self.imageFive.image = nil
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = UIScreen.mainScreen().bounds
        let width = bounds.size.width
        
        // Sizing for iPhone 4/5, iPhone 6 Display Zoom
        if width == 320 {
            
            imageOne.frame = CGRect(x: self.contentView.bounds.width - 4*80, y: self.contentView.bounds.height - 80, width: 80, height: 80)
            imageTwo.frame = CGRect(x: self.contentView.bounds.width - 3*80, y: self.contentView.bounds.height - 80, width: 80, height: 80)
            imageThree.frame = CGRect(x: self.contentView.bounds.width - 2*80, y: self.contentView.bounds.height - 80, width: 80, height: 80)
            imageFour.frame = CGRect(x: self.contentView.bounds.width - 80, y: self.contentView.bounds.height - 80, width: 80, height: 80)
            
            self.contentView.addSubview(imageOne)
            self.contentView.addSubview(imageTwo)
            self.contentView.addSubview(imageThree)
            self.contentView.addSubview(imageFour)
            
        // Sizing for iPhone 6, 6Plus display zoom
        } else if width == 375 {
            
            imageOne.frame = CGRect(x: self.contentView.bounds.width - 5*75, y: self.contentView.bounds.height - 75, width: 75, height: 75)
            imageTwo.frame = CGRect(x: self.contentView.bounds.width - 4*75, y: self.contentView.bounds.height - 75, width: 75, height: 75)
            imageThree.frame = CGRect(x: self.contentView.bounds.width - 3*75, y: self.contentView.bounds.height - 75, width: 75, height: 75)
            imageFour.frame = CGRect(x: self.contentView.bounds.width - 2*75, y: self.contentView.bounds.height - 75, width: 75, height: 75)
            imageFive.frame = CGRect(x: self.contentView.bounds.width - 75, y: self.contentView.bounds.height - 75, width: 75, height: 75)
            
            self.contentView.addSubview(imageOne)
            self.contentView.addSubview(imageTwo)
            self.contentView.addSubview(imageThree)
            self.contentView.addSubview(imageFour)
            self.contentView.addSubview(imageFive)
            
        // Sizing for iPhone 6plus
        } else if width == 414 {
            imageOne.frame = CGRect(x: self.contentView.bounds.width - 5*82.8, y: self.contentView.bounds.height - 82.8, width: 82.8, height: 82.8)
            imageTwo.frame = CGRect(x: self.contentView.bounds.width - 4*82.8, y: self.contentView.bounds.height - 82.8, width: 82.8, height: 82.8)
            imageThree.frame = CGRect(x: self.contentView.bounds.width - 3*82.8, y: self.contentView.bounds.height - 82.8, width: 82.8, height: 82.8)
            imageFour.frame = CGRect(x: self.contentView.bounds.width - 2*82.8, y: self.contentView.bounds.height - 82.8, width: 82.8, height: 82.8)
            imageFive.frame = CGRect(x: self.contentView.bounds.width - 82.8 , y: self.contentView.bounds.height - 82.8, width: 82.8, height: 82.8)
            
            self.contentView.addSubview(imageOne)
            self.contentView.addSubview(imageTwo)
            self.contentView.addSubview(imageThree)
            self.contentView.addSubview(imageFour)
            self.contentView.addSubview(imageFive)
        }
    }
    
}