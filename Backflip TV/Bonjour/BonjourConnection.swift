//
//  BonjourConnection.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-27.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Foundation


public class BonjourConnection : NSObject, NSStreamDelegate
{
	
	public weak var inputStream: NSInputStream?
	public weak var outputStream: NSOutputStream?
	
	
	
	public required init(withInputStream inputStream: NSInputStream, outputStream: NSOutputStream)
	{
		super.init()
		
		self.inputStream = inputStream
		self.outputStream = outputStream
	}
	
	
	// ------------------------------------------------
	//  MARK: Opening / Closing
	// ------------------------------------------------
	
	public func open() -> Bool
	{
		self.inputStream?.delegate = self
		self.outputStream?.delegate = self
		
		self.inputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		self.outputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		
		self.inputStream?.open()
		self.outputStream?.open()
		
		return true
	}
	
	public func close()
	{
		self.inputStream?.delegate = nil
		self.outputStream?.delegate = nil
		
		self.inputStream?.close()
		self.outputStream?.close()
		
		self.inputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		self.outputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
	}
	
	
	// ------------------------------------------------
	//  MARK: Stream event handling
	// ------------------------------------------------
	
	public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent)
	{
		guard aStream == self.inputStream || aStream == self.outputStream else {
			print("Rouge stream..")
			return
		}
		
		switch eventCode {
			
			case NSStreamEvent.HasBytesAvailable:
				
				let bufferSize = 1024
				let buffer = UnsafeMutablePointer<UInt8>.alloc(bufferSize)
				let actuallyRead = self.inputStream?.read(buffer, maxLength: bufferSize)
				if (actuallyRead > 0) {
					
					let actuallyWritten = self.outputStream?.write(buffer, maxLength: bufferSize)
					if (actuallyWritten != actuallyRead) {
						// -write:maxLength: may return -1 to indicate an error or a non-negative
						// value less than maxLength to indicate a 'short write'.  In the case of an
						// error we just shut down the connection.  The short write case is more
						// interesting.  A short write means that the client has sent us data to echo but
						// isn't reading the data that we send back to it, thus causing its socket receive
						// buffer to fill up, thus causing our socket send buffer to fill up.  Again, our
						// response to this situation is that we simply drop the connection.
						self.close()
					} else {
						print("Echoed \(actuallyWritten) bytes.")
					}
					
				} else {
					// A non-positive value from -read:maxLength: indicates either end of file (0) or
					// an error (-1).  In either case we just wait for the corresponding stream event
					// to come through.
				}
				
			break
		
			case NSStreamEvent.EndEncountered, NSStreamEvent.ErrorOccurred:
				self.close()
			break
			
			default:
				print("Default case")
			
		}
	}
	
	
}

