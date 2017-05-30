import XCTest
#if GRDBCIPHER
    import GRDBCipher
#elseif GRDBCUSTOMSQLITE
    import GRDBCustomSQLite
#else
    import GRDB
#endif

class DatabaseValueConvertibleEncodableTests: GRDBTestCase {
    func testDatabaseValueConvertibleImplementationDerivedFromEncodable() {
        struct Value : Encodable, DatabaseValueConvertible {
            let string: String
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(string)
            }
            
            static func fromDatabaseValue(_ databaseValue: DatabaseValue) -> Value? {
                preconditionFailure("unused")
            }
            
            // Infered, tested
            // var databaseValue: DatabaseValue { ... }
        }
        
        let dbValue = Value(string: "foo").databaseValue
        XCTAssertEqual(dbValue.storage.value as! String, "foo")
    }
    
    // This test crashes the compiler. TODO: report a bug
    // func testEncodableRawRepresentable() {
    //     // DatabaseValueConvertible favors RawValue over Encodable
    //     struct Value : RawRepresentable, Encodable, DatabaseValueConvertible {
    //         let rawValue: Date
    //     }
    //
    //     let dbValue = Value(rawValue: Date()).databaseValue
    //     XCTAssertEqual(dbValue.storage.value is String)
    // }
    
    func testEncodableRawRepresentableEnum() {
        // Make sure this kind of declaration is possible
        enum Value : String, Encodable, DatabaseValueConvertible {
            case foo, bar
        }
        let dbValue = Value.foo.databaseValue
        XCTAssertEqual(dbValue.storage.value as! String, "foo")
    }
}
