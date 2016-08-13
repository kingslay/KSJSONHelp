final public class MemoryDriver {

    typealias Collection = [String: Document]

    typealias Document = [String: Binding?]

    typealias Store = [String: Collection]
    var store: Store
    public init() {
        self.store = Store()
    }
    
}
extension MemoryDriver: Driver {

	public func fetchOne(table table: String, filter: Filter?) -> [String: Binding?]? {
		print("fetch one \(filter?.statement) filter on \(table)")
        var id: String?
        if let filter = filter as? CompareFilter {
            if filter.key == "identifier" {
                id = filter.value as? String
            }
        }
        if let id = id {
            if let data = self.store[table]?[id] {
                return data
            }
        }
        return nil
	}

	public func fetch(table table: String, filter: Filter?) -> [[String: Binding?]]? {
		print("fetch \(filter?.statement) filter on \(table)")
        if let collection = self.store[table] {
            var models = [Document]()
            for (_,value) in collection {
                models.append(value)
            }
            return models
        }
		return nil
	}

	public func delete(table table: String, filter: Filter?) {
		print("delete \(filter?.statement) filter on \(table)")
        var id: String?
        if let filter = filter as? CompareFilter {
            if filter.key == "identifier" {
                id = filter.value as? String
            }
        }
        if let id = id {
            store[table]?[id] = nil
        }
	}

	public func update(table table: String, filter: Filter?, data: [String: Binding?]) {
		print("update \(filter?.statement) filter \(data.count) data points on \(table)")

	}

	public func insert(table table: String, items: [[String: Binding?]]) {
        var collectionData: Collection
        if let col = store[table] {
            collectionData = col
        } else {
            collectionData = Collection()
        }

        for item in items {
            let identifier = item["identifier"] as! String
            collectionData[identifier] = item
        }
        store[table] = collectionData
	}

	public func upsert(table table: String, items: [[String: Binding?]]) {
        var collectionData: Collection
        if let col = store[table] {
            collectionData = col
        } else {
            collectionData = Collection()
        }

        for item in items {
            let identifier = item["identifier"] as! String
            collectionData[identifier] = item
        }
        store[table] = collectionData
	}
 
	public func exists(table table: String, filter: Filter?) -> Bool {
		print("exists \(filter?.statement) filter on \(table)")
        var id: String?
        if let filter = filter as? CompareFilter {
            if filter.key == "identifier" {
                id = filter.value as? String
            }
        }
        if let id = id {
            if let data = self.store[table]?[id] {
                return true
            }
        }
        return false
	}

	public func count(table table: String, filter: Filter?) -> Int {
		print("count \(filter?.statement) filter on \(table)")
        if let collection = self.store[table] {
           return collection.count
        }
        return 0
    }
    public func createTableWith(model: Model){

    }
    public func execute(SQL: String) {
        
    }
}