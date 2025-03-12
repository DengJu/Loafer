
import Foundation
import RealmSwift

class RealmProvider: NSObject {
    
    static let share = RealmProvider()
    
    public var aRealm: Realm!

    override init() {
        super.init()
        initialized()
    }
    
    func initialized() {
        let version = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "0") as! String).replacingOccurrences(of: ".", with: "").intValue
        let dbVersion = UInt64(version)
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        let dbPath = docPath.appending("/LoaferDB.realm")
        let config = Realm.Configuration(fileURL: URL(string: dbPath), inMemoryIdentifier: nil, syncConfiguration: nil, encryptionKey: nil, readOnly: false, schemaVersion: dbVersion, migrationBlock: nil, deleteRealmIfMigrationNeeded: false, shouldCompactOnLaunch: nil, objectTypes: nil)
        aRealm = try! Realm(configuration: config)
        Realm.asyncOpen(configuration: config) { result in
            switch result {
            case let .success(res):
                debugPrint("\n[LoaferDB] - DataBase open success \(res)")
            case let .failure(error):
                debugPrint("\n[LoaferDB] - DataBase open failure: " + error.localizedDescription)
            }
        }
    }
    
}

extension RealmProvider {
    
    func openTransaction(completion: @escaping ((_ realm: Realm)->Void)) {
        if RealmProvider.share.aRealm.isInWriteTransaction {
            completion(RealmProvider.share.aRealm)
        }else {
            do {
                try RealmProvider.share.aRealm.write {
                    completion(RealmProvider.share.aRealm)
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func addMessage(model: IMSocketMessageItem) {
        let finalMessage = IMSocketMessageSaveItem()
        finalMessage.messageId = model.messageId
        finalMessage.sendId = model.sendId
        finalMessage.recvId = model.recvId
        finalMessage.content = model.content
        finalMessage.contentType = model.contentType
        finalMessage.contentStatus = model.contentStatus
        finalMessage.conversationId = model.conversationId
        finalMessage.times = model.times
        let conversation = queryConversation(from: model.conversationId)
        if queryMessage(from: model.messageId) == nil {
            // Need add a new item when this message is not exist
            openTransaction { realm in
                realm.add(finalMessage)
                conversation?.latestMessageType = model.contentType
                conversation?.latestMessageContent = model.content
                conversation?.times = model.times
            }
            return
        }
        // Just need update when this message is already exist
        openTransaction { realm in
            realm.add(finalMessage, update: .all)
            conversation?.latestMessageType = model.contentType
            conversation?.latestMessageContent = model.content
            conversation?.times = model.times
        }
    }
    
    func addConversation(model: IMSocketMessageItem, receiveUser: IMSocketConversationUserInfoItem) {
        let finalModel = IMSocketConversationSaveItem()
        finalModel.conversationId = model.conversationId
        finalModel.times = model.times
        finalModel.latestMessageType = model.contentType
        finalModel.unreadCount = 0
        finalModel.latestMessageContent = model.content
        finalModel.sendId = model.sendId
        finalModel.recvId = model.recvId
        finalModel.userInfo = receiveUser.kj.JSONString()
        if queryConversation(from: model.conversationId) == nil {
            openTransaction { realm in
                realm.add(finalModel)
            }
        }else {
            openTransaction { realm in
                realm.add(finalModel, update: .all)
            }
        }
    }
    
    func addConversation(model: IMSocketConversationSaveItem) {
        if queryConversation(from: model.conversationId) == nil {
            // Need add a new item when this conversation is not exist
            openTransaction { realm in
                realm.add(model)
            }
            return
        }
        // Just need update when this conversation is already exist
        openTransaction { realm in
            realm.add(model, update: .all)
        }
    }
    
    func addConversation(jsonModel: IMSocketConversationItem) {
        let finalModel = IMSocketConversationSaveItem()
        finalModel.conversationId = jsonModel.conversationId
        finalModel.times = jsonModel.times
        finalModel.latestMessageType = jsonModel.latestMessageType
        finalModel.unreadCount = jsonModel.unreadCount
        finalModel.latestMessageContent = jsonModel.latestMessageContent
        finalModel.sendId = jsonModel.sendId
        finalModel.recvId = jsonModel.recvId
        if let receiveModel = jsonModel.userInfo {
            finalModel.userInfo = receiveModel.kj.JSONString()
        }
        if queryConversation(from: jsonModel.conversationId) == nil {
            // Need add a new item when this conversation is not exist
            openTransaction { realm in
                realm.add(finalModel)
            }
            return
        }
        // Just need update when this conversation is already exist
        openTransaction { realm in
            realm.add(finalModel, update: .all)
        }
    }
    
    func queryConversations() -> [IMSocketConversationSaveItem] {
        RealmProvider.share.aRealm.objects(IMSocketConversationSaveItem.self)
            .sorted(by: \.times, ascending: false)
            .map { $0 }
    }
    
    func queryConversation(from conversationId: String) -> IMSocketConversationSaveItem? {
        RealmProvider.share.aRealm.object(ofType: IMSocketConversationSaveItem.self, forPrimaryKey: conversationId)
    }
    
    func queryMessages(from conversationId: String) -> [IMSocketMessageSaveItem] {
        RealmProvider.share.aRealm.objects(IMSocketMessageSaveItem.self)
            .where { $0.conversationId == conversationId && $0.contentStatus != IMSocketMessageStatusType.DELETE.rawValue }
            .sorted(by: \.times)
            .map { $0 }
    }

    func queryMessage(from messageId: String) -> IMSocketMessageSaveItem? {
        RealmProvider.share.aRealm.objects(IMSocketMessageSaveItem.self)
            .where { $0.messageId == messageId && $0.contentStatus != IMSocketMessageStatusType.DELETE.rawValue }
            .first
    }

    func queryUnreadMessageCount(from imId: String) -> Int {
        queryMessages(from: imId)
            .filter { $0.contentStatus == IMSocketMessageStatusType.UNREAD_DELIVERED.rawValue || $0.contentStatus == IMSocketMessageStatusType.UNREAD_UNDELIVERED.rawValue }
            .count
    }

    func queryAllUnreadMessageCount() -> Int {
        let messages = RealmProvider.share.aRealm.objects(IMSocketMessageSaveItem.self)
            .where { ($0.contentStatus == IMSocketMessageStatusType.UNREAD_DELIVERED.rawValue || $0.contentStatus == IMSocketMessageStatusType.UNREAD_UNDELIVERED.rawValue) && $0.contentStatus != IMSocketMessageStatusType.DELETE.rawValue }
        return messages.count
    }

    func clearAllUnreadMessageCount(from imId: String) {
        let results = RealmProvider.share.aRealm.objects(IMSocketMessageSaveItem.self)
            .where { $0.conversationId == imId && ($0.contentStatus == IMSocketMessageStatusType.UNREAD_DELIVERED.rawValue || $0.contentStatus == IMSocketMessageStatusType.UNREAD_UNDELIVERED.rawValue) }
        var messageIds: [String] = []
        for model in results {
            RealmProvider.share.openTransaction { _ in
                model.contentStatus = IMSocketMessageStatusType.READ.rawValue
            }
            messageIds.append(model.messageId)
        }
        if let conversation = RealmProvider.share.queryConversation(from: imId) {
            RealmProvider.share.openTransaction { _ in
                conversation.unreadCount = 0
            }
        }
        if !messageIds.isEmpty {
            IMChatProvider.sendIMSocket(.READ_CONVERSATION(model: IMSocketConversationReadMessageRequestModel(conversationId: imId, sendId: LoaferAppSettings.UserInfo.user.userId)))
        }
    }
    
    func deleteConversationFrom(conversationId: String) {
        guard let conversation = RealmProvider.share.aRealm.object(ofType: IMSocketConversationSaveItem.self, forPrimaryKey: conversationId) else { return }
        IMChatProvider.sendIMSocket(.DELETE_CONVERSATION(model: IMSocketConversationReadMessageRequestModel(conversationId: conversationId)))
        let messages = queryMessages(from: conversationId)
        openTransaction { rlm in
            rlm.delete(conversation)
            rlm.delete(messages)
        }
    }

    func deleteAll() {
        try! RealmProvider.share.aRealm.write {
            RealmProvider.share.aRealm.deleteAll()
        }
    }
    
}
