//
//  SearchViewController.swift
//  Catalog
//
//  Created by Romain Pouclet on 2015-01-28.
//  Copyright (c) 2015 Romain Pouclet. All rights reserved.
//

import Cocoa
import ReactiveCocoa
import ReactiveCSVParser
import Realm

class HomeViewController: NSViewController {
    var realm: RLMRealm?
    
    @IBAction func importButtonPressed(sender: AnyObject) {
        println("Import button pressed, starting download")
        realm = RLMRealm(path: cacheDirectory().stringByAppendingPathComponent("catalog.realm"))
        println("Path to realm is \(realm?.path)")
        
        self.download().flattenMap { (zipFile) -> RACStream! in
            println("Archive was downloaded to \(zipFile)")
            return self.unzip(zipFile as String, destination: self.cacheDirectory())
        }.flattenMap { (csvFile) -> RACStream! in
            println("Starting parsing of file \(csvFile)")
            let parser = Parser(path: csvFile as String)
            return parser.parse()
        }.filter { (line) -> Bool in
            let count = countElements(line as Array<String>)
            println("Lines has \(count) items")
            return count >= 9
        } .deliverOn(RACScheduler.mainThreadScheduler()).subscribeNext({ (line) -> Void in
            let item = Item()
            item.title = line[8] as String

            self.realm?.beginWriteTransaction()
            Item.createInRealm(self.realm, withObject: item)
            self.realm?.commitWriteTransaction()
        }, error: { (error) -> Void in
            println("Got error \(error)")
        }) { () -> Void in
            println("Import complete")
        }
    }
    
    func cacheDirectory() -> String {
        let urls = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        return (urls.first as String).stringByAppendingPathComponent("com.perfectly-cooked.Catalog")
    }
    
    func download() -> RACSignal {
        return RACSignal.createSignal({ (subscriber) -> RACDisposable! in
            let u = NSURL(string: "http://donnees.ville.montreal.qc.ca/dataset/37450231-e4d4-4e9c-99b3-5e88afa6e053/resource/67a95c30-4e21-4346-83f7-491d4ca54a7e/download/cataloguebibliotheque.zip")!
            
            let task = NSURLSession.sharedSession().downloadTaskWithURL(u, completionHandler: { (url, response, error) -> Void in
                println("Download is over")
                
                if let downloadError = error{
                    subscriber.sendError(downloadError)
                    return;
                }
                
                let target = self.cacheDirectory().stringByAppendingPathComponent("catalog.zip")
                println("Archive target is \(target)")
                var error: NSError?
                NSFileManager.defaultManager().moveItemAtPath(url.path!, toPath: target, error: &error)
                if let movingError = error {
                    subscriber.sendError(error)
                } else {
                    subscriber.sendNext(target)
                    subscriber.sendCompleted()
                }
            })
            task.resume()
            
            
            return RACDisposable(block: { () -> Void in
                
            })
        })
    }
    
    func unzip(archivePath: String, destination: String) -> RACSignal {
        return RACSignal.createSignal({ (subscriber) -> RACDisposable! in
            let target = NSTemporaryDirectory().stringByAppendingPathComponent("le-catalog")
            if !NSFileManager.defaultManager().fileExistsAtPath(target) {
                // Would have been cool to handle potential errors, heh?
                NSFileManager.defaultManager().createDirectoryAtPath(target, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
            
            println("Archive \(archivePath) will be extracted to \(destination)")
            
            let task = NSTask()
            task.launchPath = "/usr/bin/env"
            task.arguments = ["unzip", "-o", archivePath, "-d", destination]
            task.launch()
            task.waitUntilExit()
            
            if task.terminationStatus != 0 {
                print("🆘 Invalid termination status \(task.terminationStatus)")
                subscriber.sendError(NSError())
            } else {
                let csv = NSFileManager.defaultManager().enumeratorAtPath(target)?.allObjects.filter({file -> Bool in
                    println("Current file in extracted folder is \(file)")
                    
                    return (file as String).pathExtension == "csv"
                }).first as String
                
                subscriber.sendNext(destination.stringByAppendingPathComponent(csv))
                subscriber.sendCompleted()
            }
            
            return RACDisposable(block: { () -> Void in
                
            })
        })
    }
}
