//
//  TableViewCell.swift
//  Backflip
//
//  Created by Cody Mazza-Anthony on 2015-06-12.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import ParseUI

class EventTableViewCell: UITableViewCell,UIGestureRecognizerDelegate {
    
    @IBOutlet var imageOne: PFImageView!
    
    @IBOutlet var imageTwo: PFImageView!
    
    @IBOutlet var imageThree: PFImageView!
    
    @IBOutlet var imageFour: PFImageView!
	
	@IBOutlet var imageFive: PFImageView!
    
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
        
        var bounds = UIScreen.mainScreen().bounds
        var width = bounds.size.width
        
        if width == 320 {
            
            imageOne.frame = CGRect(x: self.contentView.bounds.width - 3*80, y: self.contentView.bounds.height - 80, width: 80, height: 80)
            imageTwo.frame = CGRect(x: self.contentView.bounds.width - 2*80, y: self.contentView.bounds.height - 80, width: 80, height: 80)
            imageThree.frame = CGRect(x: self.contentView.bounds.width - 80, y: self.contentView.bounds.height - 80, width: 80, height: 80)
            imageFour.frame = CGRect(x: self.contentView.bounds.width, y: self.contentView.bounds.height - 80, width: 80, height: 80)
            
            
        } else if width == 375 {
            
            imageOne.frame = CGRect(x: self.contentView.bounds.width - 4*75, y: self.contentView.bounds.height - 75, width: 75, height: 75)
            imageTwo.frame = CGRect(x: self.contentView.bounds.width - 3*75, y: self.contentView.bounds.height - 75, width: 75, height: 75)
            imageThree.frame = CGRect(x: self.contentView.bounds.width - 2*75, y: self.contentView.bounds.height - 75, width: 75, height: 75)
            imageFour.frame = CGRect(x: self.contentView.bounds.width - 75, y: self.contentView.bounds.height - 75, width: 75, height: 75)
            imageFive.frame = CGRect(x: self.contentView.bounds.width, y: self.contentView.bounds.height - 75, width: 75, height: 75)
            
            
        } else if width == 414 {
            imageOne.frame = CGRect(x: self.contentView.bounds.width - 4*82.8, y: self.contentView.bounds.height - 82.8, width: 82.8, height: 82.8)
            imageTwo.frame = CGRect(x: self.contentView.bounds.width - 3*82.8, y: self.contentView.bounds.height - 82.8, width: 82.8, height: 82.8)
            imageThree.frame = CGRect(x: self.contentView.bounds.width - 2*82.8, y: self.contentView.bounds.height - 82.8, width: 82.8, height: 82.8)
            imageFour.frame = CGRect(x: self.contentView.bounds.width - 82.8, y: self.contentView.bounds.height - 82.8, width: 82.8, height: 82.8)
            imageFive.frame = CGRect(x: self.contentView.bounds.width , y: self.contentView.bounds.height - 82.8, width: 82.8, height: 82.8)
        }
    }
    
}