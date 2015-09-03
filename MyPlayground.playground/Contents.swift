//: Playground - noun: a place where people can play

import UIKit

@objc(Person)
class Person: NSObject {
    var name: String
    var weight: CGFloat
    var height: NSInteger
    var age: Int64
    var sex: Bool = false
    override init(){
        name = ""
        age = 1
        height = 11
        weight = 11.111
    }
    init(name: String,age: Int64,height: NSInteger = 11,weight: CGFloat = 11.1111) {
        self.name = name
        self.age = age
        self.height = height
        self.weight = weight
    }
}
class Person1: NSObject {
    var name: String?
    var age: NSNumber?
    override init(){
        name = ""
        age = 1
    }
    init(name: String,age: Int) {
        self.name = name
        self.age = age
    }
}
class Person2: Person {
    var books: [NSString] = []
    var child: [Person] = []
}
class Person3: Person {
    var books: [NSString]?
    var child: [Person]?
}

let person = Person(name: "wang", age: 30)
person.sex = true
let dic = person.toDictionary()
let personNew = Person.toModel(dic)
assert(dic == personNew.toDictionary())
print(dic)

