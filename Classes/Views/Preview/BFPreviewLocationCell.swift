//
//  BFPreviewLocationCell.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-17.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import MapKit
import Foundation

public class BFPreviewLocationCell : UICollectionViewCell
{
	
	/**
	 * Reuse Identifier
	*/
	public static let reuseIdentifier: String = "preview-location-cell"
	
	
	/**
	 * Map View
	*/
	public var mapView: MKMapView!
	
	/**
	 * Header title
	*/
	private var titleView: BFPreviewTitleView!
	
	
	
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
	
	
	/**
	 * View creation
	*/
	private func loadView() -> Void
	{
		self.mapView = MKMapView(frame: CGRectZero)
		self.mapView.layer.borderColor = UIColor.lightGrayColor().CGColor
		self.mapView.layer.borderWidth = 0.5
		self.contentView.addSubview(self.mapView)
		
		self.titleView = BFPreviewTitleView(frame: CGRectZero)
		self.titleView.text = "Location"
		self.contentView.addSubview(self.titleView)
	}
	
	
	public override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.titleView.frame = CGRectMake(0, 0, self.frame.width, 20)
	}
	
}
