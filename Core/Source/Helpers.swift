//
//  Helpers.swift
//  KSMirror
//
//  Created by Kostiantyn Koval on 05/07/15.
//
//
import Foundation
internal extension String{
    
    func contain(_ subStr: String) -> Bool {return (self as NSString).range(of: subStr).length > 0}
    
    func explode (_ separator: String) -> [String] {
        return self.components(separatedBy: separator)
    }
    
    func replacingOccurrencesOfString(_ target: String, withString: String) -> String{
        return (self as NSString).replacingOccurrences(of: target, with: withString)
    }
    
    var floatValue: Float? {return NumberFormatter().number(from: self)?.floatValue}
    var doubleValue: Double? {return NumberFormatter().number(from: self)?.doubleValue}
    
    
    func quote(_ mark: Character = "\"") -> String {
        let escaped = characters.reduce("") { string, character in
            string + (character == mark ? "\(mark)\(mark)" : "\(character)")
        }
        return "\(mark)\(escaped)\(mark)"
    }
}
