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
class TSOutgoingMessageSerializer: SDSSerializer {

    private let model: TSOutgoingMessage
    public required init(model: TSOutgoingMessage) {
        self.model = model
    }

    // MARK: - Record

    func toRecord(forUpdate: Bool) throws -> InteractionRecord {
        var id: Int64?
        if forUpdate {
            guard let grdbId: NSNumber = model.grdbId else {
                owsFailDebug("Model is missing grdbId.")
                throw SDSError.missingRequiredField
            }
            id = grdbId.int64Value
        }

        let recordType: SDSRecordType = .outgoingMessage
        guard let uniqueId: String = model.uniqueId else {
            owsFailDebug("Missing uniqueId.")
            throw SDSError.missingRequiredField
        }

        // Base class properties
        let receivedAtTimestamp: UInt64 = model.receivedAtTimestamp
        let timestamp: UInt64 = model.timestamp
        let threadUniqueId: String = model.uniqueThreadId

        // Subclass properties
        let attachmentFilenameMap: Data? = optionalArchive(model.attachmentFilenameMap)
        let attachmentIds: Data? = optionalArchive(model.attachmentIds)
        let authorId: String? = nil
        let beforeInteractionId: String? = nil
        let body: String? = model.body
        let callSchemaVersion: UInt? = nil
        let callType: RPRecentCallType? = nil
        let configurationDurationSeconds: UInt32? = nil
        let configurationIsEnabled: Bool? = nil
        let contactId: String? = nil
        let contactShare: Data? = optionalArchive(model.contactShare)
        let createdByRemoteName: String? = nil
        let createdInExistingGroup: Bool? = nil
        let customMessage: String? = model.customMessage
        let envelopeData: Data? = nil
        let ephemeralMessage: Data? = optionalArchive(model.ephemeralMessage)
        let errorMessageSchemaVersion: UInt? = nil
        let errorType: TSErrorMessageType? = nil
        let expireStartedAt: UInt64? = model.expireStartedAt
        let expiresAt: UInt64? = model.expiresAt
        let expiresInSeconds: UInt32? = model.expiresInSeconds
        let groupMetaMessage: TSGroupMetaMessage? = model.groupMetaMessage
        let hasAddToContactsOffer: Bool? = nil
        let hasAddToProfileWhitelistOffer: Bool? = nil
        let hasBlockOffer: Bool? = nil
        let hasLegacyMessageState: Bool? = model.hasLegacyMessageState
        let hasSyncedTranscript: Bool? = model.hasSyncedTranscript
        let infoMessageSchemaVersion: UInt? = nil
        let isFromLinkedDevice: Bool? = model.isFromLinkedDevice
        let isLocalChange: Bool? = nil
        let isVoiceMessage: Bool? = model.isVoiceMessage
        let legacyMessageState: TSOutgoingMessageState? = model.legacyMessageState
        let legacyWasDelivered: Bool? = model.legacyWasDelivered
        let linkPreview: Data? = optionalArchive(model.linkPreview)
        let messageId: String? = nil
        let messageSticker: Data? = optionalArchive(model.messageSticker)
        let messageType: TSInfoMessageType? = nil
        let mostRecentFailureText: String? = model.mostRecentFailureText
        let preKeyBundle: Data? = nil
        let quotedMessage: Data? = optionalArchive(model.quotedMessage)
        let read: Bool? = nil
        let recipientId: String? = nil
        let recipientStateMap: Data? = optionalArchive(model.recipientStateMap)
        let schemaVersion: UInt? = model.schemaVersion
        let serverTimestamp: UInt64? = nil
        let sourceDeviceId: UInt32? = nil
        let unregisteredRecipientId: String? = nil
        let verificationState: OWSVerificationState? = nil
        let wasReceivedByUD: Bool? = nil

        return InteractionRecord(id: id, recordType: recordType, uniqueId: uniqueId, receivedAtTimestamp: receivedAtTimestamp, timestamp: timestamp, threadUniqueId: threadUniqueId, attachmentFilenameMap: attachmentFilenameMap, attachmentIds: attachmentIds, authorId: authorId, beforeInteractionId: beforeInteractionId, body: body, callSchemaVersion: callSchemaVersion, callType: callType, configurationDurationSeconds: configurationDurationSeconds, configurationIsEnabled: configurationIsEnabled, contactId: contactId, contactShare: contactShare, createdByRemoteName: createdByRemoteName, createdInExistingGroup: createdInExistingGroup, customMessage: customMessage, envelopeData: envelopeData, ephemeralMessage: ephemeralMessage, errorMessageSchemaVersion: errorMessageSchemaVersion, errorType: errorType, expireStartedAt: expireStartedAt, expiresAt: expiresAt, expiresInSeconds: expiresInSeconds, groupMetaMessage: groupMetaMessage, hasAddToContactsOffer: hasAddToContactsOffer, hasAddToProfileWhitelistOffer: hasAddToProfileWhitelistOffer, hasBlockOffer: hasBlockOffer, hasLegacyMessageState: hasLegacyMessageState, hasSyncedTranscript: hasSyncedTranscript, infoMessageSchemaVersion: infoMessageSchemaVersion, isFromLinkedDevice: isFromLinkedDevice, isLocalChange: isLocalChange, isVoiceMessage: isVoiceMessage, legacyMessageState: legacyMessageState, legacyWasDelivered: legacyWasDelivered, linkPreview: linkPreview, messageId: messageId, messageSticker: messageSticker, messageType: messageType, mostRecentFailureText: mostRecentFailureText, preKeyBundle: preKeyBundle, quotedMessage: quotedMessage, read: read, recipientId: recipientId, recipientStateMap: recipientStateMap, schemaVersion: schemaVersion, serverTimestamp: serverTimestamp, sourceDeviceId: sourceDeviceId, unregisteredRecipientId: unregisteredRecipientId, verificationState: verificationState, wasReceivedByUD: wasReceivedByUD)
    }

    public func serializableColumnTableMetadata() -> SDSTableMetadata {
        return TSInteractionSerializer.table
    }

    public func updateColumnNames() -> [String] {
        return [
            TSInteractionSerializer.idColumn,
            TSInteractionSerializer.receivedAtTimestampColumn,
            TSInteractionSerializer.timestampColumn,
            TSInteractionSerializer.uniqueThreadIdColumn,
            TSInteractionSerializer.attachmentIdsColumn,
            TSInteractionSerializer.bodyColumn,
            TSInteractionSerializer.contactShareColumn,
            TSInteractionSerializer.ephemeralMessageColumn,
            TSInteractionSerializer.expireStartedAtColumn,
            TSInteractionSerializer.expiresAtColumn,
            TSInteractionSerializer.expiresInSecondsColumn,
            TSInteractionSerializer.linkPreviewColumn,
            TSInteractionSerializer.messageStickerColumn,
            TSInteractionSerializer.quotedMessageColumn,
            TSInteractionSerializer.schemaVersionColumn,
            TSInteractionSerializer.attachmentFilenameMapColumn,
            TSInteractionSerializer.customMessageColumn,
            TSInteractionSerializer.groupMetaMessageColumn,
            TSInteractionSerializer.hasLegacyMessageStateColumn,
            TSInteractionSerializer.hasSyncedTranscriptColumn,
            TSInteractionSerializer.isFromLinkedDeviceColumn,
            TSInteractionSerializer.isVoiceMessageColumn,
            TSInteractionSerializer.legacyMessageStateColumn,
            TSInteractionSerializer.legacyWasDeliveredColumn,
            TSInteractionSerializer.mostRecentFailureTextColumn,
            TSInteractionSerializer.recipientStateMapColumn
            ].map { $0.columnName }
    }

    public func uniqueIdColumnName() -> String {
        return TSInteractionSerializer.uniqueIdColumn.columnName
    }

    // TODO: uniqueId is currently an optional on our models.
    //       We should probably make the return type here String?
    public func uniqueIdColumnValue() -> DatabaseValueConvertible {
        // FIXME remove force unwrap
        return model.uniqueId!
    }
}
