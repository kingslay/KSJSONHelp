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
    
    public static func fromDatatypeValue(datatypeValue: Binding) -> Binding {
        return datatypeValue as! Blob
    }
    public var datatypeValue: Binding {
        return self
    }
}
extension NSData : Binding {
    
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    
    public class func fromDatatypeValue(dataValue: Binding) -> Binding {
        return NSData(bytes: (dataValue as! Blob).bytes, length: (dataValue as! Blob).bytes.count)
    }
    
    public var datatypeValue: Binding {
        return Blob(bytes: bytes, length: length)
    }
}
extension NSArray : Binding {
    
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    
    public class func fromDatatypeValue(dataValue: Binding) -> Binding {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSData(bytes: (dataValue as! Blob).bytes, length: (dataValue as! Blob).bytes.count)) as! NSArray
    }
    
    public var datatypeValue: Binding {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
}

extension NSDictionary : Binding {
    
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func fromDatatypeValue(dataValue: Binding) -> Binding {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSData(bytes: (dataValue as! Blob).bytes, length: (dataValue as! Blob).bytes.count)) as! NSDictionary
    }
    
    public var datatypeValue: Binding {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
}

public func ==(lhs: Blob, rhs: Blob) -> Bool {
    return lhs.bytes == rhs.bytes
}
