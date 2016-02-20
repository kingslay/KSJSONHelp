/// - Warning: `Binding` is a protocol that SQLite.swift uses internally to
///   directly map SQLite types to Swift types.
///
///   Do not conform custom types to the Binding protocol. See the `Value`
///   protocol, instead.
import Foundation
public protocol Binding {
    static var declaredDatatype: String { get }
    var datatypeValue: Binding { get }
}
extension Binding {
    public var datatypeValue: Binding {
        return self
    }
}

public protocol Number : Binding {}

public protocol Value : Binding { // extensions cannot have inheritance clauses
    typealias ValueType = Self
    static func fromDatatypeValue(datatypeValue: Binding) -> ValueType

}

//@warn_unused_result func value<A: Value>(v: Binding) -> A {
//    return A.fromDatatypeValue(v as! A.Datatype) as! A
//}
//
//@warn_unused_result func value<A: Value>(v: Binding?) -> A {
//    return value(v!)
//}

extension Double : Number, Value {

    public static let declaredDatatype = "REAL"

    public static func fromDatatypeValue(datatypeValue: Binding) -> Double {
        return datatypeValue as! Double
    }
}
extension Float : Number, Value {
    
    public static let declaredDatatype = "REAL"
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> Double {
        return datatypeValue as! Double
    }
    public var datatypeValue: Double {
        return Double(self)
    }
}
extension Int : Number, Value {
    
    public static var declaredDatatype = Int64.declaredDatatype
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> Int {
        return Int(datatypeValue as! Int64)
    }
    
    public var datatypeValue: Int64 {
        return Int64(self)
    }
    
}

extension UInt : Number, Value {
    
    public static var declaredDatatype = Int64.declaredDatatype
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> UInt {
        return UInt(datatypeValue as! Int64)
    }
    
    public var datatypeValue: Int64 {
        return Int64(self)
    }
    
}
extension Int64 : Number, Value {

    public static let declaredDatatype = "INTEGER"

    public static func fromDatatypeValue(datatypeValue: Binding) -> Int64 {
        return datatypeValue as! Int64
    }
}
extension UInt64 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> UInt64 {
        return UInt64(datatypeValue as! Int64)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension Int32 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> Int32 {
        return Int32(datatypeValue as! Int64)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension UInt32 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> Int32 {
        return Int32(datatypeValue as! Int64)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension Int16 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> Int16 {
        return Int16(datatypeValue as! Int64)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension UInt16 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> UInt16 {
        return UInt16(datatypeValue as! Int64)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension Int8 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> Int8 {
        return Int8(datatypeValue as! Int64)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension UInt8 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> UInt8 {
        return UInt8(datatypeValue as! Int64)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension Bool : Binding, Value {
    
    public static var declaredDatatype = Int64.declaredDatatype
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> Bool {
        return datatypeValue as! Int64 != 0
    }
    
    public var datatypeValue: Int64 {
        return self ? 1 : 0
    }
}
extension NSDate : Number, Value {
    
    public static let declaredDatatype = "REAL"
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> NSDate {
        return NSDate(timeIntervalSince1970: datatypeValue as! Double)
    }
    public var datatypeValue: Double {
        return self.timeIntervalSince1970
    }
}
extension NSNumber : Number, Value {
    
    public static let declaredDatatype = "REAL"
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> NSNumber {
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

extension String : Binding, Value {

    public static let declaredDatatype = "TEXT"

    public static func fromDatatypeValue(datatypeValue: Binding) -> String {
        return datatypeValue as! String
    }
}
extension NSString : Binding, Value {
    
    public static let declaredDatatype = "TEXT"
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> NSString {
        return datatypeValue as! String
    }
    public var datatypeValue: String {
        return self as String
    }
}

extension Character : Binding, Value {
    
    public static let declaredDatatype = "TEXT"
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> Character {
        return (datatypeValue as! String).characters.first!
    }
    public var datatypeValue: String {
        return String(self)
    }
}


