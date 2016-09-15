class PrintDriver: Driver {

	func fetchOne(table: String, filter: Filter?) -> [String: Binding?]? {
		print("Fetch One")
		print("\ttable: \(table)")
		self.printfilter(filter)

		return nil
	}

	func fetch(table: String, filter: Filter?) -> [[String: Binding?]]? {
		print("Fetch")
		print("\ttable: \(table)")
		self.printfilter(filter)
		return []
	}

	func delete(table: String, filter: Filter?) {
		print("Delete")
		print("\ttable: \(table)")
		self.printfilter(filter)
	}

	func update(table: String, filter: Filter?, data: [String: Binding?]) {
		print("Update")
		print("\ttable: \(table)")
		self.printfilter(filter)
		print("\t\(data.count) data points")
		for (key, value) in data {
			print("\t\t\(key)=\(value)")
		}
	}

	func insert(table: String, items: [[String: Binding?]]) {
		print("Insert")
		print("\ttable: \(table)")
		print("\t\(items.count) items")
		for (key, item) in items.enumerated() {
			print("\t\titem \(key)")
			for (key, val) in item {
				print("\t\t\t\(key)=\(val)")
			}
		}
	}

	func upsert(table: String, items: [[String: Binding?]]) {
		print("Upsert")
		print("\ttable: \(table)")
		print("\t\(items.count) items")
		for (key, item) in items.enumerated() {
			print("\t\titem \(key)")
			for (key, val) in item {
				print("\t\t\t\(key)=\(val)")
			}
		}

	}
	func exists(table: String, filter: Filter?) -> Bool {
		print("Exists")
		print("\ttable: \(table)")
		self.printfilter(filter)

		return false
	}

	func count(table: String, filter: Filter?) -> Int {
		print("Count")
		print("\ttable: \(table)")
		self.printfilter(filter)

		return 0
	}
    func createTableWith(model: Model){}
    func execute(sql: String) {
        
    }
	func printfilter(_ filter: Filter?) {
        print("\t\(filter?.statement) filter(s)")
	}

}
