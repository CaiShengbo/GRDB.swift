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
            
            var databaseValue: DatabaseValue {
                preconditionFailure("unused")
            }
            
            // Infered, tested
            // static func fromDatabaseValue(_ databaseValue: DatabaseValue) -> Value? { ... }
        }
        
        let value = Value.fromDatabaseValue("foo".databaseValue)!
        XCTAssertEqual(value.string, "foo")
    }
    
    func testDecodableRawRepresentableFetchingMethod() throws {
        enum Value : String, Decodable, DatabaseValueConvertible {
            case foo, bar
        }
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            let value = try Value.fetchOne(db, "SELECT 'foo'")!
            XCTAssertEqual(value, .foo)
        }
    }
}
