
import RealmSwift
import KakaJSON

//MARK: - Realm
class IMSocketMessageSaveItem: Object  {
    @Persisted(primaryKey: true) var messageId: String = ""
    @Persisted var sendId: Int64 = 0
    @Persisted var recvId: Int64 = 0
    @Persisted var content: String = ""
    @Persisted var contentType: String = ""
    @Persisted var contentStatus: String = ""
    @Persisted var conversationId: String = ""
    @Persisted(indexed: true) var times: Int64 = 0
}

class IMSocketConversationSaveItem: Object {
    @Persisted(primaryKey: true) var conversationId: String = ""
    @Persisted(indexed: true) var times: Int64 = 0
    @Persisted var latestMessageType: String = ""
    @Persisted var unreadCount: Int = 0
    @Persisted var latestMessageContent: String = ""
    @Persisted var sendId: Int64 = 0
    @Persisted var recvId: Int64 = 0
    @Persisted var userInfo: String = ""
    @Persisted var isBlock: Bool = false
    
    var anchorModel: IMSocketConversationUserInfoItem? {
        guard let model = model(from: userInfo, IMSocketConversationUserInfoItem.self) else { return nil }
        return model
    }
}

class ReserveModel: Object {
    @Persisted(primaryKey: true) var time: Int64 = 0
    @Persisted var userId: Int64 = 0
    @Persisted var nickName: String = ""
    @Persisted var tag: String = ""
    @Persisted var desc: String = ""
    @Persisted var avatar: String = ""
}


class CallRoomInfoModel: Object {
    @Persisted(primaryKey: true) var callNo: String = ""
    @Persisted var callPrice: Int = 0
    @Persisted var payUserId: Int = 0
    @Persisted var createUserId: Int = 0
    @Persisted var createUserRtcToken: String = ""
    @Persisted var toUserId: Int = 0
    @Persisted var toUserRtcToken: String = ""
    @Persisted var anchorInfo: String = ""
    @Persisted var userInfo: String = ""
    @Persisted var createTime: Int = 0
    @Persisted var callTime: Int = 0
    @Persisted var status: String = ""
    @Persisted var callType: String = ""
    @Persisted var balanceInsufficient: Bool = false
    
    var anchorModel: IMSocketCallUserInfo? {
        return model(from: anchorInfo, IMSocketCallUserInfo.self)
    }
    
    var userModel: IMSocketCallUserInfo? {
        return model(from: userInfo, IMSocketCallUserInfo.self)
    }
    
}
