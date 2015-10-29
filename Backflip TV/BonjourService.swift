//
//  BonjourService.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 22/10/2015.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation

class BonjourService : NSObject, NSNetServiceDelegate, NSNetServiceBrowserDelegate
{

	static let sharedService : BonjourService = BonjourService()

	var nsns: NSNetService?
	var nsb: NSNetServiceBrowser?


	func registerService()
	{
		let BM_DOMAIN = "local"
		let BM_TYPE = "_backflip-tv._tcp."
		let BM_NAME = UIDevice.currentDevice().name
		let BM_PORT : CInt = 6543

		/// Netservice
		nsns = NSNetService(domain: BM_DOMAIN, type: BM_TYPE, name: BM_NAME, port: BM_PORT)
		nsns?.delegate = self
		nsns?.publish()

		/// Net service browser.
		nsb = NSNetServiceBrowser()
		nsb?.delegate = self
		nsb?.searchForServicesOfType(BM_TYPE, inDomain: BM_DOMAIN)

		print("press enter")
		// this prevents the app from quitting instantly.
		// NSRunLoop.currentRunLoop().run()
		// NSFileHandle.fileHandleWithStandardInput().availableData
	}




	/**
	 * NSNetServiceDelegate
	*/
	func netServiceWillPublish(sender: NSNetService) {
		print("netServiceWillPublish:\(sender)");
	}

	func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
		print("didNotPublish:\(sender)");
	}

	func netServiceDidPublish(sender: NSNetService) {
		print("netServiceDidPublish:\(sender)");
	}

	func netServiceWillResolve(sender: NSNetService) {
		print("netServiceWillResolve:\(sender)");
	}

	func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
		print("netServiceDidNotResolve:\(sender)");
	}

	func netServiceDidResolveAddress(sender: NSNetService) {
		print("netServiceDidResolve:\(sender)");
	}

	func netService(sender: NSNetService, didUpdateTXTRecordData data: NSData) {
		print("netServiceDidUpdateTXTRecordData:\(sender)");
	}

	func netServiceDidStop(sender: NSNetService) {
		print("netServiceDidStopService:\(sender)");
	}

	func netService(sender: NSNetService, didAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream stream: NSOutputStream) {
		print("netServiceDidAcceptConnection:\(sender)");
	}



	/**
	 * NSNetServiceBrowserDelegate
	*/
	func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser, didFindDomain domainName: String, moreComing moreDomainsComing: Bool) {
		print("netServiceDidFindDomain")
	}

	func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser, didRemoveDomain domainName: String, moreComing moreDomainsComing: Bool) {
		print("netServiceDidRemoveDomain")
	}

	func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser, didFindService netService: NSNetService, moreComing moreServicesComing: Bool)
	{
		print("netServiceDidFindService")
		
		
	}

	func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser, didRemoveService netService: NSNetService, moreComing moreServicesComing: Bool) {
		print("netServiceDidRemoveService")
	}

	func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser){
		print("netServiceBrowserWillSearch")
	}

	func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
		print("netServiceDidNotSearch")
	}

	func netServiceBrowserDidStopSearch(netServiceBrowser: NSNetServiceBrowser) {
		print("netServiceDidStopSearch")
	}
}