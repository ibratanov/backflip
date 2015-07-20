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
    
    @IBOutlet var eventName: UILabel!
    
    @IBOutlet var eventLocation: UILabel!
    
}