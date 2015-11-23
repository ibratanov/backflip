//
//  EventAlbumCell.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-21.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Nuke
import UIKit


class EventAlbumCell : UICollectionViewCell
{
	static let reuseIdentifier = "event-album-cell-identifier"
	
	#if os(tvOS)
		@IBOutlet weak var label: UILabel!
	#endif
	
	@IBOutlet weak var imageView : UIImageView!
	
	
	var representedPhoto : Photo?
	
	
	override func layoutSubviews()
	{
		super.layoutSubviews()
		self.addSubview(self.imageView)
		self.imageView.frame = self.frame
	}
	
	
	override func awakeFromNib()
	{
		super.awakeFromNib()
		
		#if os(tvOS)
			imageView.adjustsImageWhenAncestorFocused = true
		#endif
		
		self.backgroundColor = UIColor(red:0.863,  green:0.867,  blue:0.875, alpha:1)
		
		imageView.contentMode = .ScaleToFill
		imageView.clipsToBounds = false
	}
	
	
	override func prepareForReuse()
	{
		super.prepareForReuse()
		
		#if os(tvOS)
			self.label?.alpha = 1.0
		#endif
	}
	

	@available(iOS 9.0, *)
	override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator)
	{
		#if os(tvOS)
			/*
				Update the label's alpha value using the `UIFocusAnimationCoordinator`.
				This will ensure all animations run alongside each other when the focus
				changes.
			*/
			coordinator.addCoordinatedAnimations({ [unowned self] in
				if self.focused {
					self.label?.alpha = 0.0
				} else {
					self.label?.alpha = 1.0
				}
			}, completion: nil)
			
		#endif
	}
	
}
