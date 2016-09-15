import Foundation
/**
	Base model for all Fluent entities.
 
	Override the `table()`, `serialize()`, and `init(serialized:)`
	methods on your subclass.
 */
 /** Implement this protocol to use primary keys */
public protocol PrimaryKeyProtocol {
    /**
     Method used to define a set of primary keys for the types table
     
     - returns:  set of property names
     */
    static func primaryKeys() -> Set<String>
}

/** Implement this protocol to ignore arbitrary properties */
public protocol IgnoredPropertieProtocol {
    /**
     Method used to define a set of ignored properties
     
     - returns:  set of property names
     */
    static func ignoredProperties() -> Set<String>
}
public protocol DefaultValueProtocol {
    static func defaultValueFor(_ property: String) -> AnyObject?
}
///属性对应。用于json转为对象的时候
public protocol ReplacePropertyProtocol {
    static func replacePropertys() -> [String: String]
}
///支持对象保存到数据库，转为字典
public protocol Model: Serialization {
    
    ///The database table in which entities are stored.
    static var tableName: String { get }
    /**
     This method will be called when the entity is saved.
     The keys of the dictionary are the column names
     in the database.
     */
    var serialize: [String: Binding?] { get }
}
extension Model {
    public static var tableName: String {
        return String(describing: self)
    }
    
    public var serialize: [String: Binding?] {
        var data: [String: Binding?] = [:]
        PropertyData.validPropertyDataForObject(self).forEach { propertyData in
            var propertyData = propertyData
            data[propertyData.name!] = propertyData.bindingValue
        }
        return data
    }
    
    public var dictionary: [String: AnyObject] {
        var data: [String: AnyObject] = [:]
        PropertyData.validPropertyDataForObject(self).forEach { propertyData -> () in
            let value = propertyData.value
            if !(value is NSNull || "\(value)" == "nil"){
                if let serialization = value as? Serialization {
                    data[propertyData.name!] = serialization.serialization
                }else if let anyObject = value as? AnyObject {
                    data[propertyData.name!] = anyObject
                }
            }
        }
        return data
    }
    
    public static func saveValuesToDefaults(_ objectArray: [Self], forKey defaultName: String = Self.tableName) {
        UserDefaults.standard.setValue(objectArray.map{$0.dictionary}, forKey: defaultName)
    }
    public var serialization: AnyObject {
        return self.dictionary as AnyObject
    }
}
///从数据库的表取出对象。从字典转为对象
public protocol Storable {
    /** Used to initialize an object to get information about its properties */
    init()
    func setValue(_ value: Any?, forKey key: String)
}
extension Storable {
    internal func setValuesForKeysWithDictionary(_ keyedValues: [String : AnyObject]) {
        keyedValues.forEach { (key, value) -> () in
            self.setValue(value, forKey: key)
        }
    }
    
    internal init(serialized: [String: Binding?]) {
        self.init()
        let propertyDatas = PropertyData.validPropertyDataForObject(self)
        for propertyData in propertyDatas {
            if let name = propertyData.name, let type = propertyData.bindingType, let optionalValue = serialized[name], let binding = optionalValue {
                setValue(type.toAnyObject(binding), forKey: name)
            }
        }
    }
    public init(from dic: [String: AnyObject]) {
        self.init()
        var replaceMap: [String: String]?
        if let replacePropertys  = self as? ReplacePropertyProtocol.Type {
            replaceMap = replacePropertys.replacePropertys()
        }
        PropertyData.validPropertyDataForObject(self).forEach{ (propertyData) -> () in
            if let name = propertyData.name, var value = dic[name] {
                if !(value is NSNull || "\(value)" == "nil"){
                    if let deserialization = value as? Deserialization {
                        value = deserialization.deserialization(propertyData.type)
                    }
                    setValue(value, forKey: (replaceMap?[name] ?? name))
                    
                }
            }
        }
    }
    public static func loadValues(from array: [[String: AnyObject]]) -> [Self] {
        return array.map {
            self.init(from: $0)
        }
    }
    private static var defaultName: String {
        return String(describing: self)
    }
    public static func loadValuesFromDefaults(forKey defaultName: String = Self.defaultName) -> [Self]? {
        if let objectArray = UserDefaults.standard.array(forKey: defaultName) {
            return objectArray.map {
                self.init(from: $0 as! [String : AnyObject])
            }
        }else{
            return nil
        }
    }
}
extension NSCoding where Self: Model,Self: Storable {
    public func encodeWithCoder(_ aCoder: NSCoder) {
        for (key,value) in self.dictionary{
            aCoder.encode(value, forKey: key)
        }
    }
    public init?(coder aDecoder: NSCoder) {
        self.init()
        PropertyData.validPropertyDataForObject(self).forEach{ (propertyData) -> () in
            if let name = propertyData.name, var value = aDecoder.decodeObject(forKey: name) {
                if !(value is NSNull || "\(value)" == "nil"){
                    if let deserialization = value as? Deserialization {
                        value = deserialization.deserialization(propertyData.type)
                    }
                    setValue(value as AnyObject?, forKey: name)
                    
                }
            }
        }
    }
}

