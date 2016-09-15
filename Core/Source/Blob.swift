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
    public init(ptr: UnsafeRawPointer,count:Int) {
        let data = Data(bytes: unsafeBitCast(ptr, to: UnsafePointer<UInt8>.self), count: count)
        self.init(bytes:data.toArray(type: UInt8.self))
    }

    public func toHex() -> String {
        return bytes.map {
            ($0 < 16 ? "0" : "") + String($0, radix: 16, uppercase: false)
        }.joined(separator: "")
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
    
    public static func toAnyObject(_ datatypeValue: Binding) -> AnyObject {
        return Data.toAnyObject(datatypeValue)
    }
    public var datatypeValue: Binding {
        return self
    }
}
extension Data : Binding {
    
    public static var declaredDatatype: String {
        return Blob.declaredDatatype
    }

    public static func toAnyObject(_ dataValue: Binding) -> AnyObject {
        let bytes = (dataValue as! Blob).bytes
        return Data(bytes: bytes) as AnyObject
    }
    
    public var datatypeValue: Binding {
        return Blob(bytes: self.toArray(type: UInt8.self))
    }
}
extension NSArray : Binding, Serialization, Deserialization{
    
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }

    public class func toAnyObject(_ dataValue: Binding) -> AnyObject {
        return NSKeyedUnarchiver.unarchiveObject(with:Data(bytes: (dataValue as! Blob).bytes)) as! NSArray
    }
    
    public var datatypeValue: Binding {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    public var serialization: AnyObject {
        return self.map { value -> AnyObject in
            if let serialization = value as? Serialization {
                return serialization.serialization
            }else{
                return value as AnyObject
            }
        } as AnyObject
    }
    public func deserialization(_ type: Any.Type) -> AnyObject {
        let genericType = generic(type: type)
        return self.map { value -> AnyObject in
            if let deserialization = value as? Deserialization {
                return deserialization.deserialization(genericType)
            }else{
                return value as AnyObject
            }
        } as AnyObject
    }
    private func generic(type: Any.Type) -> Any.Type {
        let clsString = "\(type)".replacingOccurrencesOfString("Array<", withString: "").replacingOccurrencesOfString("Optional<", withString: "").replacingOccurrencesOfString(">", withString: "")
        return NSClassFromString(clsString)!
    }
}

extension Array: Serialization {
    
    public var serialization: AnyObject {
        return self.map { value -> AnyObject in
            if let serialization = value as? Serialization {
                return serialization.serialization
            }else{
                return value as! AnyObject
            }
        } as AnyObject
    }
}

extension NSDictionary: Binding, Deserialization {

    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func toAnyObject(_ dataValue: Binding) -> AnyObject {
        return NSKeyedUnarchiver.unarchiveObject(with: Data(bytes: (dataValue as! Blob).bytes)) as! NSDictionary
    }
    
    public var datatypeValue: Binding {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    public func deserialization(_ type: Any.Type) -> AnyObject {
        if let dic = self as? [String : AnyObject], let storable = type as? Storable.Type {
            return storable.init(from: dic) as! AnyObject
        }else {
            return self
        }
    }
   
}


public func ==(lhs: Blob, rhs: Blob) -> Bool {
    return lhs.bytes == rhs.bytes
}
extension Data {

    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}
extension Data {

    init<T>(fromArray values: [T]) {
        var values = values
        self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
    }

    func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.size))
        }
    }
}
