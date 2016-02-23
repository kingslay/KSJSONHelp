//
//  Tests.swift
//  Tests
//
//  Created by king on 16/2/23.
//  Copyright © 2016年 king. All rights reserved.
//

import XCTest
class SQLiteTestCase: XCTestCase {
    override func setUp() {
        let _ = try? NSFileManager.defaultManager().removeItemAtPath(NSHomeDirectory()+"/db.sqlite3")
    }
}
