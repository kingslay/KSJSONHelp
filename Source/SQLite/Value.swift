/// - Warning: `Binding` is a protocol that SQLite.swift uses internally to
///   directly map SQLite types to Swift types.
///
///   Do not conform custom types to the Binding protocol. See the `Value`
///   protocol, instead.
import Foundation
public protocol Binding {
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

    typealias Datatype : Binding

    static var declaredDatatype: String { get }

    static func fromDatatypeValue(datatypeValue: Datatype) -> ValueType

}

extension Double : Number, Value {

    public static let declaredDatatype = "REAL"

    public static func fromDatatypeValue(datatypeValue: Double) -> Double {
        return datatypeValue
    }
}
extension Float : Number, Value {
    
    public static let declaredDatatype = "REAL"
    
    public static func fromDatatypeValue(datatypeValue: Double) -> Double {
        return datatypeValue
    }
    public var datatypeValue: Double {
        return Double(self)
    }
}
extension Int : Number, Value {
    
    public static var declaredDatatype = Int64.declaredDatatype
    
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int {
        return Int(datatypeValue)
    }
    
    public var datatypeValue: Int64 {
        return Int64(self)
    }
    
}

extension Int64 : Number, Value {

    public static let declaredDatatype = "INTEGER"

    public static func fromDatatypeValue(datatypeValue: Int64) -> Int64 {
        return datatypeValue
    }
}
extension UInt64 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Int64) -> UInt64 {
        return UInt64(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension Int32 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int32 {
        return Int32(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension UInt32 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int32 {
        return Int32(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension Int16 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int16 {
        return Int16(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension UInt16 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Int64) -> UInt16 {
        return UInt16(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension Int8 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int8 {
        return Int8(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension UInt8 : Number, Value {
    
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(datatypeValue: Int64) -> UInt8 {
        return UInt8(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}
extension Bool : Binding, Value {
    
    public static var declaredDatatype = Int64.declaredDatatype
    
    public static func fromDatatypeValue(datatypeValue: Int64) -> Bool {
        return datatypeValue != 0
    }
    
    public var datatypeValue: Int64 {
        return self ? 1 : 0
    }
}
extension NSDate : Number, Value {
    
    public static let declaredDatatype = "REAL"
    
    public static func fromDatatypeValue(datatypeValue: Double) -> NSDate {
        return NSDate(timeIntervalSince1970: datatypeValue)
    }
    public var datatypeValue: Double {
        return self.timeIntervalSince1970
    }
}
extension NSNumber : Number, Value {
    
    public static let declaredDatatype = "REAL"
    
    public static func fromDatatypeValue(datatypeValue: Double) -> NSNumber {
        return NSNumber(double: datatypeValue)
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

    public static func fromDatatypeValue(datatypeValue: String) -> String {
        return datatypeValue
    }
}
extension NSString : Binding, Value {
    
    public static let declaredDatatype = "TEXT"
    
    public static func fromDatatypeValue(datatypeValue: String) -> NSString {
        return datatypeValue
    }
    public var datatypeValue: String {
        return self as String
    }
}

extension Character : Binding, Value {
    
    public static let declaredDatatype = "TEXT"
    
    public static func fromDatatypeValue(datatypeValue: String) -> Character {
        return datatypeValue.characters.first!
    }
    public var datatypeValue: String {
        return String(self)
    }
}

extension Blob : Binding, Value {

    public static let declaredDatatype = "BLOB"

    public static func fromDatatypeValue(datatypeValue: Blob) -> Blob {
        return datatypeValue
    }
}
extension NSData : Value {
    
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    
    public class func fromDatatypeValue(dataValue: Blob) -> NSData {
        return NSData(bytes: dataValue.bytes, length: dataValue.bytes.count)
    }
    
    public var datatypeValue: Blob {
        return Blob(bytes: bytes, length: length)
    }
}
extension NSArray : Value {
    
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    
    public class func fromDatatypeValue(dataValue: Blob) -> NSArray {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSData(bytes: dataValue.bytes, length: dataValue.bytes.count)) as! NSArray
    }
    
    public var datatypeValue: NSData {
         return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
}

extension NSDictionary : Value {
    
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func fromDatatypeValue(dataValue: Blob) -> NSDictionary {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSData(bytes: dataValue.bytes, length: dataValue.bytes.count)) as! NSDictionary
    }
    
    public var datatypeValue: NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
}


