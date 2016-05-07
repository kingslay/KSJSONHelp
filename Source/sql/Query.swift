public class Query<T: Model> {
    public let table: String

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
    public func fetchOne(filter: Filter?) -> T? {
        if let S = T.self as? Storable.Type , let serialized = Database.driver.fetchOne(table: self.table, filter: filter) {
            return S.init(serialized: serialized) as? T
        } else {
            return nil
        }
    }
    
    public func fetch(filter: Filter?) -> [T]? {
        if let S = T.self as? Storable.Type, let serializeds = Database.driver.fetch(table: self.table, filter: filter) {
            return serializeds.map({ (serialized) -> T in
                S.init(serialized: serialized) as! T
            })
        } else {
            return nil
        }
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
            propertyData.forEach{ propertyData in
                var propertyData = propertyData
                data[propertyData.name!] = propertyData.bindingValue
            }
        }
		self.upsert(data)
		
	}

	///Deletes the entity from the database.
	func delete(model: T) {
        if let primaryKeysType = T.self as? PrimaryKeys.Type {
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
		self.table = T.tableName
	}
    
    internal func createTableStatementByPropertyData(propertyDatas: [PropertyData]) -> String {
        var statement = "CREATE TABLE \(self.table) ("
        var columnDefinitions: [String] = []
        for propertyData in propertyDatas {
            var columnDefinition = "\(propertyData.name!) \(propertyData.bindingType!.declaredDatatype)"
            if !propertyData.isOptional {
                columnDefinition += " NOT NULL"
            }
            columnDefinitions.append(columnDefinition)
        }
        statement += columnDefinitions.joinWithSeparator(", ")
        if let primaryKeysType = T.self as? PrimaryKeys.Type {
            statement += ", PRIMARY KEY (\(primaryKeysType.primaryKeys().joinWithSeparator(", ")))"
        }
        statement += ")"
        return statement
    }

}
extension Model {
    public func save() {
        Query().save(self)
    }
    
    public func delete() {
        Query().delete(self)
    }
    public static func delete(dic dic: [String:Binding]) {
        delete(CompositeFilter.fromDictionary(dic))
    }
    public static func delete(filter: Filter) {
        Database.driver.delete(table: self.tableName, filter: filter)
    }
}
extension Storable where Self: Model {
//    public typealias ValueType = Self
    public static func fetchOne(dic dic: [String:Binding]) -> Self? {
        return Query().fetchOne(CompositeFilter.fromDictionary(dic))
    }
    public static func fetch(dic dic: [String:Binding]) -> [Self]? {
        return Query().fetch(CompositeFilter.fromDictionary(dic))
    }
    public static func fetchOne(filter: Filter?) -> Self? {
        return Query().fetchOne(filter)
    }
    
    public static func fetch(filter: Filter?) -> [Self]? {
        return Query().fetch(filter)
    }
}