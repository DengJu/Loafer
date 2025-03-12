
import UIKit
import KakaJSON

struct IMSocketModel<Element>: Convertible {
    var cmd: Int = IMSocketSubType.HEART.HEARTBEAT.cmd
    var code: Int = 0
    var message: String = ""
    var data: IMSocketSecondModel<Element>? = nil
}

struct IMSocketSecondModel<Element>: Convertible {
    var type: String = ""
    var data: Element? = nil
}

struct IMSocketHeartModel: Convertible {
    var type: String = ""
}

// MARK: - Chat Models
struct IMSocketMessageItem: Convertible {
    var id: Int = 0
    var messageId: String = ""
    var sendId: Int64 = 0
    var recvId: Int64 = 0 {
        didSet {
            conversationId = LoaferAppSettings.URLSettings.IMPRE + "\(recvId)&" + "\(LoaferAppSettings.UserInfo.user.userId)"
        }
    }
    var content: String = ""
    var contentType: String = ""
    var contentStatus: String = ""
    var conversationId: String = ""
    var times: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
}

struct IMSocketConversationItem: Convertible {
    var conversationId: String = ""
    var times: Int64 = 0
    var latestMessageType: String = ""
    var unreadCount: Int = 0
    var latestMessageContent: String = ""
    var sendId: Int64 = 0
    var recvId: Int64 = 0
    var userInfo: IMSocketConversationUserInfoItem? = nil
}

struct IMSocketConversationUserInfoItem: Convertible {
    var userId: Int64 = 0
    var avatar: String = ""
    var nickname: String = ""
    var gender: Int = 0
    var onlineStatus: Int = 0
    var signature: String = ""
    var callPrice: Int32 = 0
}

struct IMSocketConversationsRequestItem: Convertible {
    var sendId: Int64 = LoaferAppSettings.UserInfo.user.userId
}

struct IMSocketConversationReadMessageRequestModel: Convertible {
    var conversationId: String = ""
    var sendId: Int64 = LoaferAppSettings.UserInfo.user.userId
}

struct IMSocketMessageRSPModel: Convertible {
    var conversationId: String = ""
    var messageId: String = ""
    var sendSuccess: Bool = true
}

// MARK: - CAll Models
struct IMSocketCallRequestModel: Convertible {
    var sendId: Int64 = LoaferAppSettings.UserInfo.user.userId
    var recvId: Int64 = 0
    var callNo: String = ""
}

struct IMSocketCallResponseModel: Convertible {
    var sendId: Int64 = 0
    var recvId: Int64 = 0
    var callNo: String = ""
    var status: String = ""
}

struct IMSocketCallStartModel: Convertible {
    var sendId: Int64 = LoaferAppSettings.UserInfo.user.userId
    var recvId: Int64 = 0
    var callNo: String = ""
}

struct IMSocketCallEndModel: Convertible {
    var sendId: Int64 = LoaferAppSettings.UserInfo.user.userId
    var recvId: Int64 = 0
    var callNo: String = ""
    var status: String = ""
}

struct IMSocketCallRoomInfoModel: Convertible {
    var callNo: String = ""
    var callPrice: Int = 0
    var payUserId: Int = 0
    var createUserId: Int = 0
    var createUserRtcToken: String = ""
    var toUserId: Int = 0
    var toUserRtcToken: String = ""
    var anchorInfo: IMSocketCallUserInfo = IMSocketCallUserInfo()
    var userInfo: IMSocketCallUserInfo = IMSocketCallUserInfo()
    var createTime: Int = 0
    var callTime: Int = 0
    var status: String = ""
    var callType: String = ""
}

struct IMSocketCallUserInfo: Convertible {
    var userId: Int64 = 0
    var coinBalance: Int = 0
    var avatar: String = ""
    var nickname: String = ""
}

struct IMSocketCallEndResponse: Convertible {
    var callId: String = ""
    var status: String = ""
    var coins: Int = 0
    var callTime: Int64 = 0
    var callTimeRate: Double = 0.0
    var spendCoin: Int = 0
    var anchorInfo: IMSocketCallUserInfo?
    var userInfo: IMSocketCallUserInfo?
}

struct IMSocketCallMatchSuccessResponse: Convertible {
    var callNo: String = ""
    var callPrice: Int32 = 0
    var followStatus: Int32 = 0
    var blackStatus: Int32 = 0
    var avatar: String = ""
    var nickname: String = ""
    var birthday: String = ""
    var signature: String = ""
    var gender: Int32 = 0
    var country: Int32 = 0
    var userCategory: Int32 = 0
    var onlineStatus: Int32 = 0
    var following: Int32 = 0
    var follower: Int32 = 0
    var createTime: Int32 = 0
    var lastLoginTime: Int32 = 0
    var userId: Int64 = 0
}

// MARK: - USER Models

struct IMSocketUSERBalanceChangeResponse: Convertible {
    var coins: Int = 0
}

struct IMSocketUSERFollowResponse: Convertible {
    var follow: Bool = false
    var sendInfo: IMSocketCallUserInfo?
    var receiveInfo: IMSocketCallUserInfo?
    var sendId: Int64 = 0
    var recvId: Int64 = 0
}

struct IMSocketUSEROnlineStatusResponse: Convertible {
    var onlineStatus: String = ""
    var sendId: Int64 = 0
    var recvId: Int64 = 0
}

struct IMSocketCHATOfflineMessageModelRequest: Convertible {
    var sendId: Int64 = LoaferAppSettings.UserInfo.user.userId
}

struct IMSocketMessageCallEventModel: Convertible {
    var time: String = ""
    var type: String = ""
}
