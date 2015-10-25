//
//  Defines.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-09-10.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Foundation



let kAppDatabaseName : String = "backflip-preseed"


let nPhotoObjectsUpdated : String = "nPhotoObjectsUpdated"
let nEventObjectsUpdated : String = "nEventObjectsUpdated"



#if DEBUG
	let FEATURE_COREDATA_SEED : Bool = false
#else
	let FEATURE_COREDATA_SEED : Bool = true
#endif


//------------------------------------
// MARK: Feature Flags
//------------------------------------

let FEATURE_GOOGLE_ANALYTICS : Bool = false

let FEATURE_NEW_RELIC : Bool = true

let FEATURE_MIXPANEL : Bool = true

let FEATURE_INSTABUG : Bool = true