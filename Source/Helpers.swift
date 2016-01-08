//
//  Helpers.swift
//  KSMirror
//
//  Created by Kostiantyn Koval on 05/07/15.
//
//
import Foundation
internal func findFirst<S : SequenceType> (s: S, condition: (S.Generator.Element) -> Bool) -> S.Generator.Element? {
    for value in s where condition(value) {
        return value
    }
    return nil
}

public extension Dictionary where Key: StringLiteralConvertible {
    /// Initialize from mirror with [PropertyName : PropertyValue] notation.
    public init(mirror: KSMirror) {
        self = [:]
        for item in mirror {
            guard let label = item.name as? Key,
                value = item.value as? Value else { continue }
            
            self[label] = value
        }
    }
}

extension String{
    
    func contain(subStr: String) -> Bool {return (self as NSString).rangeOfString(subStr).length > 0}
    
    func explode (separator: String) -> [String] {
        return self.componentsSeparatedByString(separator)
    }
    
    func replacingOccurrencesOfString(target: String, withString: String) -> String{
        return (self as NSString).stringByReplacingOccurrencesOfString(target, withString: withString)
    }
    
    var floatValue: Float? {return NSNumberFormatter().numberFromString(self)?.floatValue}
    var doubleValue: Double? {return NSNumberFormatter().numberFromString(self)?.doubleValue}
    
    
    @warn_unused_result func quote(mark: Character = "\"") -> String {
        let escaped = characters.reduce("") { string, character in
            string + (character == mark ? "\(mark)\(mark)" : "\(character)")
        }
        return "\(mark)\(escaped)\(mark)"
    }
}
