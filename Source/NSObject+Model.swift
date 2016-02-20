//
//  NSObject+Model.swift
//  KSJSONHelp
//
//  Created by king on 16/2/20.
//  Copyright © 2016年 king. All rights reserved.
//

import Foundation

extension Model where Self: NSObject {
    public init(serialized: [String: Binding?]){
        self.init()
        let propertyDatas = PropertyData.validPropertyDataForObject(self)
//        for propertyData in propertyDatas {
//            propertyData.type!.fromDatatypeValue(serialized[propertyData.name!])
//        }
        var validData: [String: AnyObject] = [:]
        serialized.forEach { (name, value) -> () in
            if let validValue = value as? AnyObject {
                validData[name] = validValue
            }
        }
        self.setValuesForKeysWithDictionary(validData)
    }
}