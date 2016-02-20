
public class SQLiteDriver: Driver {
    
    private let database = try! Connection("db.sqlite3")
    private var existingTables: Set<String> = []

    public func fetchOne(table table: String, filters: [Filter]) -> [String: Binding?]? {
        let sql = SQL(operation: .SELECT, table: table)
        sql.filters = filters
        sql.limit = 1
        return execute(sql)?.first
    }
    
    public func fetch(table table: String, filters: [Filter]) -> [[String: Binding?]]? {
        let sql = SQL(operation: .SELECT, table: table)
        sql.filters = filters
        if let statement = execute(sql) {
            return Array(statement)
        }else{
            return nil
        }
    }
    
    public func delete(table table: String, filters: [Filter]) {
        let sql = SQL(operation: .DELETE, table: table)
        sql.filters = filters
        execute(sql)
    }
    
    public func update(table table: String, filters: [Filter], data: [String: Binding?]) {
        let sql = SQL(operation: .UPDATE, table: table)
        sql.filters = filters
        sql.data = data
        execute(sql)?.run()
    }
    
    public func insert(table table: String, items: [[String: Binding?]]) {
        for item in items {
            let sql = SQL(operation: .INSERT, table: table)
            sql.data = item
            execute(sql)?.run()
        }
    }
    
    public func upsert(table table: String, items: [[String: Binding?]]) {
        for item in items {
            let sql = SQL(operation: .UPSERT, table: table)
            sql.data = item
            execute(sql)?.run()
        }
    }
    
    public func exists(table table: String, filters: [Filter]) -> Bool {
        print("exists \(filters.count) filters on \(table)")
        
        return false
    }
    
    public func count(table table: String, filters: [Filter]) -> Int {
        let sql = SQL(operation: .COUNT, table: table)
        sql.filters = filters
        sql.limit = 1
        if let value = execute(sql)?.scalar() {
            return wrapValue(value)
        }else{
            return 0
        }
    }
    public func containsTable(table table: String) -> Bool {
        if existingTables.contains(table){
            return true
        }else{
            do{
                if try self.database.containsTable(table) {
                    existingTables.insert(table)
                    return true
                }else{
                    return false
                }
            }catch{
                return false
            }
        }
    }
    public func createTable(table table: String, sql: String) {
        do{
            if !existingTables.contains(table){
                try self.database.execute(sql)
                existingTables.insert(table)
            }
        }catch{
            
        }
    }
    public func execute(SQL: String) {
        do{
            try self.database.execute(SQL)
        }catch{
            
        }
    }

    
    public init() {
        
    }
    
    private func execute(sql: SQL) -> Statement? {
        do{
            return try self.database.prepare(sql.query, sql.data)
        }catch{
            return nil
        }
    }
}