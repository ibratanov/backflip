//
//  BFDataManager.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-09-10.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Foundation


class BFDataMananger : NSObject
{
    
    static let sharedManager = BFDataMananger()

    
    func setupDatabase()
    {
		
        #if DEBUG
            print("Not seeding database because we're running in DEBUG mode")
		#else
			self.seedDatabase()
        #endif
		
		MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStoreNamed(kAppDatabaseName)
		
    }
    
    
    
    func seedDatabase() -> Bool
    {
        var defaultStorePath = NSPersistentStore.MR_defaultLocalStoreUrl()
		defaultStorePath = defaultStorePath.URLByDeletingLastPathComponent?.URLByAppendingPathComponent(kAppDatabaseName, isDirectory: false);
		
		var copySuccessful : Bool = false;
		let fileManager = NSFileManager.defaultManager()
		if (!fileManager.fileExistsAtPath(defaultStorePath.path!)) {
			let seedPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(kAppDatabaseName, ofType: "sqlite")!)
			print("Core data store does not yet exist at: %@. Attempting to copy from seed db %@.", defaultStorePath!.path!, seedPath!.path!)
			
			self.createPathToStoreFileIfNeccessary(defaultStorePath)
			
			var errorPointer : NSErrorPointer = nil
			copySuccessful = fileManager.copyItemAtURL(seedPath!, toURL: defaultStorePath, error: errorPointer)
			if (errorPointer != nil) {
				print("Seed Database error")
			}
			
		}
		
		
		// Remove seed + database from iCloud backup
		let documentsDirectory = defaultStorePath.URLByDeletingLastPathComponent
		self.excludePathFromBackup(documentsDirectory!)
		
		 
		return copySuccessful
    }
	
	
	
	func createPathToStoreFileIfNeccessary(urlForStore: NSURL)
	{
		var error : NSErrorPointer = nil
		NSFileManager.defaultManager().createDirectoryAtPath(urlForStore.URLByDeletingLastPathComponent!.path!, withIntermediateDirectories: true, attributes: nil, error: error)
	}
    
	
	func excludePathFromBackup(path : NSURL)
	{
		path.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey, error: nil)
	}
	
}