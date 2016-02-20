public class Query<T: Model> {

	public var filters: [Filter] = []

	//ends
	//var first: Model?
	public var first: T? {
		if let serialized = Database.driver.fetchOne(table: self.table, filters: self.filters) {
			return T(serialized: serialized)
		} else {
			return nil
		}
	}

	//var results: [Model]
	public var results: [T] {
		var models: [T] = []

        if let serializeds = Database.driver.fetch(table: self.table, filters: self.filters) {
            for serialized in serializeds {
                let model = T(serialized: serialized)
                models.append(model)
            }
        }
		return models
	}

	public func update(data: [String: Binding?]) {
		Database.driver.update(table: self.table, filters: self.filters, data: data)
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
		Database.driver.delete(table: self.table, filters: self.filters)
	}

	public var exists: Bool{
		return Database.driver.exists(table: self.table, filters: self.filters)
	}

	public var count: Int {
		return Database.driver.count(table: self.table, filters: self.filters)
	}

	//model
	public func find(id: Int) -> T? {
		return self.filter("id", "\(id)").first
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
            for propertyData in propertyData{
                data[propertyData.name!] = propertyData.value
            }
        }
		if let id = model.id {
			self.filter("id", id).update(data)
		} else {
			self.insert(data)
		}
	}

	///Deletes the entity from the database.
	func delete(model: T) {
		guard let id = model.id else {
			return
		}

		self.filter("id", id).delete()
	}

	//continues
	public func filter(key: String, _ value: Binding) -> Query {
		let filter = CompareFilter(key: key, value: value, comparison: .Equal)
		self.filters.append(filter)
		return self
	}

	public func filter(key: String, _ comparison: CompareFilter.Comparison, _ value: Binding) -> Query {
		let filter = CompareFilter(key: key, value: value, comparison: comparison)
		self.filters.append(filter)
		return self
	}

	public func filter(key: String, contains superSet: [Binding]) -> Query {
		let filter = SubsetFilter(key: key, superSet: superSet, comparison: .In)
		self.filters.append(filter)
		return self
	}

	public func filter(key: String, notContains superSet: [Binding]) -> Query {
		let filter = SubsetFilter(key: key, superSet: superSet, comparison: .NotIn)
		self.filters.append(filter)
		return self
	}

	public init() {
		self.table = T.table
	}
    internal func createTableStatementByPropertyData(propertyDatas: [PropertyData]) -> String {
        var statement = "CREATE TABLE \(self.table) ("
        
        for propertyData in propertyDatas {
            statement += "\(propertyData.name!) \(propertyData.type!.declaredDatatype))"
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