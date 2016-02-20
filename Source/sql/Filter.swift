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
        return "\(self.key) \(self.comparison.rawValue) :\(value)";
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
        let placeholderString = (0..<self.superSet.count).map {":\(self.key)\($0)"}
            .joinWithSeparator(", ")
        return "\(self.key) \(self.comparison.rawValue) (\(placeholderString))"
    }
}
