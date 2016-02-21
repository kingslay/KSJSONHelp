//
//  NSObject+Model.swift
//  KSJSONHelp
//
//  Created by king on 16/2/20.
//  Copyright © 2016年 king. All rights reserved.
//

import Foundation
extension NSObject {
    public var dictionary: [String: AnyObject] {
        var data: [String: AnyObject] = [:]
        PropertyData.validPropertyDataForObject(self).forEach { (var propertyData) -> () in
            if !(propertyData.value is NSNull || "\(propertyData.value)" == "nil"){
                data[propertyData.name!] = propertyData.objectValue
            }
        }
        return data
    }
    public class func fromDictionary(dic: [String: AnyObject]) -> Self {
        let model = self.init()
        PropertyData.validPropertyDataForObject(model).forEach{ (propertyData) -> () in
            if let name = propertyData.name, let value = dic[name] {
                if !(value is NSNull || "\(value)" == "nil"){
                    model.setValue(propertyData.objectValue(propertyData.type,value:value), forKey: name)
                }
            }
        }
        return model
    }
 
    public class func objectArrayForKey(defaultName: String) -> [NSObject]? {
        if let objectArray = NSUserDefaults.standardUserDefaults().arrayForKey(defaultName) {
            return objectArray.map {
                fromDictionary($0 as! [String : AnyObject])
            }
        }else{
            return nil
        }
    }
    public class func setObjectArray(objectArray: [NSObject], forKey defaultName: String) {
        NSUserDefaults.standardUserDefaults().setObjectArray(objectArray, forKey: defaultName)
    }
}
extension NSUserDefaults {
    
    public func setObjectArray(objectArray: [NSObject], forKey defaultName: String) {
        var object :[NSDictionary] = []
        objectArray.forEach{object.append($0.dictionary)}
        setValue(object, forKey: defaultName)
    }
   
}

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