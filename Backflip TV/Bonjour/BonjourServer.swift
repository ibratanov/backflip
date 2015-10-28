//
//  BonjourServer.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-27.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Foundation
import CoreFoundation

public class BonjourServer : NSObject, NSStreamDelegate
{
	
	/**
	 * The actual port bound to, valid after `start()`
	*/
	public var port : NSInteger?
	
	/**
	 * Network service
	*/
	private var netService : NSNetService?
	
	/**
	 * Connections
	*/
	private var connections : NSMutableSet?
	
	
	/**
	 * IPv4 / IPv6 sockets
	*/
	private var _ipv4socket : CFSocketRef?
	
	private var _ipv6socket : CFSocketRef?
	
	
	// ------------------------------------------------
	//  MARK: Initializer
	// ------------------------------------------------
	
	public override required init()
	{
		super.init()
		
		self.connections = NSMutableSet()
	}
	
	
	
	// ------------------------------------------------
	//  MARK: Connection closing / accepting
	// ------------------------------------------------
	
	func acceptConnection(socketHandle socket: CFSocketNativeHandle)
	{
//		var readStream :  UnsafeMutablePointer<Unmanaged<CFReadStream>?> = nil
//		var writeStream :  UnsafeMutablePointer<Unmanaged<CFWriteStream>?> = nil
//		
//		CFStreamCreatePairWithSocket(kCFAllocatorDefault, socket, readStream, writeStream)
//		if (readStream != nil && writeStream != nil) {
//			
//			CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue)
//			CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue)
//			
//		}

	}
	
	
}

