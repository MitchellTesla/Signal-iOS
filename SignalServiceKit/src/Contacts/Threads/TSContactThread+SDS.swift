//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import GRDBCipher
import SignalCoreKit

// NOTE: This file is generated by /Scripts/sds_codegen/sds_generate.py.
// Do not manually edit it, instead run `sds_codegen.sh`.

// MARK: - SDSSerializer

// The SDSSerializer protocol specifies how to insert and update the
// row that corresponds to this model.
class TSContactThreadSerializer: SDSSerializer {

    private let model: TSContactThread
    public required init(model: TSContactThread) {
        self.model = model
    }

    // MARK: - Record

    func toRecord(forUpdate: Bool) throws -> ThreadRecord {
        var id: Int64?
        if forUpdate {
            guard let grdbId: NSNumber = model.grdbId else {
                owsFailDebug("Model is missing grdbId.")
                throw SDSError.missingRequiredField
            }
            id = grdbId.int64Value
        }

        let recordType: SDSRecordType = .contactThread
        guard let uniqueId: String = model.uniqueId else {
            owsFailDebug("Missing uniqueId.")
            throw SDSError.missingRequiredField
        }

        // Base class properties
        let archivalDate: Date? = model.archivalDate
        let archivedAsOfMessageSortId: Bool? = archiveOptionalNSNumber(model.archivedAsOfMessageSortId, conversion: { $0.boolValue })
        let conversationColorName: String = model.conversationColorName.rawValue
        let creationDate: Date = model.creationDate
        let isArchivedByLegacyTimestampForSorting: Bool = model.isArchivedByLegacyTimestampForSorting
        let lastMessageDate: Date? = model.lastMessageDate
        let messageDraft: String? = model.messageDraft
        let mutedUntilDate: Date? = model.mutedUntilDate
        let shouldThreadBeVisible: Bool = model.shouldThreadBeVisible

        // Subclass properties
        let groupModel: Data? = nil
        let hasDismissedOffers: Bool? = model.hasDismissedOffers

        return ThreadRecord(id: id, recordType: recordType, uniqueId: uniqueId, archivalDate: archivalDate, archivedAsOfMessageSortId: archivedAsOfMessageSortId, conversationColorName: conversationColorName, creationDate: creationDate, isArchivedByLegacyTimestampForSorting: isArchivedByLegacyTimestampForSorting, lastMessageDate: lastMessageDate, messageDraft: messageDraft, mutedUntilDate: mutedUntilDate, shouldThreadBeVisible: shouldThreadBeVisible, groupModel: groupModel, hasDismissedOffers: hasDismissedOffers)
    }

    public func serializableColumnTableMetadata() -> SDSTableMetadata {
        return TSThreadSerializer.table
    }

    public func updateColumnNames() -> [String] {
        return [
            TSThreadSerializer.idColumn,
            TSThreadSerializer.archivalDateColumn,
            TSThreadSerializer.archivedAsOfMessageSortIdColumn,
            TSThreadSerializer.conversationColorNameColumn,
            TSThreadSerializer.creationDateColumn,
            TSThreadSerializer.isArchivedByLegacyTimestampForSortingColumn,
            TSThreadSerializer.lastMessageDateColumn,
            TSThreadSerializer.messageDraftColumn,
            TSThreadSerializer.mutedUntilDateColumn,
            TSThreadSerializer.shouldThreadBeVisibleColumn,
            TSThreadSerializer.hasDismissedOffersColumn
            ].map { $0.columnName }
    }

    public func uniqueIdColumnName() -> String {
        return TSThreadSerializer.uniqueIdColumn.columnName
    }

    // TODO: uniqueId is currently an optional on our models.
    //       We should probably make the return type here String?
    public func uniqueIdColumnValue() -> DatabaseValueConvertible {
        // FIXME remove force unwrap
        return model.uniqueId!
    }
}
