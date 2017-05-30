import XCTest
import Foundation
#if GRDBCIPHER
    import GRDBCipher
#elseif GRDBCUSTOMSQLITE
    import GRDBCustomSQLite
#else
    import GRDB
#endif

private enum Color: String, Encodable {
    case red, green, blue
}

private struct EncodableStruct : MutablePersistable, Encodable {
    static let databaseTableName = "t1"
    var id: Int64?
    let name: String
    let color: Color?
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

private class EncodableClass : Persistable, Encodable {
    static let databaseTableName = "t1"
    var id: Int64?
    let name: String
    let color: Color?
    
    init(id: Int64?, name: String, color: Color?) {
        self.id = id
        self.name = name
        self.color = color
    }
    
    func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

private struct CustomEncodableStruct : MutablePersistable, Encodable {
    static let databaseTableName = "t1"
    var identifier: Int64?
    let pseudo: String
    let color: Color?
    
    private enum CodingKeys : String, CodingKey {
        case identifier = "id"
        case pseudo = "name"
        case color
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encode(pseudo.uppercased(), forKey: .pseudo)
        try container.encodeIfPresent(color, forKey: .color)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        identifier = rowID
    }
}

private struct StructWithDate : Persistable, Encodable {
    static let databaseTableName = "t1"
    let date: Date
}

private struct StructWithURL : Persistable, Encodable {
    static let databaseTableName = "t1"
    let url: URL
}

private struct StructWithUUID : Persistable, Encodable {
    static let databaseTableName = "t1"
    let uuid: UUID
}

class MutablePersistableEncodableTests: GRDBTestCase {
    func testEncodableStruct() throws {
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "t1") { t in
                t.column("id", .integer).primaryKey()
                t.column("name", .text).notNull()
                t.column("color", .text)
            }
            
            var value = EncodableStruct(id: nil, name: "Arthur", color: .red)
            try value.insert(db)
            XCTAssertEqual(value.id, 1)
            
            let row = try Row.fetchOne(db, "SELECT id, name, color FROM t1")!
            XCTAssertEqual(row, ["id": 1, "name": "Arthur", "color": "red"])
        }
    }

    func testEncodableClass() throws {
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "t1") { t in
                t.column("id", .integer).primaryKey()
                t.column("name", .text).notNull()
                t.column("color", .text)
            }
            
            let value = EncodableClass(id: nil, name: "Arthur", color: .red)
            try value.insert(db)
            XCTAssertEqual(value.id, 1)
            
            let row = try Row.fetchOne(db, "SELECT id, name, color FROM t1")!
            XCTAssertEqual(row, ["id": 1, "name": "Arthur", "color": "red"])
        }
    }
    
    func testCustomEncodableStruct() throws {
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "t1") { t in
                t.column("id", .integer).primaryKey()
                t.column("name", .text).notNull()
                t.column("color", .text)
            }
            
            var value = CustomEncodableStruct(identifier: nil, pseudo: "Arthur", color: .red)
            try value.insert(db)
            XCTAssertEqual(value.identifier, 1)
            
            let row = try Row.fetchOne(db, "SELECT id, name, color FROM t1")!
            XCTAssertEqual(row, ["id": 1, "name": "ARTHUR", "color": "red"])
        }
    }
    
    func testStructWithDate() throws {
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "t1") { t in
                t.column("date", .datetime)
            }
            
            let value = StructWithDate(date: Date())
            try value.insert(db)
            
            let dbValue = try DatabaseValue.fetchOne(db, "SELECT date FROM t1")!
            
            // Date has a default Encodable implementation which encodes a Double.
            // We expect here a String, because DatabaseValueConvertible has
            // precedence over Encodable.
            XCTAssert(dbValue.storage.value is String)
            
            let fetchedDate = Date.fromDatabaseValue(dbValue)!
            XCTAssert(abs(fetchedDate.timeIntervalSince(value.date)) < 0.001)
        }
    }
    
    func testStructWithURL() throws {
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "t1") { t in
                t.column("url", .text)
            }
            
            let value = StructWithURL(url: URL(string: "https://github.com")!)
            try value.insert(db)
            
            let dbValue = try DatabaseValue.fetchOne(db, "SELECT url FROM t1")!
            XCTAssert(dbValue.storage.value is String)
            let fetchedURL = URL.fromDatabaseValue(dbValue)!
            XCTAssertEqual(fetchedURL, value.url)
        }
    }
    
    func testStructWithUUID() throws {
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "t1") { t in
                t.column("uuid", .blob)
            }
            
            let value = StructWithUUID(uuid: UUID())
            try value.insert(db)
            
            let dbValue = try DatabaseValue.fetchOne(db, "SELECT uuid FROM t1")!
            XCTAssert(dbValue.storage.value is Data)
            let fetchedUUID = UUID.fromDatabaseValue(dbValue)!
            XCTAssertEqual(fetchedUUID, value.uuid)
        }
    }
}
