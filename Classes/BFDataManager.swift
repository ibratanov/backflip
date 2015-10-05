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
		
        #if FEATURE_COREDATA_SEED
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
			print("Core data store does not yet exist at: "+defaultStorePath!.path!+". Attempting to copy from seed db"+seedPath.path!)
			
			self.createPathToStoreFileIfNeccessary(defaultStorePath)
			
			do {
				try fileManager.copyItemAtURL(seedPath, toURL: defaultStorePath)
				copySuccessful = true
			} catch _ {
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
		let error : NSErrorPointer = nil
		do {
			try NSFileManager.defaultManager().createDirectoryAtPath(urlForStore.URLByDeletingLastPathComponent!.path!, withIntermediateDirectories: true, attributes: nil)
		} catch let error1 as NSError {
			error.memory = error1
		}
	}
    
	
	func excludePathFromBackup(path : NSURL)
	{
		do {
			try path.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
		} catch _ {
		}
	}
	
}