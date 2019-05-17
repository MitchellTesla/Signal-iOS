//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import GRDBCipher
import SignalCoreKit

// NOTE: This file is generated by /Scripts/sds_codegen/sds_generate.py.
// Do not manually edit it, instead run `sds_codegen.sh`.

// MARK: - Record

public struct MessageContentJobRecord: SDSRecord {
    public static let databaseTableName: String = OWSMessageContentJobSerializer.table.tableName

    public var id: Int64?

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    public let recordType: SDSRecordType
    public let uniqueId: String

    // Base class properties
    public let createdAt: Date
    public let envelopeData: Data
    public let plaintextData: Data?
    public let wasReceivedByUD: Bool

    public enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case recordType
        case uniqueId
        case createdAt
        case envelopeData
        case plaintextData
        case wasReceivedByUD
    }

    public static func columnName(_ column: MessageContentJobRecord.CodingKeys, fullyQualified: Bool = false) -> String {
        return fullyQualified ? "\(databaseTableName).\(column.rawValue)" : column.rawValue
    }
}

// MARK: - StringInterpolation

public extension String.StringInterpolation {
    mutating func appendInterpolation(messageContentJobColumn column: MessageContentJobRecord.CodingKeys) {
        appendLiteral(MessageContentJobRecord.columnName(column))
    }
    mutating func appendInterpolation(messageContentJobColumnFullyQualified column: MessageContentJobRecord.CodingKeys) {
        appendLiteral(MessageContentJobRecord.columnName(column, fullyQualified: true))
    }
}

// MARK: - Deserialization

// TODO: Rework metadata to not include, for example, columns, column indices.
extension OWSMessageContentJob {
    // This method defines how to deserialize a model, given a
    // database row.  The recordType column is used to determine
    // the corresponding model class.
    class func fromRecord(_ record: MessageContentJobRecord) throws -> OWSMessageContentJob {

        guard let recordId = record.id else {
            throw SDSError.invalidValue
        }

        switch record.recordType {
        case .messageContentJob:

            let uniqueId: String = record.uniqueId
            let createdAt: Date = record.createdAt
            let envelopeData: Data = record.envelopeData
            let plaintextData: Data? = SDSDeserialization.optionalData(record.plaintextData, name: "plaintextData")
            let wasReceivedByUD: Bool = record.wasReceivedByUD

            let model = OWSMessageContentJob(uniqueId: uniqueId,
                                             createdAt: createdAt,
                                             envelopeData: envelopeData,
                                             plaintextData: plaintextData,
                                             wasReceivedByUD: wasReceivedByUD)

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

extension OWSMessageContentJob: SDSSerializable {
    public var serializer: SDSSerializer {
        // Any subclass can be cast to it's superclass,
        // so the order of this switch statement matters.
        // We need to do a "depth first" search by type.
        switch self {
        default:
            return OWSMessageContentJobSerializer(model: self)
        }
    }

    public func asRecord(forUpdate: Bool) throws -> MessageContentJobRecord {
        // Any subclass can be cast to it's superclass,
        // so the order of this switch statement matters.
        // We need to do a "depth first" search by type.
        switch self {
        default:
            return try OWSMessageContentJobSerializer(model: self).toRecord(forUpdate: forUpdate)
        }
    }
}

// MARK: - Table Metadata

extension OWSMessageContentJobSerializer {

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    static let recordTypeColumn = SDSColumnMetadata(columnName: "recordType", columnType: .int, columnIndex: 0)
    static let idColumn = SDSColumnMetadata(columnName: "id", columnType: .primaryKey, columnIndex: 1)
    static let uniqueIdColumn = SDSColumnMetadata(columnName: "uniqueId", columnType: .unicodeString, columnIndex: 2)
    // Base class properties
    static let createdAtColumn = SDSColumnMetadata(columnName: "createdAt", columnType: .int64, columnIndex: 3)
    static let envelopeDataColumn = SDSColumnMetadata(columnName: "envelopeData", columnType: .blob, columnIndex: 4)
    static let plaintextDataColumn = SDSColumnMetadata(columnName: "plaintextData", columnType: .blob, isOptional: true, columnIndex: 5)
    static let wasReceivedByUDColumn = SDSColumnMetadata(columnName: "wasReceivedByUD", columnType: .int, columnIndex: 6)

    // TODO: We should decide on a naming convention for
    //       tables that store models.
    public static let table = SDSTableMetadata(tableName: "model_OWSMessageContentJob", columns: [
        recordTypeColumn,
        idColumn,
        uniqueIdColumn,
        createdAtColumn,
        envelopeDataColumn,
        plaintextDataColumn,
        wasReceivedByUDColumn
        ])
}

// MARK: - Save/Remove/Update

@objc
extension OWSMessageContentJob {
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
    public func anyUpdate(transaction: SDSAnyWriteTransaction, block: (OWSMessageContentJob) -> Void) {
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

// MARK: - OWSMessageContentJobCursor

@objc
public class OWSMessageContentJobCursor: NSObject {
    private let cursor: RecordCursor<MessageContentJobRecord>?

    init(cursor: RecordCursor<MessageContentJobRecord>?) {
        self.cursor = cursor
    }

    public func next() throws -> OWSMessageContentJob? {
        guard let cursor = cursor else {
            return nil
        }
        guard let record = try cursor.next() else {
            return nil
        }
        return try OWSMessageContentJob.fromRecord(record)
    }

    public func all() throws -> [OWSMessageContentJob] {
        var result = [OWSMessageContentJob]()
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
extension OWSMessageContentJob {
    public class func grdbFetchCursor(transaction: GRDBReadTransaction) -> OWSMessageContentJobCursor {
        let database = transaction.database
        do {
            let cursor = try MessageContentJobRecord.fetchCursor(database)
            return OWSMessageContentJobCursor(cursor: cursor)
        } catch {
            owsFailDebug("Read failed: \(error)")
            return OWSMessageContentJobCursor(cursor: nil)
        }
    }

    // Fetches a single model by "unique id".
    public class func anyFetch(uniqueId: String,
                               transaction: SDSAnyReadTransaction) -> OWSMessageContentJob? {
        assert(uniqueId.count > 0)

        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return OWSMessageContentJob.fetch(uniqueId: uniqueId, transaction: ydbTransaction)
        case .grdbRead(let grdbTransaction):
            let sql = "SELECT * FROM \(MessageContentJobRecord.databaseTableName) WHERE \(messageContentJobColumn: .uniqueId) = ?"
            return grdbFetchOne(sql: sql, arguments: [uniqueId], transaction: grdbTransaction)
        }
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    // Traversal aborts if the visitor returns false.
    public class func anyVisitAll(transaction: SDSAnyReadTransaction, visitor: @escaping (OWSMessageContentJob) -> Bool) {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            OWSMessageContentJob.enumerateCollectionObjects(with: ydbTransaction) { (object, stop) in
                guard let value = object as? OWSMessageContentJob else {
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
                let cursor = OWSMessageContentJob.grdbFetchCursor(transaction: grdbTransaction)
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
    public class func anyFetchAll(transaction: SDSAnyReadTransaction) -> [OWSMessageContentJob] {
        var result = [OWSMessageContentJob]()
        anyVisitAll(transaction: transaction) { (model) in
            result.append(model)
            return true
        }
        return result
    }
}

// MARK: - Swift Fetch

extension OWSMessageContentJob {
    public class func grdbFetchCursor(sql: String,
                                      arguments: [DatabaseValueConvertible]?,
                                      transaction: GRDBReadTransaction) -> OWSMessageContentJobCursor {
        var statementArguments: StatementArguments?
        if let arguments = arguments {
            guard let statementArgs = StatementArguments(arguments) else {
                owsFailDebug("Could not convert arguments.")
                return OWSMessageContentJobCursor(cursor: nil)
            }
            statementArguments = statementArgs
        }
        let database = transaction.database
        do {
            let statement: SelectStatement = try database.cachedSelectStatement(sql: sql)
            let cursor = try MessageContentJobRecord.fetchCursor(statement, arguments: statementArguments)
            return OWSMessageContentJobCursor(cursor: cursor)
        } catch {
            Logger.error("sql: \(sql)")
            owsFailDebug("Read failed: \(error)")
            return OWSMessageContentJobCursor(cursor: nil)
        }
    }

    public class func grdbFetchOne(sql: String,
                                   arguments: StatementArguments,
                                   transaction: GRDBReadTransaction) -> OWSMessageContentJob? {
        assert(sql.count > 0)

        do {
            guard let record = try MessageContentJobRecord.fetchOne(transaction.database, sql: sql, arguments: arguments) else {
                return nil
            }

            return try OWSMessageContentJob.fromRecord(record)
        } catch {
            owsFailDebug("error: \(error)")
            return nil
        }
    }
}

// MARK: - SDSSerializer

// The SDSSerializer protocol specifies how to insert and update the
// row that corresponds to this model.
class OWSMessageContentJobSerializer: SDSSerializer {

    private let model: OWSMessageContentJob
    public required init(model: OWSMessageContentJob) {
        self.model = model
    }

    // MARK: - Record

    func toRecord(forUpdate: Bool) throws -> MessageContentJobRecord {
        var id: Int64?
        if forUpdate {
            guard let grdbId: NSNumber = model.grdbId else {
                owsFailDebug("Model is missing grdbId.")
                throw SDSError.missingRequiredField
            }
            id = grdbId.int64Value
        }

        let recordType: SDSRecordType = .messageContentJob
        guard let uniqueId: String = model.uniqueId else {
            owsFailDebug("Missing uniqueId.")
            throw SDSError.missingRequiredField
        }

        // Base class properties
        let createdAt: Date = model.createdAt
        let envelopeData: Data = model.envelopeData
        let plaintextData: Data? = model.plaintextData
        let wasReceivedByUD: Bool = model.wasReceivedByUD

        return MessageContentJobRecord(id: id, recordType: recordType, uniqueId: uniqueId, createdAt: createdAt, envelopeData: envelopeData, plaintextData: plaintextData, wasReceivedByUD: wasReceivedByUD)
    }

    public func serializableColumnTableMetadata() -> SDSTableMetadata {
        return OWSMessageContentJobSerializer.table
    }

    public func updateColumnNames() -> [String] {
        return [
            OWSMessageContentJobSerializer.idColumn,
            OWSMessageContentJobSerializer.createdAtColumn,
            OWSMessageContentJobSerializer.envelopeDataColumn,
            OWSMessageContentJobSerializer.plaintextDataColumn,
            OWSMessageContentJobSerializer.wasReceivedByUDColumn
            ].map { $0.columnName }
    }

    public func uniqueIdColumnName() -> String {
        return OWSMessageContentJobSerializer.uniqueIdColumn.columnName
    }

    // TODO: uniqueId is currently an optional on our models.
    //       We should probably make the return type here String?
    public func uniqueIdColumnValue() -> DatabaseValueConvertible {
        // FIXME remove force unwrap
        return model.uniqueId!
    }
}
