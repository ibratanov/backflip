//
//  TableViewCell.swift
//  Backflip
//
//  Created by Cody Mazza-Anthony on 2015-06-12.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell,UIGestureRecognizerDelegate {
    
    @IBOutlet var imageOne: UIImageView!
    
    @IBOutlet var imageTwo: UIImageView!
    
    @IBOutlet var imageThree: UIImageView!
    
    @IBOutlet var imageFour: UIImageView!
    
    @IBOutlet var eventName: UILabel!
    
    @IBOutlet var eventLocation: UILabel!
    
}