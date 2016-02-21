public class Query<T: Model> {

	public var filter: Filter?

	public func update(data: [String: Binding?]) {
		Database.driver.update(table: self.table, filter: self.filter, data: data)
	}

	public func insert(data: [String: Binding?]) {
		Database.driver.insert(table: self.table, items: [data])
	}

	public func upsert(data: [[String: Binding?]]) {
		Database.driver.upsert(table: self.table, items: data)
	}

	public func upsert(data: [String: Binding?]) {
		Database.driver.upsert(table: self.table, items: [data])
	}

	public func insert(data: [[String: Binding?]]) {
		Database.driver.insert(table: self.table, items: data)
	}

	public func delete() {
		Database.driver.delete(table: self.table, filter: self.filter)
	}

	public var exists: Bool{
		return Database.driver.exists(table: self.table, filter: self.filter)
	}

	public var count: Int {
		return Database.driver.count(table: self.table, filter: self.filter)
	}
    
    func fetchOne(filter: Filter?) -> [String: Binding?]? {
        return Database.driver.fetchOne(table: self.table, filter: self.filter)

    }
    func fetch(filter: Filter?) -> [[String: Binding?]]? {
        return Database.driver.fetch(table: self.table, filter: self.filter)
    }

	/* Internal Casts */
	///Inserts or updates the entity in the database.
	func save(model: T) {
        var data: [String: Binding?] = [:]
        if Database.driver.containsTable(table: self.table){
            data = model.serialize
        }else{
            let propertyData = PropertyData.validPropertyDataForObject(model)
            Database.driver.createTable(table: self.table, sql: createTableStatementByPropertyData(propertyData))
            propertyData.forEach({ (var propertyData) -> () in
                data[propertyData.name!] = propertyData.bindingValue
            })
        }
		self.upsert(data)
		
	}

	///Deletes the entity from the database.
	func delete(model: T) {
        if T.self is PrimaryKeys.Type {
            let primaryKeysType = T.self as! PrimaryKeys.Type
            let data = model.serialize
            let filter = CompositeFilter()
            for primaryKey in primaryKeysType.primaryKeys() {
                if let optionalValue = data[primaryKey],let value = optionalValue  {
                    filter.equal(primaryKey, value: value)
                }
            }
            self.filter = filter
            self.delete()
        }else{
            return
        }
	}
	public init() {
		self.table = T.table
	}
    
    internal func createTableStatementByPropertyData(propertyDatas: [PropertyData]) -> String {
        var statement = "CREATE TABLE \(self.table) ("
        
        for propertyData in propertyDatas {
            statement += "\(propertyData.name!) \(propertyData.bindingType!.declaredDatatype)"
            statement += propertyData.isOptional ? "" : " NOT NULL"
            statement += ", "
        }
        
        if T.self is PrimaryKeys.Type {
            let primaryKeysType = T.self as! PrimaryKeys.Type
            statement += "PRIMARY KEY (\(primaryKeysType.primaryKeys().joinWithSeparator(", ")))"
        }
        statement += ")"
        return statement
    }


	public let table: String
}