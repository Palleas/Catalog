//
//  CSVImporter.swift
//  Catalog
//
//  Created by Romain Pouclet on 2015-01-17.
//  Copyright (c) 2015 Romain Pouclet. All rights reserved.
//

import Cocoa
import XCTest

class CSVImporterTests: XCTestCase {
    var csvPath: String!
    
    override func setUp() {
        super.setUp()
        
        csvPath = NSBundle(forClass: self.dynamicType).pathForResource("sample", ofType: "csv", inDirectory: "Fixtures")
        XCTAssertNotNil(csvPath, "Path to CSV file should not be nil")
    }
    
    override func tearDown() {
        csvPath = nil
        super.tearDown()
    }

    func testRetrievingLineCount() {
        let importer = CSVImporter(path: csvPath)
        XCTAssertEqual(importer.lineCount(), 20, "Importer should retrieve 20 lines")
    }
}
