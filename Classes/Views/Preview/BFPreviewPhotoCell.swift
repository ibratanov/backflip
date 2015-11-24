//
//  BFPreviewPhotoCell.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-18.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation
import Kingfisher


public class BFPreviewPhotoCell : BFPreviewCell, UICollectionViewDataSource, UICollectionViewDelegate
{

	public static let identifier: String = "preview-photo-cell"
	
	/**
	* Collection View
	*/
	public var collectionView: UICollectionView!
	
	/**
	* Header title
	*/
	private var titleView: BFPreviewTitleView!

	/**
	 * Photos
	*/
	private var photos: [Photo] = []
	
	
	// ----------------------------------------
	//  MARK: - Initializers
	// ----------------------------------------
	
	public override init(style: UITableViewCellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)
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
		let flow = UICollectionViewFlowLayout()
		flow.itemSize = CGSizeMake(((self.frame.size.width - 10) / 3) - 1, ((self.frame.size.width - 10) / 3) - 1)
		flow.minimumInteritemSpacing = 1
		flow.minimumLineSpacing = 1
		flow.scrollDirection = .Vertical
		flow.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
		
		self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flow)
		self.collectionView.dataSource = self
		self.collectionView.delegate = self
		self.collectionView.backgroundColor = UIColor.whiteColor()
		self.collectionView.scrollEnabled = false
		self.collectionView.registerClass(BFPhotoCollectionViewCell.self, forCellWithReuseIdentifier: BFPhotoCollectionViewCell.reuseIdentifier)
		self.addSubview(self.collectionView)
		
		self.titleView = BFPreviewTitleView(frame: CGRectZero)
		self.titleView.text = "Photos"
		self.contentView.addSubview(self.titleView)
	}
	
	
	public override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.titleView.frame = CGRectMake(0, 0, self.frame.width, 20)
		self.collectionView.frame = CGRectMake(0, 25, self.frame.size.width, self.cellHeight())
		
		(self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSizeMake(((self.frame.size.width - 10) / 3) - 1, ((self.frame.size.width - 10) / 3) - 1)
	}
	
	
	//-------------------------------------
	// MARK: Cell Height
	//-------------------------------------
	
	public override func cellHeight() -> CGFloat
	{
		if (self.photos.count > 0) {
			let frame = UIApplication.sharedApplication().windows.first!.rootViewController!.view.frame
			let itemSize = CGSizeMake(((frame.size.width - 10) / 3) - 1, ((frame.size.width - 10) / 3) - 1)
			
			return 44.0 + (itemSize.height * CGFloat(self.photos.count / 3))
		}
	
		return 0
	}
	
	
	//-------------------------------------
	// MARK: Configuration
	//-------------------------------------
	
	public override func configureCell(withEvent event: Event?)
	{
		self.photos = event!.cleanPhotos
		// self.collectionView.reloadData()
	}
	
	
	
	//-------------------------------------
	// MARK: Collection View (Delegate)
	//-------------------------------------
	
	@available(iOS 6.0, *)
	public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return 1
	}
	
	@available(iOS 6.0, *)
	public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return self.photos.count
	}
	
	@available(iOS 6.0, *)
	public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BFPhotoCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as? BFPhotoCollectionViewCell
		
		cell?.contentView.layer.cornerRadius = 8.0
		
		return cell!
	}
	
	@available(iOS 6.0, *)
	public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
	{
		if (indexPath.row > -1) {
			guard let cell = cell as? BFPhotoCollectionViewCell else { fatalError("Expected to display a `BFPhotoCollectionViewCell`.") }
			
			let photo = self.photos[Int(indexPath.row)]
			let imageUrl = NSURL(string: photo.thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!
			cell.imageView.kf_setImageWithURL(imageUrl, placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(1))])
		}
	}
	
	
	
}
