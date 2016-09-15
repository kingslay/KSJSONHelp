public protocol Filter {
    var statement: String { get }
}
func transcode(_ literal: Binding) -> String {
    
    switch literal {
    case let blob as Blob:
        return blob.description
    case let string as String:
        return string.quote("'")
    case let binding:
        return "\(binding)"
    }
}
open class CompareFilter: Filter {
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
    
    open let key: String
    open let value: Binding
    open let comparison: Comparison
    
    public init(key: String, value: Binding, comparison: Comparison) {
        self.key = key
        self.value = value
        self.comparison = comparison
    }
    open var statement: String {
        return "\(self.key) \(self.comparison.rawValue) \(transcode(value))";
    }
}

open class SubsetFilter: Filter {
    public enum Comparison: String {
        case In =               "IN"
        case NotIn =            "NOT IN"
    }
    
    open let key: String
    open let superSet: [Binding]
    open let comparison: Comparison
    
    public init(key: String, superSet: [Binding], comparison: Comparison) {
        self.key = key
        self.superSet = superSet
        self.comparison = comparison
    }
    open var statement: String {
        let placeholderString = self.superSet.map { transcode($0) }
            .joined(separator: ", ")
        return "\(self.key) \(self.comparison.rawValue) (\(placeholderString))"
    }
}
open class CompositeFilter: Filter,ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = Binding
    fileprivate var composites: [Filter] = []
    
    public required init(dictionaryLiteral elements: (Key, Value)...) {
        elements.forEach { (propertyName, value) in
            composites.append(CompareFilter(key: propertyName, value: value,comparison: .Equal))
        }
    }
    open class func fromDictionary(_ dic: [String:Binding]) -> CompositeFilter {
        let filter = CompositeFilter()
        dic.forEach { (propertyName, value) in
            filter.equal(propertyName, value: value)
        }
        return filter
    }
    open var statement: String {
        if self.composites.count == 0 {
            return "1==1"
        }else{
            return self.composites.map {$0.statement}.joined(separator: " AND ")
        }
    }
    open func addFilter(_ filter: Filter) -> CompositeFilter {
        composites.append(filter)
        return self
    }
    
    open func equal(_ propertyName: String, value: Binding) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: value, comparison: .Equal))
        return self
    }
    
    /** Evaluated as true if the value of the property is less than the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    open func less(_ propertyName: String, value: Binding) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: value, comparison: .Less))
        return self
    }
    
    /** Evaluated as true if the value of the property is less or equal to the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    open func lessOrEqual(_ propertyName: String, value: Binding) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName,value: value, comparison: .LessOrEqual))
        return self
    }
    
    /** Evaluated as true if the value of the property is less than the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    open func greater(_ propertyName: String, value: Binding) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: value, comparison: .Greater))
        return self
    }
    
    /** Evaluated as true if the value of the property is greater or equal to the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    open func greaterOrEqual(_ propertyName: String, value: Binding) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: value, comparison: .GreaterOrEqual))
        return self
    }
    
    /** Evaluated as true if the value of the property is not equal to the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    open func notEqual(_ propertyName: String, value: Binding) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: value, comparison: .NotEqual))
        return self
    }
    
    /** Evaluated as true if the value of the property is contained in the array
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         array that should contain the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    open func contains(_ propertyName: String, array: [Binding]) -> CompositeFilter {
        composites.append(SubsetFilter(key: propertyName, superSet: array, comparison: .In))
        return self
    }
    
    /** Evaluated as true if the value of the property is not contained in the array
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         array that should not contain the property value
     
     - returns:                 `self`, to enable chaining of statements
     */
    open func notContains(_ propertyName: String, array: [Binding]) -> CompositeFilter {
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
    open func like(_ propertyName: String, pattern: String) -> CompositeFilter {
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
    open func notLike(_ propertyName: String, pattern: String) -> CompositeFilter {
        composites.append(CompareFilter(key: propertyName, value: pattern, comparison: .NotLike))
        return self
    }
}

public extension Filter {
    
    public static func addFilter(_ filter: Filter) -> CompositeFilter {
        return CompositeFilter().addFilter(filter)
    }
    
    // MARK: - Convenience filter initializers
    
    /** Evaluated as true if the value of the property is equal to the provided value
    
    - parameter propertyName:   name of the property to be evaluated
    - parameter array:          value that will be compared to the property value
    
    - returns:                  `Filter` intance
    */
    
    public static func equal(_ propertyName: String, value: Binding) -> CompositeFilter {
        return CompositeFilter().equal(propertyName, value: value)
    }
    
    /** Evaluated as true if the value of the property is less than the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `Filter` intance
     */
    public static func less(_ propertyName: String, value: Binding) -> CompositeFilter {
        return CompositeFilter().less(propertyName, value: value)
    }
    
    /** Evaluated as true if the value of the property is less or equal to the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `Filter` intance
     */
    public static func lessOrEqual(_ propertyName: String, value: Binding) -> CompositeFilter {
        return CompositeFilter().lessOrEqual(propertyName, value: value)
    }
    
    /**
     Evaluated as true if the value of the property is greater than the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `Filter` intance
     */
    public static func greater(_ propertyName: String, value: Binding) -> CompositeFilter {
        return CompositeFilter().greater(propertyName, value: value)
    }
    
    /**
     Evaluated as true if the value of the property is greater or equal to the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `Filter` intance
     */
    public static func greaterOrEqual(_ propertyName: String, value: Binding) -> CompositeFilter {
        return CompositeFilter().greaterOrEqual(propertyName, value: value)
    }
    
    /**
     Evaluated as true if the value of the property is not equal to the provided value
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         value that will be compared to the property value
     
     - returns:                 `Filter` intance
     */
    public static func notEqual(_ propertyName: String, value: Binding) -> CompositeFilter {
        return CompositeFilter().notEqual(propertyName, value: value)
    }
    
    /**
     Evaluated as true if the value of the property is contained in the array
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         array that should contain the property value
     
     - returns:                 `Filter` intance
     */
    public static func contains(_ propertyName: String, array: [Binding]) -> CompositeFilter {
        return CompositeFilter().contains(propertyName, array: array)
    }
    
    /**
     Evaluated as true if the value of the property is not contained in the array
     
     - parameter propertyName:  name of the property to be evaluated
     - parameter array:         array that should not contain the property value
     
     - returns:                 `Filter` intance
     */
    public static func notContains(_ propertyName: String, array: [Binding]) -> CompositeFilter {
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
    public static func like(_ propertyName: String, pattern: String) -> CompositeFilter {
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
    public static func notLike(_ propertyName: String, pattern: String) -> CompositeFilter {
        return CompositeFilter().notLike(propertyName, pattern: pattern)
    }
}

