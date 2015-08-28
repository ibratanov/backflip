//
//  String+Extensions.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-28.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Foundation


extension String {
	
	func contains(find: String) -> Bool{
		return self.rangeOfString(find) != nil
	}
}