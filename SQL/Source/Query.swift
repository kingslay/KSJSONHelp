open class Query<T: Model> {
    open let table: String = T.tableName

	open var filter: Filter?
    public init() {

    }
	open func update(_ data: [String: Binding?]) {
		Database.driver.update(table: self.table, filter: self.filter, data: data)
	}

	open func insert(_ data: [String: Binding?]) {
		Database.driver.insert(table: self.table, items: [data])
	}

	open func upsert(_ data: [[String: Binding?]]) {
		Database.driver.upsert(table: self.table, items: data)
	}

	open func upsert(_ data: [String: Binding?]) {
		Database.driver.upsert(table: self.table, items: [data])
	}

	open func insert(_ data: [[String: Binding?]]) {
		Database.driver.insert(table: self.table, items: data)
	}

	open func delete() {
		Database.driver.delete(table: self.table, filter: self.filter)
	}

	open var exists: Bool{
		return Database.driver.exists(table: self.table, filter: self.filter)
	}

	open var count: Int {
		return Database.driver.count(table: self.table, filter: self.filter)
	}
    open func fetchOne(_ filter: Filter?) -> T? {
        if let S = T.self as? Storable.Type , let serialized = Database.driver.fetchOne(table: self.table, filter: filter) {
            return S.init(serialized: serialized) as? T
        } else {
            return nil
        }
    }
    
    open func fetch(_ filter: Filter?) -> [T]? {
        if let S = T.self as? Storable.Type, let serializeds = Database.driver.fetch(table: self.table, filter: filter) {
            return serializeds.map({ (serialized) -> T in
                S.init(serialized: serialized) as! T
            })
        } else {
            return nil
        }
    }

	///Inserts or updates the entity in the database.
	open func save(_ model: T) {
        Database.driver.createTableWith(model: model)
        self.upsert(model.serialize)
	}

	///Deletes the entity from the database.
	open func delete(_ model: T) {
        if let primaryKeysType = T.self as? PrimaryKeyProtocol.Type {
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
}
extension Model {
    public func save() {
        Query().save(self)
    }
    
    public func delete() {
        Query().delete(self)
    }
    public static func delete(dic: [String:Binding]) {
        delete(CompositeFilter.fromDictionary(dic))
    }
    public static func delete(_ filter: Filter) {
        Database.driver.delete(table: self.tableName, filter: filter)
    }
}
extension Storable where Self: Model {
//    public typealias ValueType = Self
    public static func fetchOne(dic: [String:Binding]) -> Self? {
        return fetchOne(CompositeFilter.fromDictionary(dic))
    }
    public static func fetch(dic: [String:Binding]) -> [Self]? {
        return fetch(CompositeFilter.fromDictionary(dic))
    }
    public static func fetchOne(_ filter: Filter?) -> Self? {
        return Query().fetchOne(filter)
    }
    
    public static func fetch(_ filter: Filter?) -> [Self]? {
        return Query().fetch(filter)
    }
}
