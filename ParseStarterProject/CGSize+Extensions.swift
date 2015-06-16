//
//  CGSize+Extensions.swift
//  Backflip
//
//  Created by MWars on 2015-06-15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

extension CGSize {
    func maxDimension() -> CGFloat { return max(width, height) }
    func minDimension() -> CGFloat { return min(width, height) }
    func aspect() -> CGFloat { return width/height }
}
