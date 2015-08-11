//
//  BFCollectionViewFlowLayout.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-07.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Foundation

class BFCollectionViewFlowLayout : UICollectionViewFlowLayout
{
	
	
	override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool
	{
		return true
	}
	
	
	override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]?
	{
		var attributes : [UICollectionViewLayoutAttributes] = super.layoutAttributesForElementsInRect(rect) as! [UICollectionViewLayoutAttributes]
		
		var footerIndex : NSIndexPath?
		for  attribute in attributes {
			if attribute.representedElementKind == UICollectionElementKindSectionFooter {
				footerIndex = attribute.indexPath
				self.updateFooterAttributes(attribute)
			}
		}
		
		
		if (footerIndex == nil) {
			
			let indexPath : NSIndexPath = NSIndexPath(forItem: attributes.count, inSection: 0)
			attributes.append(self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionFooter, atIndexPath: indexPath))
		}
		
		return attributes
	}
	
	override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes!
	{
		let attributes = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)
		// attributes.size = CGSizeMake(self.collectionView!.bounds.size.width, 44)
		if (elementKind == UICollectionElementKindSectionFooter) {
			self.updateFooterAttributes(attributes)
		}
		
		return attributes
	}
		
	
	func updateFooterAttributes(attributes: UICollectionViewLayoutAttributes)
	{
		let bounds = self.collectionView?.bounds
		attributes.zIndex = 1
		attributes.hidden = false
		
		let yCenterOffset = bounds!.origin.y + bounds!.size.height - attributes.size.height/2
		// attributes.center = CGPointMake(CGRectGetMidY(bounds!), yCenterOffset)
	}
	
}



extension Array{
	func enumerateObjectsUsingBlock(enumerator:(obj:Any, idx:Int, inout stop:Bool)->Void){
		for (i,v) in enumerate(self){
			var stop:Bool = false
			enumerator(obj: v, idx: i,  stop: &stop)
			if stop{
				break
			}
		}
	}
}