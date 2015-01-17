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
    var totalBytesRead: Int = 0

    func applicationDidFinishLaunching(aNotification: NSNotification) {
//        let u = NSURL(string: "http://donnees.ville.montreal.qc.ca/dataset/37450231-e4d4-4e9c-99b3-5e88afa6e053/resource/67a95c30-4e21-4346-83f7-491d4ca54a7e/download/cataloguebibliotheque.zip")!
        let u = NSURL(string: "http://donnees.ville.montreal.qc.ca/storage/f/2013-10-14T00%3A41%3A56.426Z/l29-patinoire.zip")!
        
        let task = NSURLSession.sharedSession().downloadTaskWithURL(u, completionHandler: { (url, response, error) -> Void in
            println("Download is over")
            if let csv = self.unzipAndFindCSV(url.path!) {
                println("Found CSV file at \(csv)")
                
                self.importFile(csv)
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
        if let handler = NSFileHandle(forReadingAtPath: path) {
            var offset = UInt64(0)
            var data = handler.readDataOfLength(1024)
            while(data.length > 0) {
                let chunk = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Chuck = \(chunk)")

                let lines = chunk?.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                
                offset += data.length
                handler.seekToFileOffset(offset)
                data = handler.readDataOfLength(1024)
            }
        }
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
}

