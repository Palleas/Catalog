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
    var lines: [String]?
    
    init(path: String!) {
        self.path = path
    }
    
    func lineCount() -> Int {
        return lines?.count ?? 0
    }
    
}
