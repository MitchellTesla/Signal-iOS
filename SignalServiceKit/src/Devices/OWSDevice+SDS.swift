//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import GRDBCipher
import SignalCoreKit

// NOTE: This file is generated by /Scripts/sds_codegen/sds_generate.py.
// Do not manually edit it, instead run `sds_codegen.sh`.

// MARK: - Record

public struct DeviceRecord: SDSRecord {
    public static let databaseTableName: String = OWSDeviceSerializer.table.tableName

    public var id: Int64?

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    public let recordType: SDSRecordType
    public let uniqueId: String

    // Base class properties
    public let createdAt: Date
    public let deviceId: Int
    public let lastSeenAt: Date
    public let name: String?

    public enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case recordType
        case uniqueId
        case createdAt
        case deviceId
        case lastSeenAt
        case name
    }

    public static func columnName(_ column: DeviceRecord.CodingKeys, fullyQualified: Bool = false) -> String {
        return fullyQualified ? "\(databaseTableName).\(column.rawValue)" : column.rawValue
    }
}

// MARK: - StringInterpolation

public extension String.StringInterpolation {
    mutating func appendInterpolation(deviceColumn column: DeviceRecord.CodingKeys) {
        appendLiteral(DeviceRecord.columnName(column))
    }
    mutating func appendInterpolation(deviceColumnFullyQualified column: DeviceRecord.CodingKeys) {
        appendLiteral(DeviceRecord.columnName(column, fullyQualified: true))
    }
}

// MARK: - Deserialization

// TODO: Rework metadata to not include, for example, columns, column indices.
extension OWSDevice {
    // This method defines how to deserialize a model, given a
    // database row.  The recordType column is used to determine
    // the corresponding model class.
    class func fromRecord(_ record: DeviceRecord) throws -> OWSDevice {

        guard let recordId = record.id else {
            throw SDSError.invalidValue
        }

        switch record.recordType {
        case .device:

            let uniqueId: String = record.uniqueId
            let createdAt: Date = record.createdAt
            let deviceId: Int = record.deviceId
            let lastSeenAt: Date = record.lastSeenAt
            let name: String? = record.name

            let model = OWSDevice(uniqueId: uniqueId,
                                  createdAt: createdAt,
                                  deviceId: deviceId,
                                  lastSeenAt: lastSeenAt,
                                  name: name)

            if let grdbId = record.id {
                model.grdbId = NSNumber(value: grdbId)
            }
            return model

        default:
            owsFailDebug("Unexpected record type: \(record.recordType)")
            throw SDSError.invalidValue
        }
    }
}

// MARK: - SDSSerializable

extension OWSDevice: SDSSerializable {
    public var serializer: SDSSerializer {
        // Any subclass can be cast to it's superclass,
        // so the order of this switch statement matters.
        // We need to do a "depth first" search by type.
        switch self {
        default:
            return OWSDeviceSerializer(model: self)
        }
    }

    public func asRecord(forUpdate: Bool) throws -> DeviceRecord {
        // Any subclass can be cast to it's superclass,
        // so the order of this switch statement matters.
        // We need to do a "depth first" search by type.
        switch self {
        default:
            return try OWSDeviceSerializer(model: self).toRecord(forUpdate: forUpdate)
        }
    }
}

// MARK: - Table Metadata

extension OWSDeviceSerializer {

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    static let recordTypeColumn = SDSColumnMetadata(columnName: "recordType", columnType: .int, columnIndex: 0)
    static let idColumn = SDSColumnMetadata(columnName: "id", columnType: .primaryKey, columnIndex: 1)
    static let uniqueIdColumn = SDSColumnMetadata(columnName: "uniqueId", columnType: .unicodeString, columnIndex: 2)
    // Base class properties
    static let createdAtColumn = SDSColumnMetadata(columnName: "createdAt", columnType: .int64, columnIndex: 3)
    static let deviceIdColumn = SDSColumnMetadata(columnName: "deviceId", columnType: .int64, columnIndex: 4)
    static let lastSeenAtColumn = SDSColumnMetadata(columnName: "lastSeenAt", columnType: .int64, columnIndex: 5)
    static let nameColumn = SDSColumnMetadata(columnName: "name", columnType: .unicodeString, isOptional: true, columnIndex: 6)

    // TODO: We should decide on a naming convention for
    //       tables that store models.
    public static let table = SDSTableMetadata(tableName: "model_OWSDevice", columns: [
        recordTypeColumn,
        idColumn,
        uniqueIdColumn,
        createdAtColumn,
        deviceIdColumn,
        lastSeenAtColumn,
        nameColumn
        ])
}

// MARK: - Save/Remove/Update

@objc
extension OWSDevice {
    public func anyInsert(transaction: SDSAnyWriteTransaction) {
        switch transaction.writeTransaction {
        case .yapWrite(let ydbTransaction):
            save(with: ydbTransaction)
        case .grdbWrite(let grdbTransaction):
            do {
                let database = grdbTransaction.database
                var record = try asRecord(forUpdate: false)
                try record.insert(database)

                guard self.grdbId == nil else {
                    owsFailDebug("Model unexpectedly already has grdbId.")
                    return
                }
                guard let grdbId = record.id else {
                    owsFailDebug("Record missing grdbId.")
                    return
                }
                self.grdbId = NSNumber(value: grdbId)
            } catch {
                owsFail("Write failed: \(error)")
            }
        }
    }

    public func anyUpdate(transaction: SDSAnyWriteTransaction) {
        switch transaction.writeTransaction {
        case .yapWrite(let ydbTransaction):
            save(with: ydbTransaction)
        case .grdbWrite(let grdbTransaction):
            do {
                let database = grdbTransaction.database
                let record = try asRecord(forUpdate: true)
                try record.update(database, columns: serializer.updateColumnNames())
            } catch {
                owsFail("Write failed: \(error)")
            }
        }
    }

    // This method is used by "updateWith..." methods.
    //
    // This model may be updated from many threads. We don't want to save
    // our local copy (this instance) since it may be out of date.  We also
    // want to avoid re-saving a model that has been deleted.  Therefore, we
    // use "updateWith..." methods to:
    //
    // a) Update a property of this instance.
    // b) If a copy of this model exists in the database, load an up-to-date copy,
    //    and update and save that copy.
    // b) If a copy of this model _DOES NOT_ exist in the database, do _NOT_ save
    //    this local instance.
    //
    // After "updateWith...":
    //
    // a) Any copy of this model in the database will have been updated.
    // b) The local property on this instance will always have been updated.
    // c) Other properties on this instance may be out of date.
    //
    // All mutable properties of this class have been made read-only to
    // prevent accidentally modifying them directly.
    //
    // This isn't a perfect arrangement, but in practice this will prevent
    // data loss and will resolve all known issues.
    public func anyUpdate(transaction: SDSAnyWriteTransaction, block: (OWSDevice) -> Void) {
        guard let uniqueId = uniqueId else {
            owsFailDebug("Missing uniqueId.")
            return
        }

        block(self)

        guard let dbCopy = type(of: self).anyFetch(uniqueId: uniqueId,
                                                   transaction: transaction) else {
            return
        }

        block(dbCopy)

        dbCopy.anyUpdate(transaction: transaction)
    }

    public func anyRemove(transaction: SDSAnyWriteTransaction) {
        switch transaction.writeTransaction {
        case .yapWrite(let ydbTransaction):
            remove(with: ydbTransaction)
        case .grdbWrite(let grdbTransaction):
            SDSSerialization.delete(entity: self, transaction: grdbTransaction)
        }
    }
}

// MARK: - OWSDeviceCursor

@objc
public class OWSDeviceCursor: NSObject {
    private let cursor: RecordCursor<DeviceRecord>?

    init(cursor: RecordCursor<DeviceRecord>?) {
        self.cursor = cursor
    }

    public func next() throws -> OWSDevice? {
        guard let cursor = cursor else {
            return nil
        }
        guard let record = try cursor.next() else {
            return nil
        }
        return try OWSDevice.fromRecord(record)
    }

    public func all() throws -> [OWSDevice] {
        var result = [OWSDevice]()
        while true {
            guard let model = try next() else {
                break
            }
            result.append(model)
        }
        return result
    }
}

// MARK: - Obj-C Fetch

// TODO: We may eventually want to define some combination of:
//
// * fetchCursor, fetchOne, fetchAll, etc. (ala GRDB)
// * Optional "where clause" parameters for filtering.
// * Async flavors with completions.
//
// TODO: I've defined flavors that take a read transaction.
//       Or we might take a "connection" if we end up having that class.
@objc
extension OWSDevice {
    public class func grdbFetchCursor(transaction: GRDBReadTransaction) -> OWSDeviceCursor {
        let database = transaction.database
        do {
            let cursor = try DeviceRecord.fetchCursor(database)
            return OWSDeviceCursor(cursor: cursor)
        } catch {
            owsFailDebug("Read failed: \(error)")
            return OWSDeviceCursor(cursor: nil)
        }
    }

    // Fetches a single model by "unique id".
    public class func anyFetch(uniqueId: String,
                               transaction: SDSAnyReadTransaction) -> OWSDevice? {
        assert(uniqueId.count > 0)

        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return OWSDevice.fetch(uniqueId: uniqueId, transaction: ydbTransaction)
        case .grdbRead(let grdbTransaction):
            let sql = "SELECT * FROM \(DeviceRecord.databaseTableName) WHERE \(deviceColumn: .uniqueId) = ?"
            return grdbFetchOne(sql: sql, arguments: [uniqueId], transaction: grdbTransaction)
        }
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    // Traversal aborts if the visitor returns false.
    public class func anyVisitAll(transaction: SDSAnyReadTransaction, visitor: @escaping (OWSDevice) -> Bool) {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            OWSDevice.enumerateCollectionObjects(with: ydbTransaction) { (object, stop) in
                guard let value = object as? OWSDevice else {
                    owsFailDebug("unexpected object: \(type(of: object))")
                    return
                }
                guard visitor(value) else {
                    stop.pointee = true
                    return
                }
            }
        case .grdbRead(let grdbTransaction):
            do {
                let cursor = OWSDevice.grdbFetchCursor(transaction: grdbTransaction)
                while let value = try cursor.next() {
                    guard visitor(value) else {
                        return
                    }
                }
            } catch let error as NSError {
                owsFailDebug("Couldn't fetch models: \(error)")
            }
        }
    }

    // Does not order the results.
    public class func anyFetchAll(transaction: SDSAnyReadTransaction) -> [OWSDevice] {
        var result = [OWSDevice]()
        anyVisitAll(transaction: transaction) { (model) in
            result.append(model)
            return true
        }
        return result
    }
}

// MARK: - Swift Fetch

extension OWSDevice {
    public class func grdbFetchCursor(sql: String,
                                      arguments: [DatabaseValueConvertible]?,
                                      transaction: GRDBReadTransaction) -> OWSDeviceCursor {
        var statementArguments: StatementArguments?
        if let arguments = arguments {
            guard let statementArgs = StatementArguments(arguments) else {
                owsFailDebug("Could not convert arguments.")
                return OWSDeviceCursor(cursor: nil)
            }
            statementArguments = statementArgs
        }
        let database = transaction.database
        do {
            let statement: SelectStatement = try database.cachedSelectStatement(sql: sql)
            let cursor = try DeviceRecord.fetchCursor(statement, arguments: statementArguments)
            return OWSDeviceCursor(cursor: cursor)
        } catch {
            Logger.error("sql: \(sql)")
            owsFailDebug("Read failed: \(error)")
            return OWSDeviceCursor(cursor: nil)
        }
    }

    public class func grdbFetchOne(sql: String,
                                   arguments: StatementArguments,
                                   transaction: GRDBReadTransaction) -> OWSDevice? {
        assert(sql.count > 0)

        do {
            guard let record = try DeviceRecord.fetchOne(transaction.database, sql: sql, arguments: arguments) else {
                return nil
            }

            return try OWSDevice.fromRecord(record)
        } catch {
            owsFailDebug("error: \(error)")
            return nil
        }
    }
}

// MARK: - SDSSerializer

// The SDSSerializer protocol specifies how to insert and update the
// row that corresponds to this model.
class OWSDeviceSerializer: SDSSerializer {

    private let model: OWSDevice
    public required init(model: OWSDevice) {
        self.model = model
    }

    // MARK: - Record

    func toRecord(forUpdate: Bool) throws -> DeviceRecord {
        var id: Int64?
        if forUpdate {
            guard let grdbId: NSNumber = model.grdbId else {
                owsFailDebug("Model is missing grdbId.")
                throw SDSError.missingRequiredField
            }
            id = grdbId.int64Value
        }

        let recordType: SDSRecordType = .device
        guard let uniqueId: String = model.uniqueId else {
            owsFailDebug("Missing uniqueId.")
            throw SDSError.missingRequiredField
        }

        // Base class properties
        let createdAt: Date = model.createdAt
        let deviceId: Int = model.deviceId
        let lastSeenAt: Date = model.lastSeenAt
        let name: String? = model.name

        return DeviceRecord(id: id, recordType: recordType, uniqueId: uniqueId, createdAt: createdAt, deviceId: deviceId, lastSeenAt: lastSeenAt, name: name)
    }

    public func serializableColumnTableMetadata() -> SDSTableMetadata {
        return OWSDeviceSerializer.table
    }

    public func updateColumnNames() -> [String] {
        return [
            OWSDeviceSerializer.idColumn,
            OWSDeviceSerializer.createdAtColumn,
            OWSDeviceSerializer.deviceIdColumn,
            OWSDeviceSerializer.lastSeenAtColumn,
            OWSDeviceSerializer.nameColumn
            ].map { $0.columnName }
    }

    public func uniqueIdColumnName() -> String {
        return OWSDeviceSerializer.uniqueIdColumn.columnName
    }

    // TODO: uniqueId is currently an optional on our models.
    //       We should probably make the return type here String?
    public func uniqueIdColumnValue() -> DatabaseValueConvertible {
        // FIXME remove force unwrap
        return model.uniqueId!
    }
}
