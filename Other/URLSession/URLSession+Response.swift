
import Foundation
import KakaJSON

struct SessionResponse<Element>: Convertible {
    let data: Element? = nil
    let msg: String = ""
    let code: Int = 0
}

struct SessionResponseInit: Convertible {
    var createTime: Int64 = 0
    var configs: SessionResponseInitConfigModel = SessionResponseInitConfigModel()
    var dict: [SessionResponseInitDict] = []
    
    func kj_didConvertToModel(from json: [String : Any]) {
        LoaferAppSettings.Config.config = configs
        LoaferAppSettings.Config.dicts = dict
    }
}

struct SessionResponseInitDict: Convertible {
    var createTime: Int64 = 0
    var dictType: String = ""
    var dictItems: [SessionResponseInitDictItems] = []
}

struct SessionResponseInitDictItems: Convertible {
    let value: Int32 = 0
    let label: String = ""
    let icon: String = ""
}

struct SessionResponseInitConfigModel: Convertible {
    let DEF_OPERATIONAL_STATUS: Int = 0
    let DEF_URL_USER_AGREEMENT: String = ""
    let DEF_URL_PRIVACY_AGREEMENT: String = ""
    let DEF_AGORA_APP_ID: String = ""
    let DEF_IM_SOCKET_URL: String = ""
    let DEF_SDK_RES_COUNTRY_JSON: String = ""
    let SEND_MESSAGE_COINS: Int = 0
    let SEND_MSG_FREE_NUM: Int = 0
    let CALL_OLD_TIME_SHOW_GIFT: Int = 0
    let NEW_USER_RECHARGE_COUNTDOWN: Int64 = 0
    let NEED_LOG_EVENT: Int = 0
    let DEF_PREMIUM_BENEFITS: String = ""
    let DEF_SUBSCRIBE_BACKGROUD_IMG: String = ""
    let NewuserResource: String = ""
    let LoginResource: String = ""
    let POPUP_TYPE: Int = 0
    let MATCH_ANCHOR_COIN: Int32 = 0
    let MATCH_FREE_CALL_TIME: Int32 = 0
    
    func kj_didConvertToModel(from json: [String : Any]) {
        LoaferAppSettings.Config.OPERATIONALSTATUS = DEF_OPERATIONAL_STATUS == 1
        LoaferAppSettings.Config.TERMSOFUSE = DEF_URL_USER_AGREEMENT
        LoaferAppSettings.Config.PRIVACYPOLICY = DEF_URL_PRIVACY_AGREEMENT
        LoaferAppSettings.Config.DEF_AGORA_APP_ID = DEF_AGORA_APP_ID
        LoaferAppSettings.Config.DEF_IM_SOCKET_URL = DEF_IM_SOCKET_URL
        LoaferAppSettings.Match.time = MATCH_FREE_CALL_TIME
        LoaferAppSettings.Match.price = MATCH_ANCHOR_COIN
        if let jsonString = json["DEF_PREMIUM_BENEFITS"] as? String {
            if let data = jsonString.data(using: .utf8) {
                do {
                    let stringArray = try JSONDecoder().decode([String].self, from: data)
                    LoaferAppSettings.Gems.vipBenefits = stringArray
                } catch {
                    print("解析错误: \(error.localizedDescription)")
                }
            }
        }
    }
    
}

struct SessionResponseHostListModel: Convertible {
    var userId: Int64 = 0
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
    var callPrice: Int32 = 0
    var followStatus: Int32 = 0
    var blackStatus: Int32 = 0
    var anchorCategory: Int32 = 0
    var userTags: [SessionResponseHostTagModel] = []
    var commentTags: [SessionResponseHostCommonModel] = []
    var userPictures: [SessionResponseHostPictureModel] = []
    var videos: [SessionResponseHostVideoModel] = []
}

struct SessionResponseHostVideoModel: Convertible {
    var createTime: Int64 = 0
    var videoId: Int64 = 0
    var duration: Int64 = 0
    var coin: Int32 = 0
    var likeNum: Int32 = 0
    var cover: String = ""
    var videoUrl: String = ""
    var introduction: String = ""
    var isPay: Bool = false
    var isLike: Bool = false
}

struct SessionResponseHostTagModel: Convertible {
    let dictType: String = ""
    let dictValue: Int32 = 0
    let dictLabel: String = ""
}

struct SessionResponseHostCommonModel: Convertible {
    let type: String = ""
    let typeValue: Int32 = 0
    let num: Int32 = 0
}

struct SessionResponseHostPictureModel: Convertible {
    var url: String = ""
    var cover: Bool = false
    var type: Int32 = 0
}

struct SessionResponseUserInfoModel: Convertible {
    var userId: Int64 = 0
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
    var isChangeInfo: Bool = false
    var token: String = ""
    var rtmToken: String = ""
    var isRecharge: Bool = false
    var coinBalance: Int32 = 0
    var age: Int32 = 0
    var createTime: Int64 = 0
    var callNum: Int64 = 0
    var freeMessageRemaining: Int64 = 0
    var vipLevel: Int32 = 0
    var vipCategory: Int32 = 0
    var hasSubscribed: Bool = false
    var renewTime: Int64 = 0
    
    func kj_didConvertToModel(from json: [String : Any]) {
        if !token.isEmpty {
            LoaferAppSettings.Config.TOKEN = token
        }
        LoaferAppSettings.UserInfo.user = self
        if token.count > 0 {
            IMSocket.share.connect()
        }
    }
}

struct SessionResponseGemsListModel: Convertible {
    var productCode: String = ""
    var price: Double = 0.0
    var originalPrice: Double = 0.0
    var totalCoin: Int32 = 0
    var originalCoin: Int32 = 0
    var extraCoin: Int32 = 0
    var words: String = ""
    var rechargeCount: Int32 = 0
    var isRecommend: Bool = false
    var activityType: Int32 = 0
    var ifSubscribe: Bool = false
    var vipLevel: Int32 = 0
    var vipCategory: Int32 = 0
    var intros: String = ""
    var vipName: String = ""
}

struct SessionResponseRegionModel: Convertible {
    var Regions: [SessionResponseRegionKeyModel] = []
}

struct SessionResponseRegionKeyModel: Convertible {
    var code: String = ""
    var emoji: String = ""
    var iso: String = ""
    var name: String = ""
}

struct SessionResponseCommonStringModel: Convertible {
    let string: String = ""
}

struct SessionResponseUploadFileModel: Convertible {
    let url: String = ""
    let preUrl: String = ""
    let fileName: String = ""
    let contentType: String = ""
}

struct SessionResponseTransactionResponse: Convertible {
    var coin: Int32 = 0
    var totalCoin: Int32 = 0
    var selfMobilityType: Int32 = 0
}

struct SessionResponsePonyModel: Convertible {
    var id: Int64 = 0
    var giftNo: String = ""
    var coin: Int32 = 0
    var name: String = ""
    var image: String = ""
    var svg: String = ""
}

struct SessionResponseBannerModel: Convertible {
    var id: Int32 = 0
    var cover: String = ""
    var url: String = ""
}
