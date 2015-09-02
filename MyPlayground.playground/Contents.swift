//: Playground - noun: a place where people can play

import UIKit

var a: Any = 12
var b: Any = a as? Any
print(b)
var c = b as? Any
print(c)
var d: Any? = b
print(d)
var e: Optional = b
print(e!)
let someValue = 5
let someOptional: Int? = nil

switch c {
//case .Some(c):
//    print("the value is \(c)")
case .Some(let val):
    print("the value is \(val)")
default:
    print("nil")
}
//switch c {
//case let val where val == a:
//    print(val)
//default:
//    break
//}


