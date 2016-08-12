
public class SQLiteDriver: Driver {
    private let database = try! Connection("db.sqlite3")
    private var existingTables: Set<String> = []
    public init() {

    }
    public func fetchOne(table table: String, filter: Filter?) -> [String: Binding?]? {
        let sql = SQL(operation: .SELECT, table: table)
        sql.filter = filter
        sql.limit = 1
        return execute(sql)?.first
    }

    public func fetch(table table: String, filter: Filter?) -> [[String: Binding?]]? {
        let sql = SQL(operation: .SELECT, table: table)
        sql.filter = filter
        if let statement = execute(sql) {
            return Array(statement)
        }else{
            return nil
        }
    }

    public func delete(table table: String, filter: Filter?) {
        let sql = SQL(operation: .DELETE, table: table)
        sql.filter = filter
        execute(sql)?.run()
    }

    public func update(table table: String, filter: Filter?, data: [String: Binding?]) {
        let sql = SQL(operation: .UPDATE, table: table)
        sql.filter = filter
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

    public func exists(table table: String, filter: Filter?) -> Bool {
        print("exists \(filter?.statement) filter on \(table)")

        return false
    }

    public func count(table table: String, filter: Filter?) -> Int {
        let sql = SQL(operation: .COUNT, table: table)
        sql.filter = filter
        sql.limit = 1
        if let value = execute(sql)?.scalar() {
            return wrapValue(value)
        }else{
            return 0
        }
    }
    public func createTableWith(model: Model) {
        let tableName = model.dynamicType.tableName
        if existingTables.contains(tableName) {
            return
        }
        let propertyDatas = PropertyData.validPropertyDataForObject(model)
        let columnDefinition : (PropertyData) -> (String) = { property in
            var columnDefinition = "\(property.name!) \(property.bindingType!.declaredDatatype)"
            if !property.isOptional {
                columnDefinition += " NOT NULL"
            }
            if let defaultValueProtocol = model.dynamicType as? DefaultValueProtocol.Type,let defaultValue = defaultValueProtocol.defaultValueFor(property.name!) {
                columnDefinition += " DEFAULT \(defaultValue))"
            }
            return columnDefinition
        }
        let select = "select * from \(tableName) limit 0"
        do{
            let statement = try self.database.prepare(select)
            let columnNames = statement.columnNames
            propertyDatas.forEach{ property in
                if !columnNames.contains(property.name!) {
                    let alertSQL = "alter table \(tableName) add column \(columnDefinition(property))"
                    execute(alertSQL)
                }
            }
        } catch {
            var statement = "CREATE TABLE \(tableName) ("
            var columnDefinitions: [String] = []
            for propertyData in propertyDatas {
                columnDefinitions.append(columnDefinition(propertyData))
            }
            statement += columnDefinitions.joinWithSeparator(", ")
            if let primaryKeysType = model.dynamicType as? PrimaryKeyProtocol.Type {
                statement += ", PRIMARY KEY (\(primaryKeysType.primaryKeys().joinWithSeparator(", ")))"
            }
            statement += ")"
            execute(statement)
        }
        existingTables.insert(tableName)
    }

    public func execute(SQL: String) {
        do{
            try self.database.execute(SQL)
        }catch{

        }
    }

    private func execute(sql: SQL) -> Statement? {
        do{
            return try self.database.prepare(sql.query, sql.data)
        }catch{
            return nil
        }
    }
}