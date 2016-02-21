//
// SQLite.swift
// https://github.com/stephencelis/SQLite.swift
// Copyright © 2014-2015 Stephen Celis.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
import Foundation
public struct Blob {

    public let bytes: [UInt8]

    public init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    public init(bytes: UnsafePointer<Void>, length: Int) {
        self.init(bytes: [UInt8](UnsafeBufferPointer(
            start: UnsafePointer(bytes), count: length
        )))
    }

    public func toHex() -> String {
        return bytes.map {
            ($0 < 16 ? "0" : "") + String($0, radix: 16, uppercase: false)
        }.joinWithSeparator("")
    }

}

extension Blob : CustomStringConvertible {

    public var description: String {
        return "x'\(toHex())'"
    }

}

extension Blob : Equatable {

}

extension Blob : Binding {
    
    public static let declaredDatatype = "BLOB"
    
    public static func toAnyObject(datatypeValue: Binding) -> AnyObject {
        return NSData.toAnyObject(datatypeValue)
    }
    public var datatypeValue: Binding {
        return self
    }
}
extension NSData : Binding {
    
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    
    public class func toAnyObject(dataValue: Binding) -> AnyObject {
        return NSData(bytes: (dataValue as! Blob).bytes, length: (dataValue as! Blob).bytes.count)
    }
    
    public var datatypeValue: Binding {
        return Blob(bytes: bytes, length: length)
    }
}
extension NSArray : Binding, Value, DatatypeValue{
    
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    
    public class func toAnyObject(dataValue: Binding) -> AnyObject {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSData(bytes: (dataValue as! Blob).bytes, length: (dataValue as! Blob).bytes.count)) as! NSArray
    }
    
    public var datatypeValue: Binding {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
    public var toAnyObject: AnyObject {
        return self.map { value -> AnyObject in
            if value is Value {
                return (value as! Value ).toAnyObject
            }else{
                return value
            }
        }
    }
    public func toAnyObject(type: Any.Type) -> AnyObject {
        let genericType = generic(type)
        return self.map { value -> AnyObject in
            if value is DatatypeValue {
                return (value as! DatatypeValue).toAnyObject(genericType)
            }else{
                return value
            }
        }
    }
    private func generic(type: Any.Type) -> Any.Type {
        let clsString = "\(type)".replacingOccurrencesOfString("Array<", withString: "").replacingOccurrencesOfString("Optional<", withString: "").replacingOccurrencesOfString(">", withString: "")
        return NSClassFromString(clsString)!
    }
}

extension Array: Value {
    
    public var toAnyObject: AnyObject {
        return self.map { value -> AnyObject in
            if value is Value {
                return (value as! Value ).toAnyObject
            }else{
                return value as! AnyObject
            }
        }
    }
    
//    public func toAnyObject(type: Any.Type) -> AnyObject {
//        let genericType = generic(type)
//        let array = NSMutableArray()
//        self.forEach { value in
//            if value is DatatypeValue {
//                return array.addObject((value as! DatatypeValue).toAnyObject(genericType))
//            }else {
//                return array.addObject(value as! AnyObject)
//            }
//        }
//        return array
//    }
}

extension NSDictionary: Binding, DatatypeValue {

    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func toAnyObject(dataValue: Binding) -> AnyObject {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSData(bytes: (dataValue as! Blob).bytes, length: (dataValue as! Blob).bytes.count)) as! NSDictionary
    }
    
    public var datatypeValue: Binding {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
    public func toAnyObject(type: Any.Type) -> AnyObject {
        if self is [String : AnyObject] && type is Storable.Type {
            return (type as! Storable.Type).fromDictionary((self as! [String : AnyObject])) as! AnyObject
        }else {
            return self
        }
    }
   
}


public func ==(lhs: Blob, rhs: Blob) -> Bool {
    return lhs.bytes == rhs.bytes
}
