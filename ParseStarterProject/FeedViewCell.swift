//
//  cell.swift
//  ParseStarterProject
//
//  Created by Jonathan Arlauskas on 2015-05-13.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class FeedViewCell: UITableViewCell, UIGestureRecognizerDelegate {

    //FeedViewCell class, each photo is a class, feedViewController uses instances of cell class
    @IBOutlet var username: UILabel!
    
    @IBOutlet var title: UILabel!

    @IBOutlet var postedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
