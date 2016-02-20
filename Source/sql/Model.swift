/**
	Base model for all Fluent entities. 

	Override the `table()`, `serialize()`, and `init(serialized:)`
	methods on your subclass. 
*/
/** Implement this protocol to use primary keys */
public protocol PrimaryKeys {
    /**
     Method used to define a set of primary keys for the types table
     
     - returns:  set of property names
     */
    static func primaryKeys() -> Set<String>
}

/** Implement this protocol to ignore arbitrary properties */
public protocol IgnoredProperties {
    /**
     Method used to define a set of ignored properties
     
     - returns:  set of property names
     */
    static func ignoredProperties() -> Set<String>
}

public protocol Model {
	///The entities database identifier. `nil` when not saved yet.
	var id: String? { get }

	///The database table in which entities are stored.
	static var table: String { get }
	/**
		This method will be called when the entity is saved. 
		The keys of the dictionary are the column names
		in the database.
	*/
    var serialize: [String: Binding?] { get }

	init(serialized: [String: Binding?])
}

extension Model {

	public func save() {
		Query().save(self)
	}

	public func delete() {
		Query().delete(self)
	}

	public static func find(id: Int) -> Self? {
		return Query().find(id)
	}
    public var serialize: [String: Binding?] {
        var data: [String: Binding?] = [:]
        let propertyData = PropertyData.validPropertyDataForObject(self)
        for propertyData in  propertyData{
            data[propertyData.name!] = propertyData.value
        }
        return data
    }
    
}
