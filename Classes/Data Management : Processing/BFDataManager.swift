//
//  BFDataManager.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-09-10.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Foundation
import MagicalRecord

class BFDataMananger : NSObject
{
    
    static let sharedManager = BFDataMananger()
    
    func setupDatabase()
    {
		
        #if FEATURE_COREDATA_SEED
			self.seedDatabase()
		#else
			print("Not seeding database because we're running in DEBUG mode")
        #endif
		
		MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStoreNamed(kAppDatabaseName)
		
		#if !(TARGET_OS_EMBEDDED)  // This will work for Mac or Simulator but excludes physical iOS devices
			#if DEBUG
				// createCoreDataDebugProjectWithType(1, storeURL: persistentStore!.URL!.absoluteString!, modelFilePath: modelUrl.absoluteString!)
			#endif
		#endif
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
	
	
	#if !(TARGET_OS_EMBEDDED)
	func createCoreDataDebugProjectWithType(storeFormat: NSNumber, storeURL: String, modelFilePath: String) {
		
		let project:NSDictionary = [
			"storeFilePath": storeURL,
			"storeFormat" : storeFormat,
			"modelFilePath": modelFilePath,
			"v" : "1"
		]
		
		let projectFile = "/tmp/\(NSBundle.mainBundle().infoDictionary![kCFBundleNameKey as String]!).cdp"
		
		project.writeToFile(projectFile, atomically: true)
	}
	
	#endif
}