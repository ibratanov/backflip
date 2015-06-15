
//
//  CGRect+Extensions.swift
//  Backflip
//
//  Created by MWars on 2015-06-15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

extension CGRect {
    func scaledBy(scalar: CGFloat) -> CGRect {
        let newOrigin = CGPoint(x: origin.x * scalar, y: origin.y * scalar)
        let newSize = CGSize(width: width * scalar, height: height * scalar)
        return CGRect(origin: newOrigin, size: newSize)
    }
    
    func scaledBy(size: CGSize) -> CGRect {
        let newOrigin = CGPoint(x: origin.x * size.width, y: origin.y * size.height)
        let newSize = CGSize(width: width * size.width, height: height * size.height)
        return CGRect(origin: newOrigin, size: newSize)
    }
}