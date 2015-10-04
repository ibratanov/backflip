//
//  EventHistoryViewFlowLayout.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-09-24.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation


class EventHistoryViewFlowLayout : UICollectionViewFlowLayout
{
	
	override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
	{
		var attributes = super.layoutAttributesForElementsInRect(rect)
		let contentOffset = self.collectionView?.contentOffset
		
		let missingSections = NSMutableIndexSet()
		for layoutAttributes in attributes! {
			if (layoutAttributes.representedElementCategory == .Cell) {
				missingSections.addIndex(layoutAttributes.indexPath.section)
			}
		}
		
		for layoutAttributes in attributes! {
			if (layoutAttributes.representedElementKind == UICollectionElementKindSectionHeader) {
				missingSections.removeIndex(layoutAttributes.indexPath.section)
			}
		}
		
		
		for index in missingSections {
			let indexPath = NSIndexPath(forRow: 0, inSection: index)
			let layoutAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath)
			if (layoutAttributes != nil) {
				attributes?.append(layoutAttributes!)
			}
		}
		
		
		// Not fully sure what this does, it's late at night, I've been drinking and on Tinder
		// If you manage to figure this out, I'll buy you a beer (or 9)
		for layoutAttributes in attributes! {
			if (layoutAttributes.representedElementKind == UICollectionElementKindSectionHeader) {
				let section = layoutAttributes.indexPath.section
				let itemsInSection = self.collectionView?.numberOfItemsInSection(section)
				if (itemsInSection == 0) {
					continue
				}
				
				let firstCellIndexPath = NSIndexPath(forRow: 0, inSection: section)
				let lastCellIndexPath = NSIndexPath(forRow: max(0, (itemsInSection! - 1)), inSection: section)
				
				if (firstCellIndexPath.row < 0 || lastCellIndexPath.row < 0) {
					continue
				}
				
				let firstCellAttributes = self.layoutAttributesForItemAtIndexPath(firstCellIndexPath)
				let lastCellAttributes = self.layoutAttributesForItemAtIndexPath(lastCellIndexPath)
				
				let headerHeight = CGRectGetHeight(layoutAttributes.frame)
				var origin = layoutAttributes.frame.origin
				origin.y = min(max(contentOffset!.y, (CGRectGetMinY(firstCellAttributes!.frame)-headerHeight)), (CGRectGetMaxY(lastCellAttributes!.frame)-headerHeight))
				layoutAttributes.zIndex = 1024
				layoutAttributes.frame = CGRectMake(origin.x, origin.y, layoutAttributes.frame.size.width, layoutAttributes.frame.size.height)
			}
		}
		
		return attributes
	}
	
	override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool
	{
		return true
	}

}