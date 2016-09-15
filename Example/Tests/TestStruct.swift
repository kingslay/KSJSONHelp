//
//  TestStruct.swift
//  KSJSONHelp
//
//  Created by king on 16/5/7.
//  Copyright © 2016年 king. All rights reserved.
//

import XCTest
import KSJSONHelp
struct StructTestModel: Storable,Model {
    var pointId: Int64?
    var title: String?
    var favorite: Bool
    init() {
        favorite = false
    }
    func setValue(_ value: Any?, forKey key: String) {
        
    }
}
class TestStruct: SQLiteTestCase {
    func testSave() {
        let berlin = StructTestModel()
        berlin.save()
        let object = StructTestModel.fetch(nil)![0]
        object.favorite 
        assert(object.favorite == berlin.favorite)

        
    }
   
}
