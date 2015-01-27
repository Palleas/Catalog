//
//  CSVImporter.swift
//  Catalog
//
//  Created by Romain Pouclet on 2015-01-17.
//  Copyright (c) 2015 Romain Pouclet. All rights reserved.
//

import Cocoa

class CSVImporter: NSObject {
    let path: String
    var lines: [Item]
    var stringBuffer: NSString? = NSString()
    
    init(path: String!) {
        self.path = path
        lines = [Item]()
    }
    
    func performImport() {
        if let handler = NSFileHandle(forReadingAtPath: path) {
            var offset = UInt64(0)
            var data = handler.readDataOfLength(1024)
            
            while(data.length > 0) {
                var chunk = ""
                if stringBuffer != nil {
                    chunk += stringBuffer!
                }
                
                chunk += NSString(data: data, encoding: NSUTF8StringEncoding)!
                
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
        let title = line.componentsSeparatedByString(",")[8]
        let cleanedTitle = title.stringByReplacingOccurrencesOfString("\"", withString: "")
        
        lines.append(Item(title: cleanedTitle))
    }
    
    func lineCount() -> Int {
        return lines.count
    }
    
}
