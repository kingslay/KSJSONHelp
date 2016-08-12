//
//  Tests.swift
//  Tests
//
//  Created by king on 16/2/23.
//  Copyright © 2016年 king. All rights reserved.
//

import XCTest
import KSJSONHelp
class SQLiteTestCase: XCTestCase {
    override func setUp() {
        Database.driver = SQLiteDriver()
        let _ = try? NSFileManager.defaultManager().removeItemAtPath(NSHomeDirectory()+"/db.sqlite3")
    }
}
