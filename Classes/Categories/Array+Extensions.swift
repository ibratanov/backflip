//
//  Array+Extensions.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-24.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Foundation


extension Array {
	func contains<U: Equatable>(object:U) -> Bool {
		return (self.indexOf(object) != nil);
	}
	
	func indexOf<U: Equatable>(object: U) -> Int? {
		for (idx, objectToCompare) in enumerate(self) {
			if let to = objectToCompare as? U {
				if object == to {
					return idx
				}
			}
		}
		return nil
	}
	
	mutating func removeObject<U: Equatable>(object: U) {
		let index = self.indexOf(object)
		if(index != nil) {
			self.removeAtIndex(index!)
		}
	}
}