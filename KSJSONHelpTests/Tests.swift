// https://github.com/Quick/Quick

import XCTest

class SQLiteTestCase: XCTestCase {
    override func setUp() {
        let _ = try? NSFileManager.defaultManager().removeItemAtPath(NSHomeDirectory()+"/db.sqlite3")
    }
}
