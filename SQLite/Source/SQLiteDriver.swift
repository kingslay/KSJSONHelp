
open class SQLiteDriver: Driver {
    fileprivate let database = try! Connection("db.sqlite3")
    fileprivate var existingTables: Set<String> = []
    public init() {

    }
    open func fetchOne(table: String, filter: Filter?) -> [String: Binding?]? {
        let sql = SQL(operation: .SELECT, table: table)
        sql.filter = filter
        sql.limit = 1
        return execute(SQL:sql)?.first
    }

    open func fetch(table: String, filter: Filter?) -> [[String: Binding?]]? {
        let sql = SQL(operation: .SELECT, table: table)
        sql.filter = filter
        if let statement = execute(SQL:sql) {
            return Array(statement)
        }else{
            return nil
        }
    }

    open func delete(table: String, filter: Filter?) {
        let sql = SQL(operation: .DELETE, table: table)
        sql.filter = filter
        execute(SQL:sql)?.run()
    }

    open func update(table: String, filter: Filter?, data: [String: Binding?]) {
        let sql = SQL(operation: .UPDATE, table: table)
        sql.filter = filter
        sql.data = data
        execute(SQL:sql)?.run()
    }

    open func insert(table: String, items: [[String: Binding?]]) {
        for item in items {
            let sql = SQL(operation: .INSERT, table: table)
            sql.data = item
            execute(SQL:sql)?.run()
        }
    }

    open func upsert(table: String, items: [[String: Binding?]]) {
        for item in items {
            let sql = SQL(operation: .UPSERT, table: table)
            sql.data = item
            execute(SQL:sql)?.run()
        }
    }

    open func exists(table: String, filter: Filter?) -> Bool {
        print("exists \(filter?.statement) filter on \(table)")

        return false
    }

    open func count(table: String, filter: Filter?) -> Int {
        let sql = SQL(operation: .COUNT, table: table)
        sql.filter = filter
        sql.limit = 1
        if let value = execute(SQL:sql)?.scalar() {
            return wrapValue(value)
        }else{
            return 0
        }
    }
    open func createTableWith(model: Model) {
        let tableName = type(of: model).tableName
        if existingTables.contains(tableName) {
            return
        }
        let propertyDatas = PropertyData.validPropertyDataForObject(model)
        let columnDefinition : (PropertyData) -> (String) = { property in
            var columnDefinition = "\(property.name!) \(property.bindingType!.declaredDatatype)"
            if !property.isOptional {
                columnDefinition += " NOT NULL"
            }
            if let defaultValueProtocol = type(of: model) as? DefaultValueProtocol.Type,let defaultValue = defaultValueProtocol.defaultValueFor(property.name!) {
                columnDefinition += " DEFAULT \(defaultValue))"
            }
            return columnDefinition
        }
        let select = "select * from \(tableName) limit 0"
        do{
            let statement = try self.database.prepare(statement:select)
            let columnNames = statement.columnNames
            propertyDatas.forEach{ property in
                if !columnNames.contains(property.name!) {
                    let alertSQL = "alter table \(tableName) add column \(columnDefinition(property))"
                    execute(sql:alertSQL)
                }
            }
        } catch {
            var statement = "CREATE TABLE \(tableName) ("
            var columnDefinitions: [String] = []
            for propertyData in propertyDatas {
                columnDefinitions.append(columnDefinition(propertyData))
            }
            statement += columnDefinitions.joined(separator: ", ")
            if let primaryKeysType = type(of: model) as? PrimaryKeyProtocol.Type {
                statement += ", PRIMARY KEY (\(primaryKeysType.primaryKeys().joined(separator: ", ")))"
            }
            statement += ")"
            execute(sql:statement)
        }
        existingTables.insert(tableName)
    }

    open func execute(sql: String) {
        do{
            try self.database.execute(sql:sql)
        }catch{

        }
    }

    fileprivate func execute(SQL: SQL) -> Statement? {
        do{
            return try self.database.prepare(statement: SQL.query, SQL.data)
        }catch{
            return nil
        }
    }
}
