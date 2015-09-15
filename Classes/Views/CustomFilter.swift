//
//  CustomFilter.swift
//  Backflip for iOS
//
//  Created by Mather Warsame on 2015-09-07.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Foundation
import UIKit


class CustomFilter:  NSObject{
    
    enum FastttFilterType{
        case FastttCameraFilterNone
        case FastttCameraFilterRetro
        case FastttCameraFilterHighContrast
        case FastttCameraFilterBW
        case FastttCameraFilterSepia
    
        init() {
            self = .FastttCameraFilterNone
        }
    }
    var filterType = FastttFilterType()
    var filterName: NSString = ""
    var filterImage:UIImage = UIImage()
    
    func filterWithType(filterType:FastttFilterType) -> CustomFilter {
        let imageFilter = CustomFilter()
        imageFilter.filterType = filterType
        
        imageFilter.filterImage = self.imageForFilterType(filterType)
        imageFilter.filterName = self.nameForFilterType(filterType)
        
        return imageFilter
    }
    
    func nextFilter()-> CustomFilter {
        //        return [CustomFilter filterWithType:[self nextFilterType]];

       return CustomFilter().filterWithType(nextFilterType())
    }
    
    func nextFilterType() -> FastttFilterType{
        var filterType = FastttFilterType()
        
        switch filterType {
        case .FastttCameraFilterNone:
            filterType = .FastttCameraFilterRetro;
            break
        case .FastttCameraFilterRetro:
            filterType = .FastttCameraFilterHighContrast;
            break
        case .FastttCameraFilterHighContrast:
            filterType = .FastttCameraFilterSepia;
            break
        case .FastttCameraFilterSepia:
            filterType = .FastttCameraFilterBW;
            break
        default:
            filterType = .FastttCameraFilterNone;
            break
        }
        
        return filterType;

    }
    
    func imageForFilterType(filterType: FastttFilterType) -> UIImage {
//         var lookupImageName:NSString = ""
//        
//        switch filterType {
//        case .FastttCameraFilterRetro:
//            lookupImageName = "RetroFilter"
//            break
//        case .FastttCameraFilterHighContrast:
//            lookupImageName = "HighContrastFilter"
//            break
//        case .FastttCameraFilterSepia:
//            lookupImageName = "SepiaFilter"
//            break
//        case .FastttCameraFilterBW:
//            lookupImageName = "BWFilter"
//            break
//        default:
//            break
//        }
        //LookupImageName replace
        return UIImage(named: "HighContrastFilter")!
        
    }
    
    
    func nameForFilterType(filterType: FastttFilterType) -> NSString{
        var filterName: NSString = ""
        switch (filterType) {
        case .FastttCameraFilterRetro:
            filterName = "Retro"
            break
        case .FastttCameraFilterHighContrast:
            filterName = "High Contrast"
            break
        case .FastttCameraFilterSepia:
            filterName = "Sepia"
            break
        case .FastttCameraFilterBW:
            filterName = "Black + White"
            break
        default:
            filterName = "None"
            break
        }
        
        return filterName;

    }
    
}