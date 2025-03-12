
import UIKit
@_exported import IQKeyboardManagerSwift
@_exported import SwiftEntryKit
@_exported import KeychainAccess
@_exported import KakaJSON

struct LoaferAppSettings {
    
    struct LaunchOptions {
        
        static var URL: String = ""
        
        static var Package: String = ""
        
    }
    
    enum URLSettings {
        static let TIMEZONE: String = TimeZone.current.identifier.isEmpty ? Calendar.current.timeZone.identifier : TimeZone.current.identifier
        static let IV: String = "VGVUffwsSOUCN8bQ"
        static let PUBLICKEY: String = "0aRFkSXsS4DWdRTmjI8naEHyd6ZqeMOm"
        static let PWDKEY: String = "jaOTcbIMU5pnxoEmBTDGcusJHYvIhICZ"
        static let aKeychain = Keychain(service: "COM.LOAFER.ORG")
        static let IMPRE = "NanYuIm"
        static let INFO = LoaferAppSettings.LaunchOptions.Package + ";" + VERSION
        static let NAME = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
        static let FROM = "iOS"
        static let MODEL: String = UIDevice.modelName
        static let OSVERSION: String = UIDevice.current.systemVersion
        static let VERSION: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "0") as! String
        static var LANGUAGE: String {
            let languages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String]
            return languages?.first ?? "en"
        }
        static var RTIME: String {
            let now = NSDate()
            let timeInterval: TimeInterval = now.timeIntervalSince1970
            return "\(Int(timeInterval))"
        }
        static var REGION: String {
            let locale = Locale.current
            if let countryCode = locale.regionCode { return countryCode }
            return "1"
        }
        static var NET: String = "Not Connected"
        static var RID: String {
            String.arbitrary()
        }
        
        static var isOpenProxy: Bool {
            guard let proxy = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() else { return false }
            guard let dict = proxy as? [String: Any] else { return false }
            let isUsed = dict.isEmpty
            guard !isUsed, let HTTPProxy = dict["HTTPSProxy"] as? String else { return false }
            return !HTTPProxy.isEmpty
        }

        static var isConnectedToVpn: Bool {
            if let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
               let scopes = settings["__SCOPED__"] as? [String: Any]
            {
                for (key, _) in scopes {
                    if key.contains("tap") || key.contains("tun") || key.contains("ppp") || key.contains("ipsec") {
                        return true
                    }
                }
            }
            return false
        }
    }
    
    enum Config {
        static var config = SessionResponseInitConfigModel()
        static var dicts: [SessionResponseInitDict] = []
        static var OPERATIONALSTATUS: Bool = true
        static var TERMSOFUSE: String = "https://www.baidu.com"
        static var PRIVACYPOLICY: String = "https://www.baidu.com"
        static var DEF_AGORA_APP_ID: String = ""
        static var DEF_IM_SOCKET_URL: String = ""
        static var TOKEN: String {
            set {
                UserDefaults.standard.set(newValue, forKey: "APPTOKEN")
                UserDefaults.standard.synchronize()
            }
            get {
                if let token = UserDefaults.standard.object(forKey: "APPTOKEN") as? String {
                    return token
                }
                return ""
            }
        }
        
        static func removeToken() {
            UserDefaults.standard.set(nil, forKey: "APPTOKEN")
            UserDefaults.standard.synchronize()
        }
        
        static var DEVICEID: String {
            guard let token = try? LoaferAppSettings.URLSettings.aKeychain.get("LOAFER.APP.UUID") else {
                guard let value = UIDevice.current.identifierForVendor?.uuidString else { return "" }
                try? LoaferAppSettings.URLSettings.aKeychain.set(value.replacingOccurrences(of: "-", with: ""), key: "LOAFER.APP.UUID")
                return value
            }
            return token
        }
        
        static var feedbackDicts: [SessionResponseInitDictItems] = []
        static var reportDicts: [SessionResponseInitDictItems] = []
    }
    
    enum Match {
        static var time: Int32 = 0
        static var price: Int32 = 0
        static var isMatching: Bool = false
    }
    
    enum Gems {
        
        static var data: [SessionResponseGemsListModel] = [] {
            didSet {
                LoaferAppSettings.Gems.purchaseItems = LoaferAppSettings.Gems.data.filter({ !$0.ifSubscribe })
                LoaferAppSettings.Gems.subscribeItems = LoaferAppSettings.Gems.data.filter({ $0.ifSubscribe })
            }
        }
        
        static var purchaseItems: [SessionResponseGemsListModel] = [] {
            didSet {
                LoaferAppSettings.Gems.avtiveItems = LoaferAppSettings.Gems.purchaseItems.filter({ $0.rechargeCount == 1 && $0.activityType == 1 }).first
                LoaferAppSettings.Gems.limitOnceItems = LoaferAppSettings.Gems.purchaseItems.filter({ $0.rechargeCount == 1 && $0.activityType == 2 }).first
            }
        }
        
        static var subscribeItems: [SessionResponseGemsListModel] = []
        
        static var avtiveItems: SessionResponseGemsListModel?
        static var limitOnceItems: SessionResponseGemsListModel?
        
        static var vipBenefits: [String] = []
        
        static var remainingTime: Int64 {
            get {
                let now = NSDate()
                let timeInterval: TimeInterval = now.timeIntervalSince1970
                let time = LoaferAppSettings.UserInfo.user.createTime + LoaferAppSettings.Config.config.NEW_USER_RECHARGE_COUNTDOWN - Int64(timeInterval)
                return time > 0 ? time : 0
            }
        }
        
        static var isNeedPopup: Bool {
            get {
                return LoaferAppSettings.Gems.avtiveItems != nil && LoaferAppSettings.Gems.remainingTime > 0
            }
        }
        
        static var ponyViewShowString: String {
            get {
                if LoaferAppSettings.Config.config.CALL_OLD_TIME_SHOW_GIFT > 60 {
                    return "\(LoaferAppSettings.Config.config.CALL_OLD_TIME_SHOW_GIFT/60) minutes"
                }else {
                    return "\(LoaferAppSettings.Config.config.CALL_OLD_TIME_SHOW_GIFT) seconds"
                }
            }
        }
    }
    
    enum AOP {
        static var callSource: String = "Default"
        
        static var currentStayInterface: String = ""
        
        static var rechargeSource: String = "Default"
    }
    
    enum Pony {
        static var data: [SessionResponsePonyModel] = [] {
            didSet {
                let urls = data.filter({$0.image.toURL != nil}).map { URL(string: $0.image)! }
                PrefetchsSession.startPrefetchPhoto(urls: urls)
            }
        }
    }
    
    enum UserInfo {
        static var user = SessionResponseUserInfoModel()
        
        static var canSendMessage: Bool {
            get {
                if LoaferAppSettings.UserInfo.user.freeMessageRemaining > 0 {
                    return true
                }else {
                    if LoaferAppSettings.UserInfo.isVIP {
                        return true
                    }else {
//                        PopuoSession.popup(show: SoulSubscribePage(), isFloating: false)
                        return false
                    }
                }
            }
        }
        
        static var isVIP: Bool {
            get {
                LoaferAppSettings.UserInfo.user.vipCategory > 0
            }
        }
        
        static var VIPRemainingTime: Int64 {
            get {
                let now = NSDate()
                let timeInterval: TimeInterval = now.timeIntervalSince1970
                let time = Int64(LoaferAppSettings.UserInfo.user.renewTime/1000) - Int64(timeInterval)
                return time > 0 ? time : 0
            }
        }
        
    }
    
    static func queryCountryInfo(_ code: String) -> (String, String)? {
        guard let bundle = LoaferStorage.queryObject(name: "Region", type: .json) else { return nil }
        do {
            let jsonString = try String(contentsOfFile: bundle.path)
            if let model = model(from: jsonString, SessionResponseRegionModel.self), let data = model.Regions.filter({ $0.code == code }).first {
                return (data.emoji, data.name)
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }

}

import Nuke

struct PrefetchsSession {
    
    static let prefetcher = ImagePrefetcher()
    
    static func startPrefetchPhoto(urls: [URL]) {
        guard !urls.isEmpty else { return }
        prefetcher.isPaused = false
        prefetcher.startPrefetching(with: urls)
    }
    
    static func stopPrefetchPhoto(urls: [URL]) {
        guard !urls.isEmpty else { return }
        prefetcher.isPaused = true
        prefetcher.startPrefetching(with: urls)
    }
    
}
