//
//  File.swift
//  KSMirror
//
//  Created by Kostiantyn Koval on 05/07/15.
//
//

import Foundation

public struct KSMirrorItem {
    public let name: String
    public let type: Any.Type
    public let value: Any
    public let disposition: _MirrorDisposition
    public var superMirror: KSMirror?
    
    init(_ tup: (String, _MirrorType)) {
        self.name = tup.0
        self.type = tup.1.valueType
        self.disposition = tup.1.disposition
        if(tup.1.disposition == _MirrorDisposition.Optional){
            //取出可选值
            if tup.1.count == 1 {
                self.value = tup.1[0].1.value
            }else{
                self.value = tup.1.value
            }
        }else{
            self.value = tup.1.value
        }
        if tup.0 == "super" && tup.1.count > 0{
            superMirror = KSMirror(tup.1)
        }
    }
}

extension KSMirrorItem : CustomStringConvertible {
    public var description: String {
        return "\(name): \(type) = \(value)"
    }
}
extension KSMirrorItem  {
    public var isClass: Bool {
        return disposition == _MirrorDisposition.Class
    }
    public var isArray: Bool {
        return disposition == _MirrorDisposition.IndexContainer
    }
    public var isOptional: Bool {
        return disposition == _MirrorDisposition.Optional
    }
}
public struct KSMirror {
    
    private let mirror: _MirrorType
    
    public init (_ x: NSObject) {
        mirror = _reflect(x)
    }
    public init (_ mirror: _MirrorType) {
        self.mirror = mirror
    }
    
    public var isClass: Bool {
        return mirror.objectIdentifier != nil
    }
    
    public var isStruct: Bool {
        return mirror.objectIdentifier == nil
    }
    
    /// Type properties count
    public var childrenCount: Int {
        return mirror.count
    }
}
//MARK: - Children Inpection
extension KSMirror {
    /// Properties Names
    public var names: [String] {
        return map { $0.name }
    }
    
    /// Properties Values
    public var values: [Any] {
        return map { $0.value }
    }
    
    /// Properties Types
    public var types: [Any.Type] {
        return map { $0.type }
    }
    
    /// Short style for type names
    public var typesShortName: [String] {
        return map { ("\($0.type)" as NSString).pathExtension }
    }
    
    /// KSMirror types for every children property
    public var children: [KSMirrorItem] {
        return map { $0 }
    }
}
//MARK: - Quering
extension KSMirror {
    /// Returns a property value for a property name
    public subscript (key: String) -> Any? {
        let res = findFirst(self) { $0.name == key }
        return res.map { $0.value }
    }
    
    /// Returns a property value for a property name with a Genereci type
    /// No casting needed
    public func get<U>(key: String) -> U? {
        let res = findFirst(self) { $0.name == key }
        return res.flatMap { $0.value as? U }
    }

}
// MARK: - Converting
extension KSMirror {
    /// Convert to a dicitonary with [PropertyName : PropertyValue] notation
    public var toDictionary: [String : Any] {
        
        var result: [String : Any] = [ : ]
        for item in self {
            result[item.name] = item.value
        }
        
        return result
    }
    
    /// Convert to NSDictionary.
    /// Useful for saving it to Plist
    public var toNSDictionary: NSDictionary {
        
        var result: [String : AnyObject] = [ : ]
        for item in self {
            result[item.name] = item.value as? AnyObject
        }
        
        return result
    }
}
extension KSMirror : CollectionType, SequenceType {
    
    public func generate() -> IndexingGenerator<[KSMirrorItem]> {
        return children.generate()
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return mirror.count
    }
    
    public subscript (i: Int) -> KSMirrorItem {
        return KSMirrorItem(mirror[i])
    }
}
