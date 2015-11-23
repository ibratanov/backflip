//
//  BFPreviewCell.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-18.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation

public class BFPreviewCell : UITableViewCell
{
	
	public override init(style: UITableViewCellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .None
	}
	
	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		self.selectionStyle = .None
	}
	
	
	
	public func configureCell(withEvent event: Event?) -> Void
	{
		
	}
	
	public func cellHeight() -> CGFloat
	{
		return 0.0
	}
	
}
