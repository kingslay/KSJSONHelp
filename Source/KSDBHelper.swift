//
//  KSDBHelp.swift
//  KSJSONHelp
//
//  Created by king on 16/1/7.
//  Copyright © 2016年 king. All rights reserved.
//
import Foundation
import Dispatch
import sqlite3
let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self)

public class KSDBHelper {
    public let db: Connection
    private var createdTableNames = Set<String>()
    public convenience init() {
        try self.init(dbname: "KSDB")
    }
    public convenience init(dbname: String) {
        let filePath = "\(NSTemporaryDirectory())/\(dbname).sqlite3"
        try self.init(filePath: filePath)
    }
    public init(filePath: String) {
        db = try! Connection(filePath)
    }

    public func saveToDB(model: NSObject) throws {
        let tableName = model.dynamicType.getTableName()
        try createTable(model, tableName: tableName)
        let names = KSMirror(model).names
        let insertSQL = "replace into \(tableName)(\(names.joinWithSeparator(","))) values(\(Array(count: names.count, repeatedValue: "?").joinWithSeparator(",")))"
        
        try db.run(insertSQL)
    }
    
    public func deleteToDB(model: NSObject) throws {

    }
    
    private func createTable(model: NSObject,tableName: String) throws {
        if createdTableNames.contains(tableName) {
            return
        }
        if let count = try db.scalar("select count(name) from sqlite_master where type='table' and name=\(tableName)") as? Int where count > 0 {
            createdTableNames.insert(tableName)
            return
        }
        let mirror = KSMirror(model)
        var table_pars = "";
        for item in mirror {
            var columnType = "text"
            if item.type is Int.Type || item.type is UInt.Type || item.type is Int64.Type || item.type is UInt64.Type || item.type is Int32.Type || item.type is UInt32.Type || item.type is Int16.Type || item.type is Int16.Type || item.type is Int8.Type || item.type is UInt8.Type || item.type is Bool.Type {
                columnType = "integer"
            }else if item.value is Float.Type || item.type is Double.Type {
                columnType = "double"
            }
            table_pars.appendContentsOf("\(item.name) \(columnType),")
        }
        table_pars = table_pars.substringToIndex(table_pars.endIndex.advancedBy(-1))
        let createTableSQL = "CREATE TABLE IF NOT EXISTS \(tableName)(\(table_pars))"
        try db.run(createTableSQL)
        createdTableNames.insert(tableName)
    }

}