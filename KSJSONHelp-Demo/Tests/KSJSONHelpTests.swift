//
//  KSJSONHelpTests.swift
//  KSJSONHelpTests
//
//  Created by king on 15/8/30.
//  Copyright © 2015年 king. All rights reserved.
//

import XCTest

import KSJSONHelp

@objc(Person)
class Person: NSObject, Storable, Model {
    var name: String
    var weight: CGFloat
    var height: NSInteger
    var age: Int64
    var sex: Bool = false
    override required init() {
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
class Person1: NSObject, Storable, Model {
    var name: String?
    var age: NSNumber?
    var city: String?
    override required init(){
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
class KSJSONHelpTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func dicEqual(dic1: [String: AnyObject], _ dic2: [String: AnyObject]){
        assert((dic1 as NSDictionary) == (dic2 as NSDictionary))
    }
    func testAggregate() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let person = Person(name: "wang", age: 30)
        person.sex = true
        let dic = person.dictionary
        assert(person.age == (dic["age"] as! NSNumber).longLongValue)
        Person.fromArray([dic])
        let personNew = Person.fromDictionary(dic)
        print(dic)
        dicEqual(dic, personNew.dictionary)
    }
    func testOptionalAggregate() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let person = Person1(name: "wang", age: 30)
        let dic = person.dictionary
        let personNew = Person1.fromDictionary(dic)
        dicEqual(dic, personNew.dictionary)
        print(dic)
    }
    
    
    func testArray() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let person = Person2(name: "wang", age: 30)
        person.books = ["a","b"]
        person.child = [ Person(name: "xiaowang", age: 1) ]
        let dic = person.dictionary
        print(dic)
        let personNew = Person2.fromDictionary(dic)
        dicEqual(dic, personNew.dictionary)

    }
    func testOptionalArray() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let person = Person3(name: "wang", age: 30)
        person.books = ["a","b"]
        person.child = [ Person(name: "xiaowang", age: 1) ]
        let dic = person.dictionary
        let personNew = Person3.fromDictionary(dic)
        dicEqual(dic, personNew.dictionary)
        print(dic)
        
    }
    func testNSUserDefault() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let person = Person3(name: "wang", age: 30)
        person.books = ["a","b"]
        person.child = [ Person(name: "xiaowang", age: 1) ]
        Person3.setObjectArray([person], forKey: "person")
        let personArray = Person3.objectArrayForKey("person")
        dicEqual(personArray![0].dictionary, person.dictionary)
        print(personArray![0].dictionary)
        
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
