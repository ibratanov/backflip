//
//  BFPhotoCollectionViewCell.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-18.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Foundation

public class BFPhotoCollectionViewCell : UICollectionViewCell
{

	/**
	 * Reuse Identifier
	*/
	public static let reuseIdentifier = "photo-cell-identifier"
	
	
	/**
	 * Image View
	*/
	public var imageView: UIImageView!
	
	
	// ----------------------------------------
	//  MARK: - Initializers
	// ----------------------------------------
	
	public override init(frame: CGRect)
	{
		super.init(frame: frame)
		self.loadView()
	}
	
	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		self.loadView()
	}
	
	
	// ----------------------------------------
	//  MARK: - View loading
	// ----------------------------------------
	
	private func loadView()
	{
		self.imageView = UIImageView(frame: CGRectZero)
		self.imageView.backgroundColor = UIColor(red:0.863,  green:0.867,  blue:0.875, alpha:1)
		self.contentView.addSubview(self.imageView)
		
		self.imageView.layer.cornerRadius = 8.0
		self.imageView.layer.masksToBounds = true
		self.contentView.layer.cornerRadius = 8.0
		self.contentView.layer.masksToBounds = true
	}
	
	
	// ----------------------------------------
	//  MARK: - View Layout
	// ----------------------------------------
	
	public override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.imageView.frame = CGRectMake(2.5, 2.5, self.frame.size.width - 5, self.frame.size.height - 5)
	}
	
}
