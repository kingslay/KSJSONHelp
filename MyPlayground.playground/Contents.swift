//: Playground - noun: a place where people can play

import Foundation
import KSJSONHelp_OSX
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
print(dic)
let a = _reflect(person.dynamicType)
print(a.count)

extension SequenceType where Generator.Element : Hashable {
    func frequencies() -> [Generator.Element:Int] {
        var results : [Generator.Element:Int] = [:]
        for element in self {
            results[element] = (results[element] ?? 0) + 1
        }
        return results
    }
}

let alpha = [2,8,2,6,1,8,2,6,6]
let beta = [6,6,6,2,2,2,8,8,1]

let sorted = alpha.frequencies().sort {
    if $0.1 > $1.1 { // if the frequency is higher, return true
        return true
    } else if $0.1 == $1.1 { // if the frequency is equal
        return $0.0 > $1.0 // return value is higher
    } else {
        return false // else return false
    }
}
print(sorted)

