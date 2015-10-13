//
//  albumViewCell.swift
//  Backflip
//
//  Created by Jonathan Arlauskas on 2015-06-01.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

public class AlbumViewCell: UICollectionViewCell
{
    
    public var imageView: UIImageView?

	public var imageUrl: NSURL?


	override public init(frame: CGRect)
	{
		super.init(frame: frame)

		imageView = UIImageView(frame: self.bounds)
		self.backgroundView?.addSubview(imageView!)
	}

	required public init?(coder aDecoder: NSCoder)
	{
	    super.init(coder: aDecoder)

		imageView = UIImageView(frame: self.bounds)
		self.backgroundView?.addSubview(imageView!)
	}





	override public func prepareForReuse()
	{
		super.prepareForReuse()

		self.imageUrl = nil
		self.imageView?.image = nil
		self.imageView?.tintColor = nil
	}
	
	override public func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.imageView?.frame = self.bounds
	}
}
