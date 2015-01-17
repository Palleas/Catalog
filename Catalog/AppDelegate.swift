//
//  AppDelegate.swift
//  Catalog
//
//  Created by Romain Pouclet on 2015-01-16.
//  Copyright (c) 2015 Romain Pouclet. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSStreamDelegate {

    @IBOutlet weak var window: NSWindow!
    var stream: NSStream!
    var buffer: NSMutableData!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
//        let u = NSURL(string: "http://donnees.ville.montreal.qc.ca/dataset/37450231-e4d4-4e9c-99b3-5e88afa6e053/resource/67a95c30-4e21-4346-83f7-491d4ca54a7e/download/cataloguebibliotheque.zip")!
        let u = NSURL(string: "http://donnees.ville.montreal.qc.ca/storage/f/2013-10-14T00%3A41%3A56.426Z/l29-patinoire.zip")!
        
        let task = NSURLSession.sharedSession().downloadTaskWithURL(u, completionHandler: { (url, response, error) -> Void in
            println("Download is over")
            if let csv = self.unzipAndFindCSV(url.path!) {
                println("Found CSV file at \(csv)")
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.importFile(csv)
                })
            }
        })
        task.resume()
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func importFile(path: String) {
        println("Importing file at path \(path)")
        
        // Opening CSV file
        let stream = NSInputStream(fileAtPath: path)!
        stream.delegate = self
        stream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        stream.open()
    }

    func unzipAndFindCSV(file: String) -> String? {
        let target = NSTemporaryDirectory().stringByAppendingPathComponent("le-catalog")
        if !NSFileManager.defaultManager().fileExistsAtPath(target) {
            // Would have been cool to handle potential errors, heh?
            NSFileManager.defaultManager().createDirectoryAtPath(target, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        println("Archive \(file) will be extracted to \(target)")
        
        let task = NSTask()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["unzip", "-o", file, "-d", target]
        task.launch()
        task.waitUntilExit()
        
        if task.terminationStatus != 0 {
            print("🆘 Invalid termination status \(task.terminationStatus)")
            return nil
        }
        
        let csv = NSFileManager.defaultManager().enumeratorAtPath(target)?.allObjects.filter({file -> Bool in
            println("Current file in extracted folder is \(file)")

            return (file as String).pathExtension == "csv"
        }).first as NSString?
        
        return csv != nil ? target.stringByAppendingPathComponent(csv!) : nil
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            println("Stream has opened")
            buffer = NSMutableData()
            break
        case NSStreamEvent.EndEncountered:
            println("Stream has reached end")
            break
        case NSStreamEvent.HasBytesAvailable:
            println("Stream has bytes available")
            
            let bufferSize = 1024
            var localBuffer = Array<UInt8>(count: bufferSize, repeatedValue: 0)
            
            let read = (aStream as NSInputStream).read(&localBuffer, maxLength: bufferSize)
            println("Read \(read) bytes")
            buffer.appendBytes(localBuffer, length: localBuffer.count)
            
            break
        default:
            println("Not handling stream event: \(eventCode)")
            
            
        }
    }
}
