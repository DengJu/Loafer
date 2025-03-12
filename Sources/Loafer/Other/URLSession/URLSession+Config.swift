import Foundation
import CryptoSwift
import KakaJSON
//import Alamofire

public protocol SessionInterfaceType {
    var sessionURL: String { get }
    var sessionSubpath: String { get }
    var sessionMethod: HTTPMethod { get }
    var sessionContentType: String { get }
    var sessionJSONString: String { get }
    var sessionRequest: URLRequest? { get }
    var sessionIsHideLogButTokenNil: Bool { get }
}

enum SessionTransportFileType {
    public static func == (_: SessionTransportFileType, _: SessionTransportFileType) -> Bool {
        return true
    }

    case imageFile(data: Data)
    case audioFile(fileUrl: URL)
    case videoFile(fileUrl: URL)

    var suffix: String {
        switch self {
        case .imageFile: return "image.jpg"
        case .videoFile: return "video.mp4"
        case .audioFile: return "audio.wav"
        }
    }

    var mimeType: String {
        switch self {
        case .imageFile: return "image/jpg"
        case .audioFile: return "audio/wav"
        case .videoFile: return "video/mp4"
        }
    }
}

enum URLSessionInterface {
    case URLInterfaceDict(model: SessionRequestInitModel)
    case URLInterfaceInit(model: SessionRequestInitModel)
    case URLInterfaceHostList(model: SessionRequestHostListModel)
    case URLInterfaceHiddenLogin
    case URLInterfaceLogin(model: SessionRequestLoginModel)
    case URLInterfaceEditInfo(model: SessionRequestEditInfoModel)
    case URLInterfaceGemsList
    case URLInterfacePonyList
    case URLInterfaceFollowList(model: SessionRequestFollowListModel)
    case URLInterfaceBlockList(model: SessionRequestBlockModel)
    case URLInterfaceFollow(model: SessionRequestFollowModel)
    case URLInterfaceBlock(model: SessionRequestBlockStatusModel)
    case URLInterfaceReport(model: SessionRequestReportModel)
    case URLInterfaceHostDetail(model: SessionRequestHostDetailModel)
    case URLInterfaceRecommondHost(model: SessionRequestRecommondHostModel)
    case URLInterfaceFeedBack(model: SessionRequestFeedbackModel)
    case URLInterfaceDeleteAccount(model: SessionRequestDeleteAccountModel)
    case URLInterfaceUploadFile(model: SessionRequestUploadFileModel)
    case URLInterfaceLogOut
    case URLInterfaceVerifyData(model: SessionRequestVerifyDataModel)
    case URLInterfaceSendPony(model: SessionRequestSendPonyModel)
    case URLInterfaceUnlockVideo(model: SessionRequestBuyVideoModel)
    case URLInterfaceLikeVideo(model: SessionRequestLikeVideoModel)
    case URLInterfaceChekVideo(model: SessionRequestLikeVideoModel)
    case URLInterfaceCallHistory(model: SessionRequestBlockModel)
    case URLInterfaceTranslation(model: SessionRequestTranslationModel)
    case URLInterfaceQueryBanner(model: SessionRequestQueryBannerModel)
}

extension URLSessionInterface: SessionInterfaceType {
    
    var sessionRequest: URLRequest? {
        guard let finalUrl = URL(string: sessionURL + sessionSubpath) else { return nil }
        var request = URLRequest.init(url: finalUrl)
        request.timeoutInterval = 60
        request.httpMethod = sessionMethod.rawValue
        request.setValue(sessionContentType, forHTTPHeaderField: "Content-Type")
        var internalHeader: [String: String] = [:]
        let rid = LoaferAppSettings.URLSettings.RID
        internalHeader["App-Info"] = LoaferAppSettings.URLSettings.INFO
        internalHeader["App-Unsafe"] = "false"
        internalHeader["App-Rid"] = rid
        internalHeader["App-RTime"] = LoaferAppSettings.URLSettings.RTIME
        internalHeader["Authorization"] = LoaferAppSettings.Config.TOKEN
        internalHeader["App-OpenVPN"] = (LoaferAppSettings.URLSettings.isConnectedToVpn || LoaferAppSettings.URLSettings.isOpenProxy) ? "true" : "false"
        internalHeader["App-Language"] = LoaferAppSettings.URLSettings.LANGUAGE
        internalHeader["App-Region"] = LoaferAppSettings.URLSettings.REGION
        internalHeader["App-DeviceId"] = LoaferAppSettings.Config.DEVICEID
        let jsonString = sessionJSONString
        internalHeader["App-Sign"] = (jsonString+rid).md5().uppercased()
        request.allHTTPHeaderFields = internalHeader
        guard let encryptedBytes = try? AES(key: LoaferAppSettings.URLSettings.PUBLICKEY, iv: LoaferAppSettings.URLSettings.IV, padding: .pkcs5).encrypt(jsonString.bytes) else { return request }
        let baseString = encryptedBytes.toBase64()
        request.httpBody = (baseString.data(using: .utf8))! as Data
        return request
    }
    
    var sessionURL: String { LoaferAppSettings.LaunchOptions.URL + "/\(LoaferAppSettings.LaunchOptions.Package)" }
    
    var sessionJSONString: String {
        switch self {
        case .URLInterfaceDict(let model): return JSONString(from: model)
        case .URLInterfaceInit(let model): return JSONString(from: model)
        case .URLInterfaceLogin(let model): return JSONString(from: model)
        case .URLInterfaceEditInfo(let model): return JSONString(from: model)
        case .URLInterfaceHostList(let model): return JSONString(from: model)
        case .URLInterfaceFollowList(let model): return JSONString(from: model)
        case .URLInterfaceBlockList(let model): return JSONString(from: model)
        case .URLInterfaceFollow(let model): return JSONString(from: model)
        case .URLInterfaceBlock(let model): return JSONString(from: model)
        case .URLInterfaceReport(let model): return JSONString(from: model)
        case .URLInterfaceHostDetail(let model): return JSONString(from: model)
        case .URLInterfaceRecommondHost(let model): return JSONString(from: model)
        case .URLInterfaceFeedBack(let model): return JSONString(from: model)
        case .URLInterfaceDeleteAccount(let model): return JSONString(from: model)
        case .URLInterfaceUploadFile(let model): return JSONString(from: model)
        case .URLInterfaceVerifyData(let model): return JSONString(from: model)
        case .URLInterfaceSendPony(let model): return JSONString(from: model)
        case .URLInterfaceUnlockVideo(let model): return JSONString(from: model)
        case .URLInterfaceLikeVideo(let model): return JSONString(from: model)
        case .URLInterfaceChekVideo(let model): return JSONString(from: model)
        case .URLInterfaceCallHistory(let model): return JSONString(from: model)
        case .URLInterfaceTranslation(let model): return JSONString(from: model)
        case .URLInterfaceQueryBanner(let model): return JSONString(from: model)
        default: return ""
        }
    }
    
    var sessionSubpath: String {
        switch self {
        case .URLInterfaceDict: return "/init/getDict"
        case .URLInterfaceInit: return "/init/getConfig"
        case .URLInterfaceHostList: return "/anchor/getDetailList"
        case .URLInterfaceHiddenLogin: return "/authorize/stealthLogin"
        case .URLInterfaceLogin: return "/authorize/login"
        case .URLInterfaceEditInfo: return "/user/setInfo"
        case .URLInterfaceGemsList: return "/rechargeConsume/getRechargeList"
        case .URLInterfacePonyList: return "/rechargeConsume/getGiftList"
        case .URLInterfaceFollowList: return "/userStatus/getFollowList"
        case .URLInterfaceBlockList: return "/userStatus/getBlackList"
        case .URLInterfaceFollow: return "/userStatus/followStatus"
        case .URLInterfaceBlock: return "/userStatus/blackStatus"
        case .URLInterfaceReport: return "/user/reportUser"
        case .URLInterfaceHostDetail: return "/anchor/getInfo"
        case .URLInterfaceRecommondHost: return "/anchor/recommendAnchor"
        case .URLInterfaceFeedBack: return "/user/feedback"
        case .URLInterfaceDeleteAccount: return "/user/delUser"
        case .URLInterfaceUploadFile: return "/system/getPutFileUrl"
        case .URLInterfaceLogOut: return "/authorize/loginOut"
        case .URLInterfaceVerifyData: return "/rechargeConsume/callBack/iosSuccess"
        case .URLInterfaceSendPony: return "/rechargeConsume/sendGift"
        case .URLInterfaceUnlockVideo: return "/video/purchase"
        case .URLInterfaceLikeVideo: return "/video/likeVideo"
        case .URLInterfaceChekVideo: return "/video/getVideoById"
        case .URLInterfaceCallHistory: return "/call/getCallHistory"
        case .URLInterfaceTranslation: return "/ai/translate"
        case .URLInterfaceQueryBanner: return "/system/getBanner"
        }
    }
    
    var sessionIsHideLogButTokenNil: Bool {
        switch self {
        case .URLInterfaceHiddenLogin: return LoaferAppSettings.Config.TOKEN.isEmpty
        default: return false
        }
    }
    
    var sessionMethod: HTTPMethod { .post }
    
    var sessionContentType: String { "application/json" }
    
}
