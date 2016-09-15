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
#if SQLITE_SWIFT_STANDALONE
    import sqlite3
#else
    import CSQLite
#endif
import Foundation
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

/// A connection to SQLite.
public final class Connection {

    /// The location of a SQLite database.
    public enum Location {

        /// An in-memory database (equivalent to `.URI(":memory:")`).
        ///
        /// See: <https://www.sqlite.org/inmemorydb.html#sharedmemdb>
        case inMemory

        /// A temporary, file-backed database (equivalent to `.URI("")`).
        ///
        /// See: <https://www.sqlite.org/inmemorydb.html#temp_db>
        case temporary

        /// A database located at the given URI filename (or path).
        ///
        /// See: <https://www.sqlite.org/uri.html>
        ///
        /// - Parameter filename: A URI filename
        case uri(String)
    }

    public var handle: OpaquePointer { return _handle! }

    fileprivate var _handle: OpaquePointer? = nil

    /// Initializes a new SQLite connection.
    ///
    /// - Parameters:
    ///
    ///   - location: The location of the database. Creates a new database if it
    ///     doesn’t already exist (unless in read-only mode).
    ///
    ///     Default: `.InMemory`.
    ///
    ///   - readonly: Whether or not to open the database in a read-only state.
    ///
    ///     Default: `false`.
    ///
    /// - Returns: A new database connection.
    public init(_ location: Location = .inMemory, readonly: Bool = false) throws {
        let flags = readonly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        let description = location.description;
        if _isDebugAssertConfiguration() {
            print(description)
        }
        try check(resultCode: sqlite3_open_v2(description, &_handle, flags | SQLITE_OPEN_FULLMUTEX, nil))
        queue.setSpecific(key: Connection.queueKey, value: self)
    }

    /// Initializes a new connection to a database.
    ///
    /// - Parameters:
    ///
    ///   - filename: The location of the database. Creates a new database if
    ///     it doesn’t already exist (unless in read-only mode).
    ///
    ///   - readonly: Whether or not to open the database in a read-only state.
    ///
    ///     Default: `false`.
    ///
    /// - Throws: `Result.Error` iff a connection cannot be established.
    ///
    /// - Returns: A new database connection.
    public convenience init(_ filename: String, readonly: Bool = false) throws {
        try self.init(.uri(filename), readonly: readonly)
    }

    deinit {
        sqlite3_close(handle)
    }

    // MARK: -

    /// Whether or not the database was opened in a read-only state.
    public var readonly: Bool { return sqlite3_db_readonly(handle, nil) == 1 }

    /// The last rowid inserted into the database via this connection.
    public var lastInsertRowid: Int64? {
        let rowid = sqlite3_last_insert_rowid(handle)
        return rowid > 0 ? rowid : nil
    }

    /// The last number of changes (inserts, updates, or deletes) made to the
    /// database via this connection.
    public var changes: Int {
        return Int(sqlite3_changes(handle))
    }

    /// The total number of changes (inserts, updates, or deletes) made to the
    /// database via this connection.
    public var totalChanges: Int {
        return Int(sqlite3_total_changes(handle))
    }

    // MARK: - Execute

    /// Executes a batch of SQL statements.
    ///
    /// - Parameter sql: A batch of zero or more semicolon-separated SQL
    ///   statements.
    ///
    /// - Throws: `Result.Error` if query execution fails.
    public func execute(sql: String) throws {
        try Statement(self, sql).run()
    }

    // MARK: - Prepare

    /// Prepares a single SQL statement (with optional parameter bindings).
    ///
    /// - Parameters:
    ///
    ///   - statement: A single SQL statement.
    ///
    ///   - bindings: A list of parameters to bind to the statement.
    ///
    /// - Returns: A prepared statement.
    @warn_unused_result public func prepare(statement: String, _ bindings: [Binding?] = []) throws -> Statement {
        return try Statement(self, statement).bind(bindings)
    }

    /// Prepares a single SQL statement and binds parameters to it.
    ///
    /// - Parameters:
    ///
    ///   - statement: A single SQL statement.
    ///
    ///   - bindings: A dictionary of named parameters to bind to the statement.
    ///
    /// - Returns: A prepared statement.
    @warn_unused_result public func prepare(statement: String, _ bindings: [String: Binding?]?) throws -> Statement {
        let statement = try prepare(statement:statement)
        if let bindings = bindings {
            statement.bind(bindings)
        }
        return statement
    }
    // MARK: - Transactions

    /// The mode in which a transaction acquires a lock.
    public enum TransactionMode : String {

        /// Defers locking the database till the first read/write executes.
        case Deferred = "DEFERRED"

        /// Immediately acquires a reserved lock on the database.
        case Immediate = "IMMEDIATE"

        /// Immediately acquires an exclusive lock on all databases.
        case Exclusive = "EXCLUSIVE"

    }

    // TODO: Consider not requiring a throw to roll back?
    /// Runs a transaction with the given mode.
    ///
    /// - Note: Transactions cannot be nested. To nest transactions, see
    ///   `savepoint()`, instead.
    ///
    /// - Parameters:
    ///
    ///   - mode: The mode in which a transaction acquires a lock.
    ///
    ///     Default: `.Deferred`
    ///
    ///   - block: A closure to run SQL statements within the transaction.
    ///     The transaction will be committed when the block returns. The block
    ///     must throw to roll the transaction back.
    ///
    /// - Throws: `Result.Error`, and rethrows.
    public func transaction(mode: TransactionMode = .Deferred, block: @escaping () throws -> Void) throws {
        try transaction(begin:"BEGIN \(mode.rawValue) TRANSACTION", block, "COMMIT TRANSACTION", or: "ROLLBACK TRANSACTION")
    }

    // TODO: Consider not requiring a throw to roll back?
    // TODO: Consider removing ability to set a name?
    /// Runs a transaction with the given savepoint name (if omitted, it will
    /// generate a UUID).
    ///
    /// - SeeAlso: `transuaction()`.
    ///
    /// - Parameters:
    ///
    ///   - savepointName: A unique identifier for the savepoint (optional).
    ///
    ///   - block: A closure to run SQL statements within the transaction.
    ///     The savepoint will be released (committed) when the block returns.
    ///     The block must throw to roll the savepoint back.
    ///
    /// - Throws: `SQLite.Result.Error`, and rethrows.
    public func savepoint(name: String = NSUUID().uuidString, block: @escaping () throws -> Void) throws {
        let name = name.quote("'")
        let savepoint = "SAVEPOINT \(name)"

        try transaction(begin:savepoint, block, "RELEASE \(savepoint)", or: "ROLLBACK TO \(savepoint)")
    }

    private func transaction(begin: String, _ block: @escaping () throws -> Void, _ commit: String, or rollback: String) throws {
        return try sync {
            try self.execute(sql: begin)
            do {
                try block()
            } catch {
                try self.execute(sql: rollback)
                throw error
            }
            try self.execute(sql: commit)
        }
    }

    /// Interrupts any long-running queries.
    public func interrupt() {
        sqlite3_interrupt(handle)
    }

    // MARK: - Handlers

    /// The number of seconds a connection will attempt to retry a statement
    /// after encountering a busy signal (lock).
    public var busyTimeout: Double = 0 {
        didSet {
            sqlite3_busy_timeout(handle, Int32(busyTimeout * 1_000))
        }
    }

    /// Sets a handler to call after encountering a busy signal (lock).
    ///
    /// - Parameter callback: This block is executed during a lock in which a
    ///   busy error would otherwise be returned. It’s passed the number of
    ///   times it’s been called for this lock. If it returns `true`, it will
    ///   try again. If it returns `false`, no further attempts will be made.
    public func busyHandler(callback: ((Int) -> Bool)?) {
        guard let callback = callback else {
            sqlite3_busy_handler(handle, nil, nil)
            busyHandler = nil
            return
        }

        let box: BusyHandler = { callback(Int($0)) ? 1 : 0 }
        sqlite3_busy_handler(handle, { callback, tries in
            unsafeBitCast(callback, to: BusyHandler.self)(tries)
        }, unsafeBitCast(box, to: UnsafeMutableRawPointer.self))
        busyHandler = box
    }
    fileprivate typealias BusyHandler = @convention(block) (Int32) -> Int32
    fileprivate var busyHandler: BusyHandler?

    /// Sets a handler to call when a statement is executed with the compiled
    /// SQL.
    ///
    /// - Parameter callback: This block is invoked when a statement is executed
    ///   with the compiled SQL as its argument.
    ///
    ///       db.trace { SQL in print(SQL) }
    public func trace(callback: ((String) -> Void)?) {
        guard let callback = callback else {
            sqlite3_trace(handle, nil, nil)
            trace = nil
            return
        }

        let box: Trace = { callback(String(cString: $0)) }
        sqlite3_trace(handle, { callback, SQL in
            unsafeBitCast(callback, to: Trace.self)(SQL!)
        }, unsafeBitCast(box, to: UnsafeMutableRawPointer.self))
        trace = box
    }
    fileprivate typealias Trace = @convention(block) (UnsafePointer<Int8>) -> Void
    fileprivate var trace: Trace?

    /// Registers a callback to be invoked whenever a row is inserted, updated,
    /// or deleted in a rowid table.
    ///
    /// - Parameter callback: A callback invoked with the `Operation` (one of
    ///   `.Insert`, `.Update`, or `.Delete`), database name, table name, and
    ///   rowid.
    public func updateHook(callback: ((_ operation: Operation, _ db: String, _ table: String, _ rowid: Int64) -> Void)?) {
        guard let callback = callback else {
            sqlite3_update_hook(handle, nil, nil)
            updateHook = nil
            return
        }

        let box: UpdateHook = {
            callback(
                Operation(rawValue: $0),
                String(cString: $1),
                String(cString: $2),
                $3
            )
        }
        sqlite3_update_hook(handle, { callback, operation, db, table, rowid in
            unsafeBitCast(callback, to: UpdateHook.self)(operation, db!, table!, rowid)
        }, unsafeBitCast(box, to: UnsafeMutableRawPointer.self))
        updateHook = box
    }
    fileprivate typealias UpdateHook = @convention(block) (Int32, UnsafePointer<Int8>, UnsafePointer<Int8>, Int64) -> Void
    fileprivate var updateHook: UpdateHook?

    /// Registers a callback to be invoked whenever a transaction is committed.
    ///
    /// - Parameter callback: A callback invoked whenever a transaction is
    ///   committed. If this callback throws, the transaction will be rolled
    ///   back.
    public func commitHook(callback: (() throws -> Void)?) {
        guard let callback = callback else {
            sqlite3_commit_hook(handle, nil, nil)
            commitHook = nil
            return
        }

        let box: CommitHook = {
            do {
                try callback()
            } catch {
                return 1
            }
            return 0
        }
        sqlite3_commit_hook(handle, { callback in
            unsafeBitCast(callback, to: CommitHook.self)()
        }, unsafeBitCast(box, to: UnsafeMutableRawPointer.self))
        commitHook = box
    }
    fileprivate typealias CommitHook = @convention(block) () -> Int32
    fileprivate var commitHook: CommitHook?

    /// Registers a callback to be invoked whenever a transaction rolls back.
    ///
    /// - Parameter callback: A callback invoked when a transaction is rolled
    ///   back.
    public func rollbackHook(callback: (() -> Void)?) {
        guard let callback = callback else {
            sqlite3_rollback_hook(handle, nil, nil)
            rollbackHook = nil
            return
        }

        let box: RollbackHook = { callback() }
        sqlite3_rollback_hook(handle, { callback in
            unsafeBitCast(callback, to: RollbackHook.self)()
        }, unsafeBitCast(box, to: UnsafeMutableRawPointer.self))
        rollbackHook = box
    }
    fileprivate typealias RollbackHook = @convention(block) () -> Void
    fileprivate var rollbackHook: RollbackHook?

    fileprivate var functions = Set<DatabaseFunction>()

    /// The return type of a collation comparison function.
    public typealias ComparisonResult = Foundation.ComparisonResult

    fileprivate var collations = Set<DatabaseCollation>()

    // MARK: - Error Handling

    func sync<T>(block: @escaping () throws -> T) rethrows -> T {
        var success: T?
        var failure: Error?

        let box: () -> Void = {
            do {
                success = try block()
            } catch {
                failure = error
            }
        }

        if let value = DispatchQueue.getSpecific(key: Connection.queueKey),value === self {
            box()
        } else {
            queue.sync(execute: box) // FIXME: rdar://problem/21389236
        }

        if let failure = failure {
            try { () -> Void in throw failure }()
        }

        return success!
    }

    func check(resultCode: Int32, statement: Statement? = nil) throws -> Int32 {
        guard let error = Result(errorCode: resultCode, connection: self, statement: statement) else {
            return resultCode
        }
        print(error)
        throw error
    }

    fileprivate var queue = DispatchQueue(label: "SQLite.Database", attributes: [])

    private static let queueKey = DispatchSpecificKey<Connection>()

}

extension Connection : CustomStringConvertible {

    public var description: String {
        return String(cString:sqlite3_db_filename(handle, nil))
    }

}
extension Connection {
    
    /**
     Check if a table exists
     
     - parameter tableName:  name of the table
     
     - returns:              boolean indicating whether the table exists, or not
     */
    public func contains(tableName: String) throws -> Bool {
        let query = "SELECT name FROM sqlite_master WHERE type='table' AND name=?"
        return try prepare(statement:query, [tableName]).scalar() != nil
    }
}
extension Connection {
    public func create(function: DatabaseFunction) {
        functions.update(with: function)
        let functionPointer = unsafeBitCast(function, to: UnsafeMutableRawPointer.self)
        let code = sqlite3_create_function_v2(
            handle,
            function.name,
            function.argumentCount,
            function.flags,
            functionPointer,
            { (context, argc, argv) in
                let function = unsafeBitCast(sqlite3_user_data(context), to: DatabaseFunction.self)
                let result = function.function(argc, argv)
                if let result = result as? Blob {
                    sqlite3_result_blob(context, result.bytes, Int32(result.bytes.count), nil)
                } else if let result = result as? Double {
                    sqlite3_result_double(context, result)
                } else if let result = result as? Int64 {
                    sqlite3_result_int64(context, result)
                } else if let result = result as? String {
                    sqlite3_result_text(context, result, Int32(result.characters.count), SQLITE_TRANSIENT)
                } else if result == nil {
                    sqlite3_result_null(context)
                } else {
                    fatalError("unsupported result type: \(result)")
                }
            }, nil, nil, nil)
    }
    public func create(collation: DatabaseCollation) {
        collations.update(with: collation)
        let collationPointer = unsafeBitCast(collation, to: UnsafeMutableRawPointer.self)
        let code = sqlite3_create_collation_v2(
            handle,
            collation.name,
            SQLITE_UTF8,
            collationPointer,
            { (collationPointer, length1, buffer1, length2, buffer2) -> Int32 in
                let collation = unsafeBitCast(collationPointer, to: DatabaseCollation.self)
                return Int32(collation.function(length1, buffer1, length2, buffer2).rawValue)
            }, nil)
        try! check(resultCode: code,statement: nil)
    }
}
extension Connection.Location : CustomStringConvertible {

    public var description: String {
        switch self {
        case .inMemory:
            return ":memory:"
        case .temporary:
            return ""
        case .uri(let URI):
            let documentsDir : String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
            return documentsDir+"/"+URI
        }
    }

}

/// An SQL operation passed to update callbacks.
public enum Operation {

    /// An INSERT operation.
    case insert

    /// An UPDATE operation.
    case update

    /// A DELETE operation.
    case delete

    fileprivate init(rawValue: Int32) {
        switch rawValue {
        case SQLITE_INSERT:
            self = .insert
        case SQLITE_UPDATE:
            self = .update
        case SQLITE_DELETE:
            self = .delete
        default:
            fatalError("unhandled operation code: \(rawValue)")
        }
    }

}

public enum Result : Error {

    fileprivate static let successCodes: Set = [SQLITE_OK, SQLITE_ROW, SQLITE_DONE]

    case error(message: String, code: Int32, statement: Statement?)

    init?(errorCode: Int32, connection: Connection, statement: Statement? = nil) {
        guard !Result.successCodes.contains(errorCode) else { return nil }

        let message = String(cString:sqlite3_errmsg(connection.handle))
        self = .error(message: message, code: errorCode, statement: statement)
    }

}

extension Result : CustomStringConvertible {

    public var description: String {
        switch self {
        case let .error(message, _, statement):
            guard let statement = statement else { return message }

            return "\(message) (\(statement))"
        }
    }
}
/// An SQL function.
public final class DatabaseFunction {
    public let name: String
    let argumentCount: Int32
    let deterministic: Bool
    let function: (Int32, UnsafeMutablePointer<OpaquePointer?>?) -> Binding?
    var flags: Int32 { return deterministic ? SQLITE_UTF8: SQLITE_UTF8|SQLITE_DETERMINISTIC }




    /// Returns an SQL function.
    ///
    ///     let fn = DatabaseFunction("succ", argumentCount: 1) { databaseValues in
    ///         let dbv = databaseValues.first!
    ///         guard let int = dbv.value() as Int? else {
    ///             return nil
    ///         }
    ///         return int + 1
    ///     }
    ///     db.add(function: fn)
    ///     Int.fetchOne(db, "SELECT succ(1)")! // 2
    ///
    /// - parameters:
    ///     - name: The function name.
    ///     - argumentCount: The number of arguments of the function. If
    ///       omitted, or nil, the function accepts any number of arguments.
    ///     - pure: Whether the function is "pure", which means that its results
    ///       only depends on its inputs. When a function is pure, SQLite has
    ///       the opportunity to perform additional optimizations. Default value
    ///       is false.
    ///     - function: A function that takes an array of DatabaseValue
    ///       arguments, and returns an optional DatabaseValueConvertible such
    ///       as Int, String, NSDate, etc. The array is guaranteed to have
    ///       exactly *argumentCount* elements, provided *argumentCount* is
    ///       not nil.
    public init(_ name: String, argumentCount: Int32? = nil, deterministic: Bool = false, function: @escaping ([Binding?]) -> Binding?) {
        self.name = name
        self.argumentCount = argumentCount ?? -1
        self.deterministic = deterministic

        self.function = { (argc, argv) in
            let arguments = (0..<Int(argc)).map { idx in
                let value = argv?[idx]
                switch sqlite3_value_type(value) {
                case SQLITE_BLOB:
                    return Blob(ptr:sqlite3_value_blob(value),count:Int(sqlite3_value_bytes(value)))
                case SQLITE_FLOAT:
                    return sqlite3_value_double(value)
                case SQLITE_INTEGER:
                    return sqlite3_value_int64(value)
                case SQLITE_NULL:
                    return nil
                case SQLITE_TEXT:
                    return String(cString:UnsafePointer(sqlite3_value_text(value)))
                case let type:
                    fatalError("unsupported value type: \(type)")
                }
            } as [Binding?]
            return function(arguments)
        }
    }
}

extension DatabaseFunction : Hashable {
    /// The hash value.
    public var hashValue: Int {
        return name.hashValue ^ argumentCount.hashValue
    }
}

/// Two functions are equal if they share the same name and argumentCount.
public func ==(lhs: DatabaseFunction, rhs: DatabaseFunction) -> Bool {
    return lhs.name == rhs.name && lhs.argumentCount == rhs.argumentCount
}

/// A Collation is a string comparison function used by SQLite.
public final class DatabaseCollation {
    public let name: String
    let function: (Int32, UnsafeRawPointer?, Int32, UnsafeRawPointer?) -> ComparisonResult

    /// Returns a collation.
    ///
    ///     let collation = DatabaseCollation("localized_standard") { (string1, string2) in
    ///         return (string1 as NSString).localizedStandardCompare(string2)
    ///     }
    ///     db.add(collation: collation)
    ///     try db.execute("CREATE TABLE files (name TEXT COLLATE localized_standard")
    ///
    /// - parameters:
    ///     - name: The function name.
    ///     - function: A function that compares two strings.
    public init(_ name: String, function: @escaping (String, String) -> ComparisonResult) {
        self.name = name
        self.function = { (length1, buffer1, length2, buffer2) in
            // Buffers are not C strings: they do not end with \0.
            let string1 = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: buffer1.unsafelyUnwrapped), length: Int(length1), encoding: .utf8, freeWhenDone: false)!
            let string2 = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: buffer2.unsafelyUnwrapped), length: Int(length2), encoding: .utf8, freeWhenDone: false)!
            return function(string1, string2)
        }
    }
}

extension DatabaseCollation : Hashable {
    /// The hash value.
    public var hashValue: Int {
        // We can't compute a hash since the equality is based on the opaque
        // sqlite3_strnicmp SQLite function.
        return 0
    }
}

/// Two collations are equal if they share the same name (case insensitive)
public func ==(lhs: DatabaseCollation, rhs: DatabaseCollation) -> Bool {
    // See https://www.sqlite.org/c3ref/create_collation.html
    return sqlite3_stricmp(lhs.name, lhs.name) == 0
}
