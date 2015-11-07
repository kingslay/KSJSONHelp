//
//  NSObject+KeyValues.swift
//  CFRuntime
//
//  Created by 成林 on 15/7/10.
//  Copyright (c) 2015年 冯成林. All rights reserved.
//

import Foundation

extension NSObject {
    /**  一键字典转模型  */
    public class func toModel(dict: [String : AnyObject]) -> Self{
        let model = self.init()
        let mirror = KSMirror(model)
        model.toModel(mirror,dict: dict)
        return model
    }
    private func toModel(mirror: KSMirror,dict: [String : AnyObject]){
        let mappingDict = self.mappingDict()
        for item in mirror {
            if item.name == "super" {
                if let superMirror = item.superMirror {
                    self.toModel(superMirror, dict: dict)
                }
                continue
            }
            var key = item.name
            key = mappingDict?[key] ?? key
            if let value = dict[key] {
                if value is NSNull {
                    continue
                }
                if value is NSArray {
                    let genericType = NSObject.genericType(item)
                    let arrM = NSMutableArray()
                    for  genericValue in value as! NSArray {
                        arrM.addObject(NSObject.transformValue(genericType, value: genericValue))
                    }
                    self.setValue(arrM, forKeyPath: key)
                }else{
                    self.setValue(NSObject.transformValue(item.type, value: value), forKeyPath: key)
                }
            }
        }
    }
    
    
    public class func toModels(array: [[String : AnyObject]]) -> [NSObject]{
        var models: [NSObject] = []
        
        for value in array {
            models.append(self.toModel(value))
        }
        return models
    }
    
    /**  一键模型转字典  */
    public func toDictionary() -> [String : AnyObject]{
        return toDictionary(KSMirror(self))
    }
    private func toDictionary(mirror: KSMirror) -> [String : AnyObject]{
        
        var dict = [String : AnyObject]()
        for item in mirror {
            if item.name == "super" {
                if let superMirror = item.superMirror {
                    let superDict = toDictionary(superMirror);
                    for (k,v) in superDict{
                        dict[k] = v
                    }
                }
                continue
            }
            let value = item.value
            if item.isOptional {
                if "\(value)" == "nil" {
                    continue
                }
            }
            dict[item.name] = NSObject.transformValue(value)
        }
        return dict
    }
    
    /**  字段映射  */
    public func mappingDict() -> [String: String]? {
        return nil
    }
    /**  数组Element类型截取：截取字符串并返回一个类型  */
    public class func genericType(item: KSMirrorItem) -> Any.Type {
        let clsString = "\(item.type)".replacingOccurrencesOfString("Array<", withString: "").replacingOccurrencesOfString("Optional<", withString: "").replacingOccurrencesOfString(">", withString: "")
        return NSClassFromString(clsString)!
    }
    
    
    private class func transformValue(type: Any.Type,value: Any) -> AnyObject{
        if type is Int.Type || type is Optional<Int>.Type {
            if value is String {
                return Int(value as! String)!
            }
            return value as! Int
        }else if type is Float.Type || type is Optional<Float>.Type {
            if value is String {
                return Float(value as! String)!
            }
            return value as! Float
        }else if type is Double.Type || type is Optional<Double>.Type {
            if value is String {
                return Double(value as! String)!
            }
            return value as! Double
        }else if type is String.Type || type is Optional<String>.Type || type is NSString.Type || type is Optional<NSString>.Type  {
            return value as! String
        }else if value is [String : AnyObject] {
            return (type as! NSObject.Type).toModel(value as! [String : AnyObject])
        }
        return value as! AnyObject
    }
    private class func transformValue(value: Any) -> AnyObject {
        if value is NSArray {
            var dictM: [AnyObject] = []
            let valueArray = value as! NSArray
            for item in valueArray {
                dictM.append(NSObject.transformValue(item))
            }
            return dictM
        }else if value is NSNumber {
            return value as! NSNumber
        }else if value is NSString {
            return value as! NSString
        }else if value is NSObject {
            return (value as! NSObject).toDictionary()
        }else if value is Int8 {
            return NSNumber(char: value as! Int8)
        }else if value is UInt8 {
            return NSNumber(unsignedChar: value as! UInt8)
        }else if value is Int16 {
            return NSNumber(short: value as! Int16)
        }else if value is UInt16 {
            return NSNumber(unsignedShort: value as! UInt16)
        }else if value is Int32 {
            return NSNumber(int: value as! Int32)
        }else if value is UInt32 {
            return NSNumber(unsignedInt: value as! UInt32)
        }else if value is Int64 {
            return NSNumber(longLong: value as! Int64)
        }else if value is UInt64 {
            return NSNumber(unsignedLongLong: value as! UInt64)
        }
        return value as! AnyObject
    }
}
///保存数组数据到NSUserDefaults
extension NSObject {
    public class func objectArrayForKey(defaultName: String) -> [NSObject]? {
        if let objectArray = NSUserDefaults.standardUserDefaults().arrayForKey(defaultName) {
            var object :[NSObject] = []
            objectArray.forEach{object.append(toModel($0 as! [String : AnyObject]))}
            return object
        }else{
            return nil
        }
    }
    public class func setObjectArray(objectArray: [NSObject], forKey defaultName: String) {
        var object :[NSDictionary] = []
        objectArray.forEach{object.append($0.toDictionary())}
        NSUserDefaults.standardUserDefaults().setValue(object, forKey: defaultName)
    }
}

