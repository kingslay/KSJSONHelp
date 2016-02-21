/// - Warning: `Binding` is a protocol that SQLite.swift uses internally to
///   directly map SQLite types to Swift types.
///
///   Do not conform custom types to the Binding protocol. See the `Value`
///   protocol, instead.
import Foundation
///数据库绑定类型
public protocol Binding {
    static var declaredDatatype: String { get }
    var datatypeValue: Binding { get }
    static func toAnyObject(datatypeValue: Binding) -> AnyObject
}

@warn_unused_result func wrapValue<A: Binding>(v: Binding) -> A {
    return A.toAnyObject(v) as! A
}

@warn_unused_result func wrapValue<A: Binding>(v: Binding?) -> A {
    return wrapValue(v!)
}
///进行序列化如：把对象专为字典
public protocol Serialization {
    var serialization: AnyObject { get }
}
///进行反序列化：把字典转为对象
public protocol Deserialization {
    func deserialization(type: Any.Type) -> AnyObject
}

public protocol Number {
    
}

extension Double : Binding, Number {

    public static let declaredDatatype = "REAL"

    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return datatypeValue as! Double
    }
    public var datatypeValue: Binding {
        return self
    }
}
extension Float : Binding, Number {
    
    public static let declaredDatatype = "REAL"
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return datatypeValue as! Double
    }
    public var datatypeValue: Binding {
        return Double(self)
    }
}
extension Int : Binding, Number {
    
    public static var declaredDatatype = Int64.declaredDatatype
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return Int(datatypeValue as! Int64)
    }
    
    public var datatypeValue: Binding {
        return Int64(self)
    }
    
}

extension UInt : Binding, Number {
    
    public static var declaredDatatype = Int64.declaredDatatype
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return UInt(datatypeValue as! Int64)
    }
    
    public var datatypeValue: Binding {
        return Int64(self)
    }
    
}
extension Int64 : Binding, Number, Serialization {

    public static let declaredDatatype = "INTEGER"

    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return (datatypeValue as! Int64).serialization
    }
    public var datatypeValue: Binding {
        return self
    }
    public var serialization: AnyObject {
        return NSNumber(longLong: self)
    }

}
extension UInt64 : Binding, Number, Serialization {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return UInt64(datatypeValue as! Int64).serialization
    }
    public var datatypeValue: Binding {
        return Int64(self)
    }
    public var serialization: AnyObject {
        return NSNumber(unsignedLongLong: self)
    }

}
extension Int32 : Binding, Number, Serialization {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return Int32(datatypeValue as! Int64).serialization
    }
    public var datatypeValue: Binding {
        return Int64(self)
    }
    public var serialization: AnyObject {
        return NSNumber(int: self)
    }
}
extension UInt32 : Binding, Number, Serialization {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return UInt32(datatypeValue as! Int64).serialization
    }
    public var datatypeValue: Binding {
        return Int64(self)
    }
    public var serialization: AnyObject {
        return NSNumber(unsignedInt: self)
    }
}
extension Int16 : Binding, Number, Serialization {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return Int16(datatypeValue as! Int64).serialization
    }
    public var datatypeValue: Binding {
        return Int64(self)
    }
    public var serialization: AnyObject {
        return NSNumber(short: self)
    }
}
extension UInt16 : Binding, Number, Serialization {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return UInt16(datatypeValue as! Int64).serialization
    }
    public var datatypeValue: Binding {
        return Int64(self)
    }
    public var serialization: AnyObject {
        return NSNumber(unsignedShort: self)
    }
}
extension Int8 : Binding, Number, Serialization {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return Int8(datatypeValue as! Int64).serialization
    }
    public var datatypeValue: Binding {
        return Int64(self)
    }
    public var serialization: AnyObject {
        return NSNumber(char: self)
    }
}
extension UInt8 : Binding, Number, Serialization {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return UInt8(datatypeValue as! Int64).serialization
    }
    public var datatypeValue: Binding {
        return Int64(self)
    }
    public var serialization: AnyObject {
        return NSNumber(unsignedChar: self)
    }
}
extension Bool : Binding {
    
    public static var declaredDatatype = Int64.declaredDatatype
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return datatypeValue as! Int64 != 0
    }
    
    public var datatypeValue: Binding {
        return self ? 1 : 0
    }
}
extension NSDate : Binding, Number {
    
    public class var declaredDatatype: String {
        return "REAL"
    }
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return NSDate(timeIntervalSince1970: datatypeValue as! Double)
    }
    public var datatypeValue: Binding {
        return self.timeIntervalSince1970
    }
}
extension NSNumber : Binding, Number {
    
    public class var declaredDatatype: String {
        return "REAL"
    }
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        if let double = datatypeValue as? Double {
            return NSNumber(double: double)
        }else if let longLong = datatypeValue as? Int64 {
            return NSNumber(longLong: longLong)
        }else{
            return NSNumber()
        }
    }
    public var datatypeValue: Binding {
        let typeString = String.fromCString(self.objCType)
        switch typeString! {
        case "c":
            return Int64(self.charValue)
        case "i":
            return Int64(self.intValue)
        case "s":
            return Int64(self.shortValue)
        case "l":
            return Int64(self.longValue)
        case "q":
            return self.longLongValue
        case "C":
            return Int64(self.charValue)
        case "I":
            return Int64(self.unsignedIntValue)
        case "S":
            return Int64(self.unsignedShortValue)
        case "L":
            return Int64(self.unsignedLongValue)
        case "Q":
            return Int64(self.unsignedLongLongValue)
        case "B":
            return Int64(self.boolValue ? 1 : 0)
        case "f", "d":
            return self.doubleValue
        default:
            return self.description
        }
    }
}

extension String : Binding {

    public static let declaredDatatype = "TEXT"

    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return datatypeValue as! String
    }
    public var datatypeValue: Binding {
        return self
    }
}

extension Character : Binding {
    
    public static let declaredDatatype = "TEXT"
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return datatypeValue as! String
    }
    public var datatypeValue: Binding {
        return String(self)
    }
}

extension NSString : Binding {
    
    public class var declaredDatatype: String {
        return String.declaredDatatype
    }
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return datatypeValue as! String
    }
    public var datatypeValue: Binding {
        return self as String
    }
}


