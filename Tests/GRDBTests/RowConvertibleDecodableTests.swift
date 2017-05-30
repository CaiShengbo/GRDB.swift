import Foundation
import XCTest
#if GRDBCIPHER
    import GRDBCipher
#elseif GRDBCUSTOMSQLITE
    import GRDBCustomSQLite
#else
    import GRDB
#endif

// // Does not adopt DatabaseValueConvertible
// private enum Color: String, Decodable {
//     case red, green, blue
// }
// 
// private struct DecodableStruct : RowConvertible, Decodable {
//     let id: Int64?
//     let name: String
//     let color: Color?
// }
// 
// private class DecodableClass : RowConvertible, Decodable {
//     let id: Int64?
//     let name: String
//     let color: Color?
//     
//     init(id: Int64?, name: String, color: Color?) {
//         self.id = id
//         self.name = name
//         self.color = color
//     }
// }
// 
// private struct CustomDecodableStruct : RowConvertible, Decodable {
//     let identifier: Int64?
//     let pseudo: String
//     let color: Color?
//     
//     private enum CodingKeys : String, CodingKey {
//         case identifier = "id"
//         case pseudo = "name"
//         case color
//     }
//     
//     init(from decoder: Decoder) throws {
//         let container = try decoder.container(keyedBy: CodingKeys.self)
//         identifier = try container.decodeIfPresent(Int64.self, forKey: .identifier)
//         pseudo = try container.decode(String.self, forKey: .pseudo).uppercased()
//         color = try container.decodeIfPresent(Color.self, forKey: .color)
//     }
// }
// 
// // Does not adopt RowConvertible
// private struct KeyedDecodable: Decodable {
//     let id: Int64?
//     let name: String
//     let color: Color?
// }
// 
// private struct DecodableNested : RowConvertible, Decodable {
//     let rowConvertibleDecodable: DecodableStruct // RowConvertible & Decodable (keyed)
//     let keyedDecodable: KeyedDecodable           // Decodable (keyed)
//     let color: Color                             // Decodable (single value)
// }
//
//// Not supported yet by Swift
// private class DecodableDerivedClass : DecodableClass {
//     let email: String?
//
//     init(id: Int64?, name: String, color: Color?, email: String?) {
//         self.email = email
//         super.init(id: id, name: name, color: color)
//     }
//
//     // Codable boilerplate
//     private enum CodingKeys : CodingKey {
//         case email
//     }
//
//     required init(from decoder: Decoder) throws {
//         let container = try decoder.container(keyedBy: CodingKeys.self)
//         self.email = try container.decodeIfPresent(String.self, forKey: .email)
//         try super.init(from: container.superDecoder())
//     }
// }

// MARK: - Keyed Row Decoding

class RowConvertibleDecodableTests: GRDBTestCase {
    func testTrivialProperty() {
        struct Struct : RowConvertible, Decodable {
            let int64: Int64
            let optionalInt64: Int64?
        }
        
        do {
            // No null values
            let s = Struct(row: ["int64": 1, "optionalInt64": 2])
            XCTAssertEqual(s.int64, 1)
            XCTAssertEqual(s.optionalInt64, 2)
        }
        do {
            // Null values
            let s = Struct(row: ["int64": 2, "optionalInt64": nil])
            XCTAssertEqual(s.int64, 2)
            XCTAssertNil(s.optionalInt64)
        }
        do {
            // Missing and extra values
            let s = Struct(row: ["int64": 3, "ignored": "?"])
            XCTAssertEqual(s.int64, 3)
            XCTAssertNil(s.optionalInt64)
        }
    }
    
    func testDecodablePropertyFromSingleValueDecoder() {
        struct Value : Decodable {
            let string: String
            
            init(from decoder: Decoder) throws {
                string = try decoder.singleValueContainer().decode(String.self)
            }
        }
        
        struct Struct : RowConvertible, Decodable {
            let value: Value
            let optionalValue: Value?
        }
        
        do {
            // No null values
            let s = Struct(row: ["value": "foo", "optionalValue": "bar"])
            XCTAssertEqual(s.value.string, "foo")
            XCTAssertEqual(s.optionalValue!.string, "bar")
        }
        
        // Nil values are not supported (fatal error "could not convert database value NULL to String")
        // That's because GRDB doesn't know if the "optionalValue" is the name
        // of a column, or the name of a row scope, and can't test for missing
        // column, null column value, or missing row scope.
        //
        // TODO: report an issue
//         do {
//             // Null values
//             let s = Struct(row: ["value": "foo", "optionalValue": nil])
//             XCTAssertEqual(s.value.string, "foo")
//             XCTAssertNil(s.optionalValue)
//         }
        
        do {
            // Missing and extra values
            let s = Struct(row: ["value": "foo", "ignored": "?"])
            XCTAssertEqual(s.value.string, "foo")
            XCTAssertNil(s.optionalValue)
        }
    }
    
    func testDecodablePropertyWithCustomDatabaseValueConvertibleImplementation() {
        struct Value : Decodable, DatabaseValueConvertible {
            let string: String
            
            init(string: String) {
                self.string = string
            }
            
            init(from decoder: Decoder) throws {
                string = try decoder.singleValueContainer().decode(String.self)
            }
            
            // DatabaseValueConvertible
            var databaseValue: DatabaseValue {
                return string.databaseValue
            }
            
            static func fromDatabaseValue(_ databaseValue: DatabaseValue) -> Value? {
                if let string = String.fromDatabaseValue(databaseValue) {
                    return Value(string: string + " (DatabaseValueConvertible)")
                } else {
                    return nil
                }
            }
        }
        
        struct Struct : RowConvertible, Decodable {
            let value: Value
            let optionalValue: Value?
        }
        
        do {
            // No null values
            let s = Struct(row: ["value": "foo", "optionalValue": "bar"])
            XCTAssertEqual(s.value.string, "foo (DatabaseValueConvertible)")
            XCTAssertEqual(s.optionalValue!.string, "bar (DatabaseValueConvertible)")
        }
        
        do {
            // Null values
            let s = Struct(row: ["value": "foo", "optionalValue": nil])
            XCTAssertEqual(s.value.string, "foo (DatabaseValueConvertible)")
            XCTAssertNil(s.optionalValue)
        }
        
        do {
            // Missing and extra values
            let s = Struct(row: ["value": "foo", "ignored": "?"])
            XCTAssertEqual(s.value.string, "foo (DatabaseValueConvertible)")
            XCTAssertNil(s.optionalValue)
        }
    }
    
//    func testDecodableStruct() {
//        struct Value1 : Decodable {
//            let string: String
//        }
//        
//        struct Value2 : Decodable, DatabaseValueConvertible {
//            let string: String
//            var databaseValue: DatabaseValue { return string.databaseValue }
//        }
//        
//        struct Value3 : Decodable, DatabaseValueConvertible {
//            let string: String
//            var databaseValue: DatabaseValue { return string.databaseValue }
//            
//            static func fromDatabaseValue(_ databaseValue: DatabaseValue) -> Value3? {
//                return Value3(string: "decodedByDatabaseValueConvertible")
//            }
//        }
//        
//        struct Value4 : Decodable, DatabaseValueConvertible {
//            let string: String
//            var databaseValue: DatabaseValue { return string.databaseValue }
//            
//            init(string: String) {
//                self.string = string
//            }
//            
//            private enum CodingKeys : String, CodingKey {
//                case string = "string"
//            }
//            
//            init(from decoder: Decoder) throws {
//                let container = try decoder.container(keyedBy: CodingKeys.self)
//                string = try container.decode(String.self, forKey: .string) + " (Decodable)"
//            }
//            
//            static func fromDatabaseValue(_ databaseValue: DatabaseValue) -> Value4? {
//                if let string = String.fromDatabaseValue(databaseValue) {
//                    return Value4(string: string + " (DatabaseValueConvertible)")
//                } else {
//                    return nil
//                }
//            }
//        }
//        
//        struct Struct : RowConvertible, Decodable {
//            let int64: Int64
//            let optionalInt64: Int64?
//            let value1: Value1
//            let optionalValue1: Value1?
//            let value3: Value3
//            let optionalValue3: Value3?
//            let value4: Value4
//            let optionalValue4: Value4?
//        }
//        
//        do {
//            // No null values
//            let value = Struct(row: ["id": 1, "name": "Arthur", "color": "red"])
//            XCTAssertEqual(value.id, 1)
//            XCTAssertEqual(value.name, "Arthur")
//            XCTAssertEqual(value.color, .red)
//        }
//        do {
//            // Null, missing, and extra values
//            let value = Struct(row: ["id": nil, "name": "Arthur", "ignored": true])
//            XCTAssertNil(value.id)
//            XCTAssertEqual(value.name, "Arthur")
//            XCTAssertNil(value.color)
//        }
//    }
//
//    func testCustomDecodableStruct() {
//        do {
//            // No null values
//            let value = CustomDecodableStruct(row: ["id": 1, "name": "Arthur", "color": "red"])
//            XCTAssertEqual(value.identifier, 1)
//            XCTAssertEqual(value.pseudo, "ARTHUR")
//            XCTAssertEqual(value.color, .red)
//        }
//        do {
//            // Null, missing, and extra values
//            let value = CustomDecodableStruct(row: ["id": nil, "name": "Arthur", "ignored": true])
//            XCTAssertNil(value.identifier)
//            XCTAssertEqual(value.pseudo, "ARTHUR")
//            XCTAssertNil(value.color)
//        }
//    }
//    
//    func testDecodableClass() {
//        do {
//            // No null values
//            let value = DecodableClass(row: ["id": 1, "name": "Arthur", "color": "red"])
//            XCTAssertEqual(value.id, 1)
//            XCTAssertEqual(value.name, "Arthur")
//            XCTAssertEqual(value.color, .red)
//        }
//        do {
//            // Null, missing, and extra values
//            let value = DecodableClass(row: ["id": nil, "name": "Arthur", "ignored": true])
//            XCTAssertNil(value.id)
//            XCTAssertEqual(value.name, "Arthur")
//            XCTAssertNil(value.color)
//        }
//    }
//    
//    func testDecodableNested() throws {
//        let dbQueue = try makeDatabaseQueue()
//        try dbQueue.inDatabase { db in
//            let value = try DecodableNested.fetchOne(
//                db,
//                "SELECT :id AS id, :name AS name, :color AS color",
//                arguments: ["id": 1, "name": "Arthur", "color": "red"],
//                adapter: ScopeAdapter([
//                    "rowConvertibleDecodable": SuffixRowAdapter(fromIndex: 0),
//                    "keyedDecodable": SuffixRowAdapter(fromIndex: 0)]))!
//            XCTAssertEqual(value.rowConvertibleDecodable.id, 1)
//            XCTAssertEqual(value.rowConvertibleDecodable.name, "Arthur")
//            XCTAssertEqual(value.rowConvertibleDecodable.color, .red)
//            XCTAssertEqual(value.keyedDecodable.id, 1)
//            XCTAssertEqual(value.keyedDecodable.name, "Arthur")
//            XCTAssertEqual(value.keyedDecodable.color, .red)
//            XCTAssertEqual(value.color, .red)
//        }
//    }
}

// MARK: - Foundation Codable Types

extension RowConvertibleDecodableTests {

    func testStructWithDate() {
        struct StructWithDate : RowConvertible, Decodable {
            let date: Date
        }
        
        let date = Date()
        let value = StructWithDate(row: ["date": date])
        XCTAssert(abs(value.date.timeIntervalSince(date)) < 0.001)
    }
    
    func testStructWithURL() {
        struct StructWithURL : RowConvertible, Decodable {
            let url: URL
        }
        
        let url = URL(string: "https://github.com")
        let value = StructWithURL(row: ["url": url])
        XCTAssertEqual(value.url, url)
    }
    
    func testStructWithUUID() {
        struct StructWithUUID : RowConvertible, Decodable {
            let uuid: UUID
        }
        
        let uuid = UUID()
        let value = StructWithUUID(row: ["uuid": uuid])
        XCTAssertEqual(value.uuid, uuid)
    }
}

// Not supported yet by Swift
// func testDecodableDerivedClass() {
//     do {
//         // No null values
//         let player = DecodableDerivedClass(row: ["id": 1, "name": "Arthur", "color": "red", "email": "arthur@example.com"])
//         XCTAssertEqual(player.id, 1)
//         XCTAssertEqual(player.name, "Arthur")
//         XCTAssertEqual(player.color, .red)
//         XCTAssertEqual(player.email, "arthur@example.com")
//     }
//     do {
//         // Null, missing, and extra values
//         let player = DecodableDerivedClass(row: ["id": nil, "name": "Arthur", "ignored": true])
//         XCTAssertNil(player.id)
//         XCTAssertEqual(player.name, "Arthur")
//         XCTAssertNil(player.color)
//         XCTAssertNil(player.email)
//     }
// }
