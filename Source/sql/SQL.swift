public class SQL {
    
    public var table: String
    public var operation: Operation
    
    public var filters: [Filter]?
    public var limit: Int?
    public var data: [String: Binding?]?
    
    public enum Operation: String {
        case SELECT = "SELECT * FROM"
        case DELETE = "DELETE FROM"
        case INSERT = "INSERT OR ABORT INTO"
        case UPDATE = "UPDATE"
        case CREATE = "CREATE TABLE"
        case UPSERT = "INSERT OR REPLACE INTO"
        case COUNT = "SELECT count(*) FROM"

    }
    
    public init(operation: Operation, table: String) {
        self.operation = operation
        self.table = table
    }
    
    public var query: String {
        var query: [String] = []
        query.append(self.operation.rawValue)
        query.append("\(self.table)")
        if let data = self.data {
            if self.operation == .INSERT || self.operation == .UPSERT {
                let columns = data.keys
                let namedParameters = columns.map {":" + $0}
                query.append("(\(columns.joinWithSeparator(", "))) VALUES (\(namedParameters.joinWithSeparator(", ")))")
            } else if self.operation == .UPDATE {
                var updates: [String] = []
                
                for (key, value) in data {
                    updates.append("\(key) = \(value)")
                }
                query.append("SET \(updates.joinWithSeparator(", "))")
            }
        }
        if let filters = self.filters {
            if filters.count > 0 {
                query.append("WHERE")
            }
            
            for (index, filter) in filters.enumerate() {
                query.append((index > 0) ? " AND \(filter.statement)" : filter.statement)
            }
        }
        
        if let limit = self.limit {
            query.append("LIMIT \(limit)")
        }
        
        let queryString = query.joinWithSeparator(" ")
        
        self.log(queryString)
        
        return queryString + ";"
    }
    
    func log(message: Any) {
        print("[SQL] \(message)")
    }
}