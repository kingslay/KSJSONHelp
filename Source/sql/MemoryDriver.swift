class MemoryDriver: Driver {
	var memory: [
		String: [ //table
			String: //id
				[ //entity
					String: String
				]
		]
	] = [ "users":
			[
				"metadata": [
					"increment": "1"
				],
				"1": [
					"id": "1",
					"first_name": "Tanner",
					"last_name": "Nelson",
					"email": "me@tanner.xyz"
				]
			]
		]


	func fetchOne(table table: String, filter: Filter?) -> [String: Binding?]? {
		print("fetch one \(filter?.statement) filter on \(table)")
		var id: String?

		if let id = id {
			if let data = self.memory[table]?[id] {
				return data
			}
		}

		return nil
	}

	func fetch(table table: String, filter: Filter?) -> [[String: Binding?]]? {
		print("fetch \(filter?.statement) filter on \(table)")

		if let data = self.memory[table] {
			var all: [[String: Binding?]] = []

			for (key, entity) in data {
				if key != "metadata" { //hack
					all.append(entity)
				}
			}

			return all
		}

		return []
	}

	func delete(table table: String, filter: Filter?) {
		print("delete \(filter?.statement) filter on \(table)")

		if filter == nil {
			//truncate
			self.memory[table] = [
				"metadata": [
					"increment": "0"
				]
			]
		} else {
			let id = "1" //hack
			self.memory[table]?.removeValueForKey(id)
		}
	}

	func update(table table: String, filter: Filter?, data: [String: Binding?]) {
		print("update \(filter?.statement) filter \(data.count) data points on \(table)")

		//implement me
	}

	func insert(table table: String, items: [[String: Binding?]]) {
		print("insert \(items.count) items into \(table)")

		//implement me
	}

	func upsert(table table: String, items: [[String: Binding?]]) {
		//check if object exists
		// if does - update
		// if not - insert

		//implement me
	}
 
	func exists(table table: String, filter: Filter?) -> Bool {
		print("exists \(filter?.statement) filter on \(table)")

		if let data = self.memory[table] {
			for (key, _) in data {
				//implement filtering

				if key != "metadata" { //hack
					return true
				}
			}
		}

		return false
	}

	func count(table table: String, filter: Filter?) -> Int {
		print("count \(filter?.statement) filter on \(table)")

		var count = 0

		if let data = self.memory[table] {
			for (key, _) in data {
				//implement filtering

				if key != "metadata" { //hack
					count += 1
				}
			}
		}

		return count
	}
    func containsTable(table table: String) -> Bool {
        return true
    }
    func createTable(table table: String, sql: String) {
    }
    func execute(SQL: String) {
        
    }
}