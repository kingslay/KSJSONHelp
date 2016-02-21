//
//  PropertyData.swift
//  SwiftyDB
//
//  Created by Øyvind Grimnes on 20/12/15.
//

import Foundation

internal struct PropertyData {
    
    internal let isOptional: Bool
    internal var type: Any.Type
    internal var bindingType: Binding.Type?
    internal var name: String?
    lazy internal var bindingValue: Binding? = self.toBinding(self.value)
    internal let value: Any
    
    internal var isValid: Bool {
        return name != nil
    }
    
    internal init(property: Mirror.Child) {
        self.name = property.label
        let mirror = Mirror(reflecting: property.value)
        self.type = mirror.subjectType
        isOptional = mirror.displayStyle == .Optional
        if isOptional {
            if mirror.children.count == 1 {
                self.value = mirror.children.first!.value
            }else{
                self.value = property.value
            }
        }else{
            self.value = property.value
        }
        bindingType = typeForMirror(mirror)
    }
    
    internal func typeForMirror(mirror: Mirror) -> Binding.Type? {
        if !isOptional {
            if mirror.displayStyle == .Collection {
                return NSArray.self
            }
            if mirror.displayStyle == .Dictionary {
                return NSDictionary.self
            }
            return mirror.subjectType as? Binding.Type
        }
        
        // TODO: Find a better way to unwrap optional types
        // Can easily be done using mirror if the encapsulated value is not nil
        
        switch mirror.subjectType {
        case is Optional<String>.Type:      return String.self
        case is Optional<NSString>.Type:    return NSString.self
        case is Optional<Character>.Type:   return Character.self
            
        case is Optional<NSDate>.Type:      return NSDate.self
        case is Optional<NSNumber>.Type:    return NSNumber.self
        case is Optional<NSData>.Type:      return NSData.self
            
        case is Optional<Bool>.Type:        return Bool.self
            
        case is Optional<Int>.Type:         return Int.self
        case is Optional<Int8>.Type:        return Int8.self
        case is Optional<Int16>.Type:       return Int16.self
        case is Optional<Int32>.Type:       return Int32.self
        case is Optional<Int64>.Type:       return Int64.self
        case is Optional<UInt>.Type:        return UInt.self
        case is Optional<UInt8>.Type:       return UInt8.self
        case is Optional<UInt16>.Type:      return UInt16.self
        case is Optional<UInt32>.Type:      return UInt32.self
        case is Optional<UInt64>.Type:      return UInt64.self
            
        case is Optional<Float>.Type:       return Float.self
        case is Optional<Double>.Type:      return Double.self
            
        case is Optional<NSArray>.Type:     return NSArray.self
        case is Optional<NSDictionary>.Type: return NSDictionary.self
            
        default:                            return nil
        }
    }
    
    /**
     
     Unwraps any value
     
     - parameter value:  The value to unwrap
     
     */
    
    private func toBinding(value: Any) -> Binding? {
        let mirror = Mirror(reflecting: value)
        
        if mirror.displayStyle == .Collection {
            return NSKeyedArchiver.archivedDataWithRootObject(value as! NSArray)
        }
        if mirror.displayStyle == .Dictionary {
            return NSKeyedArchiver.archivedDataWithRootObject(value as! NSDictionary)
        }
        
        /* Raw value */
        if mirror.displayStyle != .Optional {
            return value as? Binding
        }
        
        /* The encapsulated optional value if not nil, otherwise nil */
        if let value = mirror.children.first?.value {
            return toBinding(value)
        }else{
            return nil
        }
    }
}

extension PropertyData {
    internal static func validPropertyDataForObject (object: Any) -> [PropertyData] {
        return validPropertyDataForMirror(Mirror(reflecting: object))
    }
    
    private static func validPropertyDataForMirror(mirror: Mirror, var ignoredProperties: Set<String> = []) -> [PropertyData] {
        if mirror.subjectType is IgnoredProperties.Type {
            ignoredProperties = ignoredProperties.union((mirror.subjectType as! IgnoredProperties.Type).ignoredProperties())
        }
        
        var propertyData: [PropertyData] = []
        
        if let superclassMirror = mirror.superclassMirror() {
            propertyData += validPropertyDataForMirror(superclassMirror, ignoredProperties: ignoredProperties)
        }
        
        /* Map children to property data and filter out ignored or invalid properties */
        propertyData += mirror.children.map {
            PropertyData(property: $0)
            }.filter({
                $0.isValid && !ignoredProperties.contains($0.name!)
            })
        
        return propertyData
    }
}