//
//  albumViewCell.swift
//  Backflip
//
//  Created by Jonathan Arlauskas on 2015-06-01.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class AlbumViewCell: UICollectionViewCell
{
    
    @IBOutlet weak var imageView: UIImageView!
	
	
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
