//
//  albumViewCell.swift
//  ParseStarterProject
//
//  Created by Jonathan Arlauskas on 2015-06-01.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import ParseUI

class AlbumViewCell: UICollectionViewCell {

    //@IBOutlet var imageView: PFImageView?
    
    @IBOutlet weak var imageView: PFImageView!

	
	override func prepareForReuse()
	{
		super.prepareForReuse()
		
		self.imageView.image = nil
		self.imageView.tintColor = nil
	}
	
	override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.imageView.frame = self.bounds
	}
}
