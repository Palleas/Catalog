//
//  Parser.swift
//  ReactiveCSVParser
//
//  Created by Romain Pouclet on 2015-01-27.
//  Copyright (c) 2015 Perfectly-Cooked. All rights reserved.
//

import Cocoa
import ReactiveCocoa

public class Parser: NSObject {
    let path: String
    
    public init(path: String) {
        self.path = path
    }
    
    public func parse() -> RACSignal {
        return RACSignal.createSignal({ (subscriber: RACSubscriber!) -> RACDisposable! in
            if let handler = NSFileHandle(forReadingAtPath: self.path) {
                var offset = UInt64(0)
                var data = handler.readDataOfLength(1024)
                var stringBuffer: String?
                while(data.length > 0) {
                    var chunk = ""
                    if stringBuffer != nil {
                        chunk += stringBuffer!
                    }
                    
                    chunk += NSString(data: data, encoding: NSUTF8StringEncoding) ?? ""
                    
                    let lines = chunk.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                    for (index, line) in enumerate(lines[0..<lines.count - 1]) {
                        subscriber.sendNext(line)
                    }
                    
                    stringBuffer = lines[lines.count - 1]
                    
                    offset += data.length
                    handler.seekToFileOffset(offset)
                    data = handler.readDataOfLength(1024)
                }
                subscriber.sendCompleted()
            } else {
                subscriber.sendError(NSError())
            }
            
            
            return RACDisposable(block: { () -> Void in
                
            })
        }).map({ (line) -> AnyObject! in
            return line.componentsSeparatedByString(",").map({ (col)  -> AnyObject! in
                return (col as String).stringByReplacingOccurrencesOfString("\"", withString: "")
            })
        })
    }
}
