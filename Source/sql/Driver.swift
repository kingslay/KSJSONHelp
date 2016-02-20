public protocol Driver {
	func fetchOne(table table: String, filters: [Filter]) -> [String: Binding?]?
	func fetch(table table: String, filters: [Filter]) -> [[String: Binding?]]?
	func delete(table table: String, filters: [Filter])
	func update(table table: String, filters: [Filter], data: [String: Binding?])
	func insert(table table: String, items: [[String: Binding?]])
	func upsert(table table: String, items: [[String: Binding?]])
	func exists(table table: String, filters: [Filter]) -> Bool
	func count(table table: String, filters: [Filter]) -> Int
    func containsTable(table table: String) -> Bool
    func createTable(table table: String, sql: String)
    func execute(SQL: String)
}