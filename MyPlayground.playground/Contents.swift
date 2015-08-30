//: Playground - noun: a place where people can play

import UIKit
@objc(Person)
class Person: NSObject {
    var name: String?
    var age: Int
    override init(){
        age = 1
    }
    init(name: String,age: Int) {
        self.name = name
        self.age = age
    }
}
var str = "Hello, playground"
let a = NSStringFromClass(Person)
NSStringFromClass(Person)
NSStringFromClass(Person)


NSClassFromString("Person")




