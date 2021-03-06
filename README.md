# 		KSJSONHelp

 a lightweight and pure Swift implemented library for  

- conversion between JSON and model. 

- Simple ActiveRecord implementation for working with your database

纯swift实现框架支持

- json、对象互相转化



- 解决对象与关系数据库映射，并快速实现 CRUD 操作的对象存储类库

## Usage 

#### convert dictionary to model

```swift
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
let person = Person.fromDictionary(dic)
```

#### convert model to dictionary

```swift
let dict = person.dictionary
```

####   CRUD operate

```swift
if let user = Person.fetchOne(dic:["name": "Old Name"]) {
	print("Found \(user.name)")
	user.name = "New Name"
	user.save()
    user.delete()
}
```


## Requirements

- Swift 2


- Xcode 7

## Installation

### CocoaPods

CocoaPods is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

``` shell
gem install cocoapods
```

To integrate Kingfisher into your Xcode project using CocoaPods, specify it in your Podfile:

``` 
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!
pod 'KSJSONHelp'
```

Then, run the following command:

``` shell
pod install
```

You should open the {Project}.xcworkspace instead of the {Project}.xcodeproj after you installed anything from CocoaPods.

For more information about how to use CocoaPods, I suggest [this tutorial](http://www.raywenderlich.com/64546/introduction-to-cocoapods-2)

### Carthage

Carthage is a decentralized dependency manager for Cocoa application. To install the carthage tool, you can use Homebrew.

``` shell
$ brew update

$ brew install carthage
```



To integrate KSJSONHelp into your Xcode project using Carthage, specify it in your Cartfile:

`github "kingslay/KSJSONHelp"`

Then, run the following command to build the KSJSONHelp framework:

`$ carthage update`

At last, you need to set up your Xcode project manually to add the KSJSONHelp framework.

On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop each framework you want to use from the Carthage/Build folder on disk.

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script with the following content:

/usr/local/bin/carthage copy-frameworks

and add the paths to the frameworks you want to use under “Input Files”:

$(SRCROOT)/Carthage/Build/iOS/KSJSONHelp.framework

For more information about how to use Carthage, please see its project page.

## Contact

Follow and contact me on [Twitter ](https://twitter.com/kingslay01)or [Sina Weibo](http://weibo.com/p/1005051702286027/home?from=page_100505&mod=TAB#place)[](http://weibo.com/p/1005051702286027/home?from=page_100505&mod=TAB#place). If you find an issue, just open a ticket on it. Pull requests are warmly welcome as well.