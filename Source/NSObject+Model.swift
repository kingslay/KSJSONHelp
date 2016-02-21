//
//  NSObject+Model.swift
//  KSJSONHelp
//
//  Created by king on 16/2/20.
//  Copyright © 2016年 king. All rights reserved.
//

import Foundation

//extension Dictionary {
//    public func toModel <D where D: Model, D: Storable> () -> D {
//        let model = D.init()
//        var validData: [String: AnyObject] = [:]
//        self.forEach { (key, value) -> () in
//            if let name = key as? String, let validValue = value as? AnyObject {
//                validData[name] = validValue
//            }
//        }
//        model.setValuesForKeysWithDictionary(validData)
//        return model
//    }
//}
//extension Array {
//    public func toModels <D where D: NSObject> () -> [D] {
//        var array: [D] = []
//        self.forEach { (element) -> () in
//            if let dic = element as? Dictionary<String,AnyObject> {
//                array.append(D.fromDictionary(dic))
//            }
//        }
//        return array
//    }
//}