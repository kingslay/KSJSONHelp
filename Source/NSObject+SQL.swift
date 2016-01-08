//
//  NSObject+SQL.swift
//  KSJSONHelp
//
//  Created by king on 16/1/7.
//  Copyright © 2016年 king. All rights reserved.
//

import Foundation
/**  一键模型插入sqlite  */
extension NSObject {
    public static var usingLKDBHelper = KSDBHelper()
    ///表名
    public class func getTableName() -> String{
        return "\(self.dynamicType)"
    }
    
    public func saveToDB() -> Bool {
        do{
            try self.dynamicType.usingLKDBHelper.saveToDB(self)
        } catch let error as Result {
            print(error)
            return false
        } catch {
            fatalError()
            return false
        }
        return true
    }
    public func deleteToDB() -> Bool {
        do{
            try self.dynamicType.usingLKDBHelper.deleteToDB(self)
        } catch let error as Result {
            print(error)
            return false
        } catch {
            fatalError()
            return false
        }
        return true
    }
}

