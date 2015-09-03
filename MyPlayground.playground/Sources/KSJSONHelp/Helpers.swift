//
//  Helpers.swift
//  KSMirror
//
//  Created by Kostiantyn Koval on 05/07/15.
//
//
import Foundation
func findFirst<S : SequenceType> (s: S, condition: (S.Generator.Element) -> Bool) -> S.Generator.Element? {
  
  for value in s {
    if condition(value) {
      return value
    }
  }
  return nil
}
func SwiftClassFromString(className: String) -> AnyClass! {
    // get the project name
    if  var appName  = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String? {
        // generate the full name of your class (take a look into your "YourProject-swift.h" file)
        let classStringName = "_TtC\(appName.characters.count)\(appName)\(className.characters.count)\(className)"
        // return the class!
        return NSClassFromString(classStringName)
    }
    return nil;
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
}
