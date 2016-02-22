public protocol Filter {
    var statement: String { get }
}
public class CompareFilter: Filter {
    public enum Comparison: String {
        case Equal =            "="
        case Less =             "<"
        case Greater =          ">"
        case NotEqual =         "!="
        case Like =             "LIKE"
        case NotLike =          "NOT LIKE"
        case LessOrEqual =      "<="
        case GreaterOrEqual =   ">="
    }
    
    public let key: String
    public let value: Binding
    public let comparison: Comparison
    
    init(key: String, value: Binding, comparison: Comparison) {
        self.key = key
        self.value = value
        self.comparison = comparison
    }
    public var statement: String {
        return "\(self.key) \(self.comparison.rawValue) \(value)";
    }
}

public class SubsetFilter: Filter {
    public enum Comparison: String {
        case In =               "IN"
        case NotIn =            "NOT IN"
    }
    
    public let key: String
    public let superSet: [Binding]
    public let comparison: Comparison
    
    init(key: String, superSet: [Binding], comparison: Comparison) {
        self.key = key
        self.superSet = superSet
        self.comparison = comparison
    }
    public var statement: String {
        let placeholderString = (0..<self.superSet.count).map {"\($0)"}
            .joinWithSeparator(", ")
        return "\(self.key) \(self.comparison.rawValue) (\(placeholderString))"
    }
}
public class CompositeFilter: Filter,DictionaryLiteralConvertible {
    public typealias Key = String
    public typealias Value = Binding
    private var composites: [Filter] = []
    
    public required init(dictionaryLiteral elements: (Key, Value)...) {
        elements.forEach { (propertyName, value) in
            composites.append(CompareFilter(key: propertyName, value: value,comparison: .Equal))
        }
    }
    public class func fromDictionary(dic: [String:Binding]) -> CompositeFilter {
        let filter = CompositeFilter()
        dic.forEach { (propertyName, value) in
            filter.equal(propertyName, value: value)
        }
        return filter
    }
    public var statement: String {
        if self.composites.count == 0 {
            return "1==1"
        }else{
            return self.composites.map {$0.statement}.joinWithSeparator(" AND ")
        }
    }
    public func addFilter(filter: Filter) -> CompositeFilter {
        composites.append(filter)
        return self
    }
    
    public func equal(propertyName: String, value: Binding) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: value, comparison: .Equal))
        return self
    }
    
    /** Evaluated as true if the value of the property is less than the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    public func less(propertyName: String, value: Binding) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: value, comparison: .Less))
        return self
    }
    
    /** Evaluated as true if the value of the property is less or equal to the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    public func lessOrEqual(propertyName: String, value: Binding) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName,value: value, comparison: .LessOrEqual))
        return self
    }
    
    /** Evaluated as true if the value of the property is less than the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    public func greater(propertyName: String, value: Binding) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: value, comparison: .Greater))
        return self
    }
    
    /** Evaluated as true if the value of the property is greater or equal to the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    public func greaterOrEqual(propertyName: String, value: Binding) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: value, comparison: .GreaterOrEqual))
        return self
    }
    
    /** Evaluated as true if the value of the property is not equal to the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    public func notEqual(propertyName: String, value: Binding) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: value, comparison: .NotEqual))
        return self
    }
    
    /** Evaluated as true if the value of the property is contained in the array
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         array that should contain the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    public func contains(propertyName: String, array: [Binding]) -> CompositeFilter {
        composites.append(SubsetFilter(key: propertyName, superSet: array, comparison: .In))
        return self
    }
    
    /** Evaluated as true if the value of the property is not contained in the array
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         array that should not contain the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    public func notContains(propertyName: String, array: [Binding]) -> CompositeFilter {
        composites.append(SubsetFilter(key: propertyName, superSet: array, comparison:  .NotIn))
        return self
    }
    
    /**
     Evaluated as true if the value of the property matches the pattern.
     
     **%** matches any string
     
     **_** matches a single character
     
     'Dog' LIKE 'D_g'    = true
     
     'Dog' LIKE 'D%'     = true
     
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         array that should contain the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    public func like(propertyName: String, pattern: String) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: pattern, comparison: .Like))
        return self
    }
    
    /**
     Evaluated as true if the value of the property matches the pattern.
     
     **%** matches any string
     
     **_** matches a single character
     
     'Dog' NOT LIKE 'D_g'    = false
     
     'Dog' NOT LIKE 'D%'     = false
     
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         array that should contain the property value
     
     - returns:                 `Filter` intance
     */
    public func notLike(propertyName: String, pattern: String) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: pattern, comparison: .NotLike))
        return self
    }
}

extension Filter {
    
    public static func addFilter(filter: Filter) -> CompositeFilter {
        return CompositeFilter().addFilter(filter)
    }
    
    // MARK: - Convenience filter initializers
    
    /** Evaluated as true if the value of the property is equal to the provided value
    
    - parameter propertyName:   name of the property to be evaluated
    - parameter array:          value that will be compared to the property value
    
    - returns:                  `Filter` intance
    */
    
    public static func equal(propertyName: String, value: Binding) -> CompositeFilter {
        return CompositeFilter().equal(propertyName, value: value)
    }
    
    /** Evaluated as true if the value of the property is less than the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `Filter` intance
     */
    public static func less(propertyName: String, value: Binding) -> CompositeFilter {
        return CompositeFilter().less(propertyName, value: value)
    }
    
    /** Evaluated as true if the value of the property is less or equal to the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `Filter` intance
     */
    public static func lessOrEqual(propertyName: String, value: Binding) -> CompositeFilter {
        return CompositeFilter().lessOrEqual(propertyName, value: value)
    }
    
    /**
     Evaluated as true if the value of the property is greater than the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `Filter` intance
     */
    public static func greater(propertyName: String, value: Binding) -> CompositeFilter {
        return CompositeFilter().greater(propertyName, value: value)
    }
    
    /**
     Evaluated as true if the value of the property is greater or equal to the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `Filter` intance
     */
    public static func greaterOrEqual(propertyName: String, value: Binding) -> CompositeFilter {
        return CompositeFilter().greaterOrEqual(propertyName, value: value)
    }
    
    /**
     Evaluated as true if the value of the property is not equal to the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `Filter` intance
     */
    public static func notEqual(propertyName: String, value: Binding) -> CompositeFilter {
        return CompositeFilter().notEqual(propertyName, value: value)
    }
    
    /**
     Evaluated as true if the value of the property is contained in the array
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         array that should contain the property value
     
     - returns:                 `Filter` intance
     */
    public static func contains(propertyName: String, array: [Binding]) -> CompositeFilter {
        return CompositeFilter().contains(propertyName, array: array)
    }
    
    /**
     Evaluated as true if the value of the property is not contained in the array
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         array that should not contain the property value
     
     - returns:                 `Filter` intance
     */
    public static func notContains(propertyName: String, array: [Binding]) -> CompositeFilter {
        return CompositeFilter().notContains(propertyName, array: array)
    }
    
    /**
     Evaluated as true if the value of the property matches the pattern.
     
     **%** matches any string
     
     **_** matches a single character
     
     'Dog' LIKE 'D_g'    = true
     
     'Dog' LIKE 'D%'     = true
     
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         array that should contain the property value
     
     - returns:                 `Filter` intance
     */
    public static func like(propertyName: String, pattern: String) -> CompositeFilter {
        return CompositeFilter().like(propertyName, pattern: pattern)
    }
    
    /**
     Evaluated as true if the value of the property matches the pattern.
     
     **%** matches any string
     
     **_** matches a single character
     
     'Dog' NOT LIKE 'D_g'    = false
     
     'Dog' NOT LIKE 'D%'     = false
     
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         array that should contain the property value
     
     - returns:                 `Filter` intance
     */
    public static func notLike(propertyName: String, pattern: String) -> CompositeFilter {
        return CompositeFilter().notLike(propertyName, pattern: pattern)
    }
}

