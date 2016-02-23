//
//  DynamicRetrievalSpec.swift
//  SwiftyDB
//
//  Created by Øyvind Grimnes on 13/01/16.
//
import Foundation
import KSJSONHelp

class DynamicRetrievalSpec: SQLiteTestCase {
    func testSave() {
        let dynamicObject = DynamicTestClass()
        dynamicObject.string = "not default value"
        dynamicObject.nsstring = "not default value"
        dynamicObject.int = 123
        dynamicObject.uint = 123
        dynamicObject.int64 = 123
        dynamicObject.uint64 = 123
        dynamicObject.number = 123
        dynamicObject.data = dynamicObject.string.dataUsingEncoding(NSUTF8StringEncoding)!
        dynamicObject.date = NSDate(timeIntervalSince1970: 123123)
        dynamicObject.bool = true
        dynamicObject.float = 123
        dynamicObject.double = 123
        dynamicObject.array = ["1"]
        dynamicObject.dic = ["1":1]
        dynamicObject.optionalArray = [1]
        dynamicObject.save()
        let retrievedDynamicObject = DynamicTestClass.fetchOne(dic:["primaryKey": dynamicObject.primaryKey])!
        assert(retrievedDynamicObject.string == dynamicObject.string)
        assert(retrievedDynamicObject.nsstring == dynamicObject.nsstring)
        assert(retrievedDynamicObject.number == dynamicObject.number)
        assert(retrievedDynamicObject.int == dynamicObject.int)
        assert(retrievedDynamicObject.uint == dynamicObject.uint)
        assert(retrievedDynamicObject.int64 == dynamicObject.int64)
        assert(retrievedDynamicObject.uint64 == dynamicObject.uint64)
        assert(retrievedDynamicObject.bool == dynamicObject.bool)
        assert(retrievedDynamicObject.float == dynamicObject.float)
        assert(retrievedDynamicObject.double == dynamicObject.double)
        assert(retrievedDynamicObject.date.isEqualToDate(dynamicObject.date))
        assert(retrievedDynamicObject.data.isEqualToData(dynamicObject.data))
        assert(retrievedDynamicObject.array == dynamicObject.array)
        assert(retrievedDynamicObject.optionalArray == dynamicObject.optionalArray)
        assert(retrievedDynamicObject.dic == dynamicObject.dic)
        assert(retrievedDynamicObject.optionalDictionary == dynamicObject.optionalDictionary)
        assert(DynamicTestClass.fetch(nil)?.count == 1)
        assert(DynamicTestClass.fetchOne(dic:["primaryKey": 2]) == nil )
        dynamicObject.save()
        assert(DynamicTestClass.fetch(nil)?.count == 1)
        dynamicObject.primaryKey = 2
        dynamicObject.save()
        assert(DynamicTestClass.fetch(nil)?.count == 2)
        dynamicObject.delete()
        assert(DynamicTestClass.fetch(nil)?.count == 1)
        DynamicTestClass.delete(dic:[:])
        assert(DynamicTestClass.fetch(nil)?.count == 0)

        
        
    }
}
