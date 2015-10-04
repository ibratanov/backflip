//
//  NSObject+Swizzle.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-09-07.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Foundation

extension NSObject {
	
	class func swizzleMethodSelector(origSelector: String!, withSelector: String!, forClass:AnyClass!) -> Bool {
		
		var originalMethod: Method?
		var swizzledMethod: Method?
		
		originalMethod = class_getInstanceMethod(forClass, Selector.init(stringLiteral: origSelector))
		swizzledMethod = class_getInstanceMethod(forClass, Selector.init(stringLiteral: withSelector))
		
		if (originalMethod != nil && swizzledMethod != nil) {
			method_exchangeImplementations(originalMethod!, swizzledMethod!)
			return true
		}
		return false
	}
	
	class func swizzleStaticMethodSelector(origSelector: String!, withSelector: String!, forClass:AnyClass!) -> Bool {
		
		var originalMethod: Method?
		var swizzledMethod: Method?
		
		originalMethod = class_getClassMethod(forClass, Selector.init(stringLiteral: origSelector))
		swizzledMethod = class_getClassMethod(forClass, Selector.init(stringLiteral: withSelector))
		
		if (originalMethod != nil && swizzledMethod != nil) {
			method_exchangeImplementations(originalMethod!, swizzledMethod!)
			return true
		}
		return false
	}
}