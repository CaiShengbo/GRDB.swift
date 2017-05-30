import XCTest
#if GRDBCIPHER
    import GRDBCipher
#elseif GRDBCUSTOMSQLITE
    import GRDBCustomSQLite
#else
    import GRDB
#endif

class DatabaseValueConvertibleDecodableTests: GRDBTestCase {
    func testDatabaseValueConvertibleImplementationDerivedFromDecodable() {
        struct Value : Decodable, DatabaseValueConvertible {
            let string: String
            
            init(from decoder: Decoder) throws {
                string = try decoder.singleValueContainer().decode(String.self)
            }
            
            // DatabaseValueConvertible
            var databaseValue: DatabaseValue {
                return string.databaseValue
            }
            
            // Infered
            // static func fromDatabaseValue(_ databaseValue: DatabaseValue) -> Value? { ... }
        }
        
        let value = Value.fromDatabaseValue("foo".databaseValue)!
        XCTAssertEqual(value.string, "foo")
    }
}
