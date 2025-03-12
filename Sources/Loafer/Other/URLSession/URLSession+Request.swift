
import Foundation
import KakaJSON

struct SessionRequestInitModel: Convertible {
    
    var configs: [String]? = ["CALL_OLD_TIME_SHOW_GIFT", "SEND_MSG_FREE_NUM", "SEND_MESSAGE_COINS", "NEW_USER_RECHARGE_COUNTDOWN", "NEED_LOG_EVENT", "DEF_PREMIUM_BENEFITS", "DEF_SUBSCRIBE_BACKGROUD_IMG", "LoginResource", "NewuserResource", "POPUP_TYPE", "MATCH_ANCHOR_COIN", "MATCH_FREE_CALL_TIME"]
    
    var dictTypes: [String] = []
    
}

struct SessionRequestHostListModel: Convertible {
    var page: Int = 1
    var size: Int = 100
    var type: String = "HOT"
}

struct SessionRequestLoginModel: Convertible {
    var type: String = "IOS"
    var loginNo: String = ""
    var password: String = ""
    var deviceCode: String = LoaferAppSettings.Config.DEVICEID
    var invitationCode: String = ""
}

struct SessionRequestEditInfoModel: Convertible {
    var avatar: String?
    var nickname: String?
    var birthday: String?
    var signature: String?
    var gender: Int32?
    var country: Int32?
}

struct SessionRequestFollowListModel: Convertible {
    var page: Int32 = 0
    var size: Int32 = 0
    var follow: Bool = true
}

struct SessionRequestBlockModel: Convertible {
    var page: Int32 = 1
    var size: Int32 = 12
}

struct SessionRequestFollowModel: Convertible {
    var followUserId: Int64 = 0
    var follow: Bool = true
}

struct SessionRequestBlockStatusModel: Convertible {
    var blackUserId: Int64 = 0
    var black: Bool = true
}

struct SessionRequestReportModel: Convertible {
    var reportType: Int32 = 0
    var reportedId: Int64 = 0
    var reportedType: String = "USER_INFO"
}

struct SessionRequestHostDetailModel: Convertible {
    var userId: Int64 = 0
}

struct SessionRequestRecommondHostModel: Convertible {
    var page: Int32 = 1
    var size: Int32 = 12
}

struct SessionRequestFeedbackModel: Convertible {
    var feedbackType: Int32 = Int32(LoaferAppSettings.Config.feedbackDicts.first?.value ?? 0)
    var reason: String = ""
    var contactEmail: String = "loafer@gmail.com"
    var imgUrl: String = ""
}

struct SessionRequestDeleteAccountModel: Convertible {
    var reason: Int32 = 0
    var desc: String = ""
}

enum RequestUploadFileType: String {
    case user
    case video
    case picture
    case other
}

struct SessionRequestUploadFileModel: Convertible {
    var type: String = RequestUploadFileType.picture.rawValue
    var fileName: String = ""
    var contentLength: Int64 = 0
}

struct SessionRequestVerifyDataModel: Convertible {
    var signedPayload: String = ""
    var transactionId: String = ""
    var originalTransactionId: String = ""
}

struct SessionRequestTranslateModel: Convertible {
    var conversationId: String = ""
    var messageId: String = ""
    var from_lang: String = ""
    var to_lang: String = ""
    var content: String = ""
    var translateResult: String = ""
}

struct SessionRequestSendPonyModel: Convertible {
    var userId: Int64 = LoaferAppSettings.UserInfo.user.userId
    var giftId: Int = 0
}
struct SessionRequestLikeVideoModel: Convertible {
    var videoId: Int64 = 0
}

struct SessionRequestBuyVideoModel: Convertible {
    var videoId: Int64 = 0
}

struct SessionRequestTranslationModel: Convertible {
    var conversationId: String?
    var messageId: String?
    var from_lang: String = "en-US"
    var to_lang: String = ""
    var content: String = ""
    var translateResult: String?
}

struct SessionRequestQueryBannerModel: Convertible {
    var position: String = "message_list_page"
    var showType: String = "BANNER"
}
