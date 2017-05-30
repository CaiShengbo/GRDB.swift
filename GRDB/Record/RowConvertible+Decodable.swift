struct RowKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let row: Row
    
    init(row: Row, codingPath: [CodingKey?]) {
        self.row = row
        self.codingPath = codingPath
    }
    
    /// The path of coding keys taken to get to this point in decoding.
    /// A `nil` value indicates an unkeyed container.
    let codingPath: [CodingKey?]
    
    /// All the keys the `Decoder` has for this container.
    ///
    /// Different keyed containers from the same `Decoder` may return different keys here; it is possible to encode with multiple key types which are not convertible to one another. This should report all keys present which are convertible to the requested type.
    var allKeys: [Key] {
        return row.columnNames.flatMap { Key(stringValue: $0) }
    }
    
    /// Returns whether the `Decoder` contains a value associated with the given key.
    ///
    /// The value associated with the given key may be a null value as appropriate for the data format.
    ///
    /// - parameter key: The key to search for.
    /// - returns: Whether the `Decoder` has an entry for the given key.
    func contains(_ key: Key) -> Bool {
        return row.hasColumn(key.stringValue) || (row.scoped(on: key.stringValue) != nil)
    }
    
    /// Decodes a value of the given type for the given key.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
    /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
    func decode(_ type: Bool.Type,   forKey key: Key) throws -> Bool   { return row[key.stringValue] }
    func decode(_ type: Int.Type,    forKey key: Key) throws -> Int    { return row[key.stringValue] }
    func decode(_ type: Int8.Type,   forKey key: Key) throws -> Int8   { return row[key.stringValue] }
    func decode(_ type: Int16.Type,  forKey key: Key) throws -> Int16  { return row[key.stringValue] }
    func decode(_ type: Int32.Type,  forKey key: Key) throws -> Int32  { return row[key.stringValue] }
    func decode(_ type: Int64.Type,  forKey key: Key) throws -> Int64  { return row[key.stringValue] }
    func decode(_ type: UInt.Type,   forKey key: Key) throws -> UInt   { return row[key.stringValue] }
    func decode(_ type: UInt8.Type,  forKey key: Key) throws -> UInt8  { return row[key.stringValue] }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { return row[key.stringValue] }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { return row[key.stringValue] }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { return row[key.stringValue] }
    func decode(_ type: Float.Type,  forKey key: Key) throws -> Float  { return row[key.stringValue] }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double { return row[key.stringValue] }
    func decode(_ type: String.Type, forKey key: Key) throws -> String { return row[key.stringValue] }
    
    /// Decodes a value of the given type for the given key.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A value of the requested type, if present for the given key and convertible to the requested type.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
    /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        if let valueType = T.self as? DatabaseValueConvertible.Type {
            // Prefer DatabaseValueConvertible decoding over Decodable.
            // This allows us to decode Date from String, for example.
            return valueType.fromDatabaseValue(row[key.stringValue]) as! T
        } else {
            return try T(from: RowDecoder(row: row, codingPath: codingPath + [key]))
        }
    }
    
    /// Decodes a value of the given type for the given key, if present.
    ///
    /// This method returns `nil` if the container does not have a value associated with `key`, or if the value is null. The difference between these states can be distinguished with a `contains(_:)` call.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A decoded value of the requested type, or `nil` if the `Decoder` does not have an entry associated with the given key, or if the value is a null value.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    func decodeIfPresent(_ type: Bool.Type,   forKey key: Key) throws -> Bool?   { return row[key.stringValue] }
    func decodeIfPresent(_ type: Int.Type,    forKey key: Key) throws -> Int?    { return row[key.stringValue] }
    func decodeIfPresent(_ type: Int8.Type,   forKey key: Key) throws -> Int8?   { return row[key.stringValue] }
    func decodeIfPresent(_ type: Int16.Type,  forKey key: Key) throws -> Int16?  { return row[key.stringValue] }
    func decodeIfPresent(_ type: Int32.Type,  forKey key: Key) throws -> Int32?  { return row[key.stringValue] }
    func decodeIfPresent(_ type: Int64.Type,  forKey key: Key) throws -> Int64?  { return row[key.stringValue] }
    func decodeIfPresent(_ type: UInt.Type,   forKey key: Key) throws -> UInt?   { return row[key.stringValue] }
    func decodeIfPresent(_ type: UInt8.Type,  forKey key: Key) throws -> UInt8?  { return row[key.stringValue] }
    func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? { return row[key.stringValue] }
    func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? { return row[key.stringValue] }
    func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? { return row[key.stringValue] }
    func decodeIfPresent(_ type: Float.Type,  forKey key: Key) throws -> Float?  { return row[key.stringValue] }
    func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? { return row[key.stringValue] }
    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? { return row[key.stringValue] }
    
    /// Decodes a value of the given type for the given key, if present.
    ///
    /// This method returns `nil` if the container does not have a value associated with `key`, or if the value is null. The difference between these states can be distinguished with a `contains(_:)` call.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A decoded value of the requested type, or `nil` if the `Decoder` does not have an entry associated with the given key, or if the value is a null value.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        if let valueType = T.self as? DatabaseValueConvertible.Type {
            // Prefer DatabaseValueConvertible decoding over Decodable.
            // This allows us to decode Date from String, for example.
            if let dbValue: DatabaseValue = row[key.stringValue] {
                return valueType.fromDatabaseValue(dbValue) as! T?
            } else {
                return nil
            }
        } else if (T.self as? RowConvertible.Type) != nil {
            // T is RowConvertible: we need a row scope:
            if row.scoped(on: key.stringValue) != nil {
                return try T(from: RowDecoder(row: row, codingPath: codingPath + [key]))
            } else {
                return nil
            }
        } else if contains(key) {
            // Column and/or row scope are present.
            //
            // But we don't know if T will ask for a one or the other.
            //
            // Postpone the decision until RowDecoder.container(keyedBy:) or
            // RowDecoder.singleValueContainer() is called. But we have lost
            // the ability to return nil.
            return try T(from: RowDecoder(row: row, codingPath: codingPath + [key]))
        } else {
            // Both column and row scope are missing: we are sure that the value
            // is missing.
            return nil
        }
    }
    
    /// Returns the data stored for the given key as represented in a container keyed by the given key type.
    ///
    /// - parameter type: The key type to use for the container.
    /// - parameter key: The key that the nested container is associated with.
    /// - returns: A keyed decoding container view into `self`.
    /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not a keyed container.
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        fatalError("Not implemented")
    }
    
    /// Returns the data stored for the given key as represented in an unkeyed container.
    ///
    /// - parameter key: The key that the nested container is associated with.
    /// - returns: An unkeyed decoding container view into `self`.
    /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError("Not implemented")
    }
    
    /// Returns a `Decoder` instance for decoding `super` from the container associated with the default `super` key.
    ///
    /// Equivalent to calling `superDecoder(forKey:)` with `Key(stringValue: "super", intValue: 0)`.
    ///
    /// - returns: A new `Decoder` to pass to `super.init(from:)`.
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the default `super` key.
    /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the default `super` key.
    func superDecoder() throws -> Decoder {
        return RowDecoder(row: row, codingPath: codingPath)
    }
    
    /// Returns a `Decoder` instance for decoding `super` from the container associated with the given key.
    ///
    /// - parameter key: The key to decode `super` for.
    /// - returns: A new `Decoder` to pass to `super.init(from:)`.
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
    /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for the given key.
    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError("Not implemented")
    }
}

struct RowColumnDecodingContainer: SingleValueDecodingContainer {
    let row: Row
    let column: String
    
    /// Decodes a null value.
    ///
    /// - returns: Whether the encountered value was null.
    func decodeNil() -> Bool {
        return row[column] == nil
    }
    
    /// Decodes a single value of the given type.
    ///
    /// - parameter type: The type to decode as.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
    /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
    func decode(_ type: Bool.Type) throws -> Bool { return row[column] }
    func decode(_ type: Int.Type) throws -> Int { return row[column] }
    func decode(_ type: Int8.Type) throws -> Int8 { return row[column] }
    func decode(_ type: Int16.Type) throws -> Int16 { return row[column] }
    func decode(_ type: Int32.Type) throws -> Int32 { return row[column] }
    func decode(_ type: Int64.Type) throws -> Int64 { return row[column] }
    func decode(_ type: UInt.Type) throws -> UInt { return row[column] }
    func decode(_ type: UInt8.Type) throws -> UInt8 { return row[column] }
    func decode(_ type: UInt16.Type) throws -> UInt16 { return row[column] }
    func decode(_ type: UInt32.Type) throws -> UInt32 { return row[column] }
    func decode(_ type: UInt64.Type) throws -> UInt64 { return row[column] }
    func decode(_ type: Float.Type) throws -> Float { return row[column] }
    func decode(_ type: Double.Type) throws -> Double { return row[column] }
    func decode(_ type: String.Type) throws -> String { return row[column] }
    
    /// Decodes a single value of the given type.
    ///
    /// - parameter type: The type to decode as.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
    /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        fatalError("Not implemented")
    }
}

struct RowDecoder: Decoder {
    let row: Row
    
    init(row: Row, codingPath: [CodingKey?]) {
        self.row = row
        self.codingPath = codingPath
    }
    
    // Decoder
    let codingPath: [CodingKey?]
    var userInfo: [CodingUserInfoKey : Any] { return [:] }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        if let key = codingPath.last {
            guard let scopedRow = row.scoped(on: key!.stringValue) else {
                throw DecodingError.keyNotFound(key!, DecodingError.Context(codingPath: codingPath, debugDescription: "missing row scope: \(key!.stringValue)"))
            }
            return KeyedDecodingContainer(RowKeyedDecodingContainer<Key>(row: scopedRow, codingPath: codingPath))
        } else {
            return KeyedDecodingContainer(RowKeyedDecodingContainer<Key>(row: row, codingPath: codingPath))
        }
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.typeMismatch(
            UnkeyedDecodingContainer.self,
            DecodingError.Context(codingPath: codingPath, debugDescription: "unkeyed decoding is not supported"))
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return RowColumnDecodingContainer(row: row, column: codingPath.last!!.stringValue)
    }
}

extension RowConvertible where Self: Decodable {
    /// Initializes a record from `row`.
    public init(row: Row) {
        try! self.init(from: RowDecoder(row: row, codingPath: []))
    }
}
