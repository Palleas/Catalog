//
//  CSVImporter.swift
//  Catalog
//
//  Created by Romain Pouclet on 2015-01-17.
//  Copyright (c) 2015 Romain Pouclet. All rights reserved.
//

import Cocoa

public class CSVImporter: NSObject {
    let path: String
    public var titles: [String]
    var stringBuffer: NSString? = NSString()
    
    init(path: String!) {
        self.path = path
        titles = [String]()
    }
    
    func performImport() {
        if let handler = NSFileHandle(forReadingAtPath: path) {
            var offset = UInt64(0)
            var data = handler.readDataOfLength(1024)
            var debugTick = 0
            while(data.length > 0 && debugTick < 1000) {
                debugTick++
                var chunk = ""
                if stringBuffer != nil {
                    chunk += stringBuffer!
                }
                
                chunk += NSString(data: data, encoding: NSUTF8StringEncoding) ?? ""
                
            let lines = chunk.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                for (index, line) in enumerate(lines[0..<lines.count - 1]) {
                    processLine(line as String)
                }
                
                stringBuffer = lines[lines.count - 1]
                
                offset += data.length
                handler.seekToFileOffset(offset)
                data = handler.readDataOfLength(1024)
            }
        }
    }
    
    func processLine(line: String) {
        let rows = line.componentsSeparatedByString(",")
        if rows.count < 9 {
            return
        }
        
        let title = line.componentsSeparatedByString(",")[8]
        
        titles.append(title.stringByReplacingOccurrencesOfString("\"", withString: ""))
    }
    
    func lineCount() -> Int {
        return titles.count
    }
    
}
