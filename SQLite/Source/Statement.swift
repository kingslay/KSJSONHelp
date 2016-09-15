//
// SQLite.swift
// https://github.com/stephencelis/SQLite.swift
// Copyright © 2014-2015 Stephen Celis.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

/// A single SQL statement.
#if SQLITE_SWIFT_STANDALONE
    import sqlite3
#else
    import CSQLite
#endif
public final class Statement {
    
    fileprivate var handle: OpaquePointer? = nil
    
    fileprivate let connection: Connection
    
    init(_ connection: Connection, _ SQL: String) throws {
        self.connection = connection
        print("[SQL] \(SQL)")
        try connection.check(resultCode: sqlite3_prepare_v2(connection.handle, SQL, -1, &handle, nil))
    }
    
    deinit {
        sqlite3_finalize(handle)
    }
    
    public lazy var columnCount: Int = Int(sqlite3_column_count(self.handle))
    
    public lazy var columnNames: [String] = (0..<Int32(self.columnCount)).map {
        String(cString:sqlite3_column_name(self.handle, $0))
    }
    
    /// A cursor pointing to the current row.
    public lazy var row: Cursor = Cursor(self)
    
    /// Binds a list of parameters to a statement.
    ///
    /// - Parameter values: A list of parameters to bind to the statement.
    ///
    /// - Returns: The statement object (useful for chaining).
    public func bind(_ values: [Binding?]) -> Statement {
        if values.isEmpty { return self }
        reset()
        guard values.count == Int(sqlite3_bind_parameter_count(handle)) else {
            fatalError("\(sqlite3_bind_parameter_count(handle)) values expected, \(values.count) passed")
        }
        for idx in 1...values.count { bind(values[idx - 1], atIndex: idx) }
        return self
    }
    
    /// Binds a dictionary of named parameters to a statement.
    ///
    /// - Parameter values: A dictionary of named parameters to bind to the
    ///   statement.
    ///
    /// - Returns: The statement object (useful for chaining).
    public func bind(_ values: [String: Binding?]) -> Statement {
        reset()
        for (name, value) in values {
            let idx = sqlite3_bind_parameter_index(handle, ":"+name)
            guard idx > 0 else {
                fatalError("parameter not found: \(name)")
            }
            bind(value, atIndex: Int(idx))
        }
        return self
    }
    
    fileprivate func bind(_ value: Binding?, atIndex idx: Int) {
        if value == nil {
            sqlite3_bind_null(handle, Int32(idx))
        } else if let value = value as? Blob {
            sqlite3_bind_blob(handle, Int32(idx), value.bytes, Int32(value.bytes.count), SQLITE_TRANSIENT)
        } else if let value = value as? Double {
            sqlite3_bind_double(handle, Int32(idx), value)
        } else if let value = value as? Int64 {
            sqlite3_bind_int64(handle, Int32(idx), value)
        } else if let value = value as? String {
            sqlite3_bind_text(handle, Int32(idx), value, -1, SQLITE_TRANSIENT)
        } else if let value = value {
            self.bind(value.datatypeValue, atIndex: idx)
        }
    }
    public func run() {
        for _ in self {
            
        }
    }
    public func scalar() -> Binding? {
        reset(clearBindings: false)
        try! step()
        return row[0]
    }
    
    public func step() throws -> Bool {
        return try connection.sync { try self.connection.check(resultCode: sqlite3_step(self.handle)) == SQLITE_ROW }
    }
    
    fileprivate func reset(clearBindings shouldClear: Bool = true) {
        sqlite3_reset(handle)
        if (shouldClear) { sqlite3_clear_bindings(handle) }
    }
    
}

extension Statement : Sequence {
    public func makeIterator() -> Statement {
        reset(clearBindings: false)
        return self
    }
}

extension Statement : IteratorProtocol {
    public func next() -> [String:Binding?]? {
        if try! step() {
            var dictionary: [String:Binding?] = [:]
            for i in 0..<columnCount {
                dictionary[columnNames[i]] = row[i];
            }
            return dictionary
        }else{
            return nil
        }
    }
    public var first: [String:Binding?]? {
        return next()
    }

    
}

extension Statement : CustomStringConvertible {
    
    public var description: String {
        return String(cString:sqlite3_sql(handle))
    }
}

public struct Cursor {
    
    fileprivate let handle: OpaquePointer
    
    fileprivate let columnCount: Int
    
    fileprivate init(_ statement: Statement) {
        handle = statement.handle!
        columnCount = statement.columnCount
    }    
}

/// Cursors provide direct access to a statement’s current row.
extension Cursor : Collection {
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i+1
    }

    public var startIndex: Int {
        return 0
    }
    public var endIndex: Int {
        return self.columnCount
    }
    public func makeIterator() -> IndexingIterator<Cursor> {
        return IndexingIterator(_elements: self)
    }
    
    public subscript(idx: Int) -> Binding? {
        switch sqlite3_column_type(handle, Int32(idx)) {
        case SQLITE_BLOB:
            return Blob(ptr:sqlite3_column_blob(handle, Int32(idx)),count: Int(sqlite3_column_bytes(handle, Int32(idx))))
        case SQLITE_FLOAT:
            return sqlite3_column_double(handle, Int32(idx)) as Double
        case SQLITE_INTEGER:
            return sqlite3_column_int64(handle, Int32(idx)) as Int64
        case SQLITE_NULL:
            return nil
        case SQLITE_TEXT:
            return String(cString:UnsafePointer(sqlite3_column_text(handle, Int32(idx)))) ?? "" as String
        case let type:
            fatalError("unsupported column type: \(type)")
        }
    }
}
