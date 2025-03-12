
import UIKit
import KakaJSON
import RealmSwift
import PromiseKit
import AVFoundation

public protocol IMSocketProviderType {
    associatedtype Target: IMSocketTargetType

    func sendIMSocket(_ target: Target)
    
}

let IMChatProvider = IMSocketProvider<IMSocketSubType.CHAT>()
let IMCallProvider = IMSocketProvider<IMSocketSubType.CALL>()
let IMConsumerProvider = IMSocketProvider<IMSocketSubType.CONSUMER>()
let IMHeartProvider = IMSocketProvider<IMSocketSubType.HEART>()
let IMSYSProvider = IMSocketProvider<IMSocketSubType.SYS>()
let IMUserProvider = IMSocketProvider<IMSocketSubType.USER>()

class IMSocketProvider<Command: IMSocketTargetType>: IMSocketProviderType {
    
    typealias Target = Command
    
    func sendIMSocket(_ target: Command) {
        guard let content = target.data else { return }
        IMSocket.share.webSocket?.write(string: content)
    }
    
}

struct IMSocketParseContentProvider {
    
    enum IMSocketParseType: Int {
        case HEARTBEAT = 0
        case SYS_MSG = 1000
        case CHAT = 1001
        case CALL = 1002
        case CONSUMER = 1003
        case USER = 1004
    }
    
    static func parseIMSocket(_ content: String) {
        guard let model = model(from: content, IMSocketModel<Any>.self) else { return }
        guard model.code == 200 else {
            ToastTool.show(.failure, model.message)
            if model.code == 1005 {
                InsufficientPolicy.insufficientPop(type: .default)
            }
            return
        }
        if model.cmd == IMSocketParseType.HEARTBEAT.rawValue {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                IMHeartProvider.sendIMSocket(.HEARTBEAT)
            }
        }else if model.cmd == IMSocketParseType.SYS_MSG.rawValue {
            
        }else if model.cmd == IMSocketParseType.CHAT.rawValue {
            parseCHATSocket(content: content)
        }else if model.cmd == IMSocketParseType.CALL.rawValue {
            parseCALLSocket(content: content)
        }else if model.cmd == IMSocketParseType.CONSUMER.rawValue {
            
        }else if model.cmd == IMSocketParseType.USER.rawValue {
            parseUSERSocket(content: content)
        }
    }
    
    static func parseUSERSocket(content: String) {
        guard let socketModel = model(from: content, IMSocketModel<Any>.self), let type = socketModel.data?.type else { return }
        if type == IMSocketParseSubType.USER.LT_ONE_MIN.rawValue {
            if let roomModel = model(from: content, IMSocketModel<String>.self), let callNo = roomModel.data?.data {
                RealmProvider.share.openTransaction { realm in
                    if let callModel = realm.object(ofType: CallRoomInfoModel.self, forPrimaryKey: callNo) {
                        callModel.balanceInsufficient = true
                    }
                }
            }
        }else if type == IMSocketParseSubType.USER.CHANGE_BALANCE.rawValue {
            if let roomModel = model(from: content, IMSocketModel<IMSocketUSERBalanceChangeResponse>.self), let model = roomModel.data?.data {
                LoaferAppSettings.UserInfo.user.coinBalance = Int32(model.coins)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESH-USER-BALANCE"), object: model.coins)
            }
        }else if type == IMSocketParseSubType.USER.FOLLOW_MSG.rawValue {
//            if let roomModel = model(from: content, IMSocketModel<IMSocketUSERFollowResponse>.self), let model = roomModel.data?.data {
//                
//            }
        }else if type == IMSocketParseSubType.USER.CHANGE_ONLINE.rawValue {
//            if let roomModel = model(from: content, IMSocketModel<IMSocketUSEROnlineStatusResponse>.self), let model = roomModel.data?.data {
//                
//            }
        }
    }
    
    static func parseCHATSocket(content: String) {
        guard let socketModel = model(from: content, IMSocketModel<Any>.self), let type = socketModel.data?.type else { return }
        if type == IMSocketParseSubType.CHAT.MESSAGE.rawValue {
            if let messageModel = model(from: content, IMSocketModel<IMSocketMessageItem>.self), let message = messageModel.data?.data {
                RealmProvider.share.addMessage(model: message)
            }
        }else if type == IMSocketParseSubType.CHAT.CONVERSATION_LIST.rawValue {
            if let array = model(from: content, IMSocketModel<[IMSocketConversationItem]>.self), let conversations = array.data?.data {
                conversations.forEach {
                    RealmProvider.share.addConversation(jsonModel: $0)
                }
                if conversations.isEmpty {
                    NotificationCenter.default.post(name: NSNotification.Name("ConversationListEmptyNoty"), object: nil)
                }
            }
        }else if type == IMSocketParseSubType.CHAT.CREATE_CONVERSATION.rawValue {
            if let array = model(from: content, IMSocketModel<IMSocketConversationItem>.self), let conversation = array.data?.data {
                RealmProvider.share.addConversation(jsonModel: conversation)
            }
        }else if type == IMSocketParseSubType.CHAT.UNREAD_MESSAGE_LIST.rawValue {
            if let array = model(from: content, IMSocketModel<[IMSocketMessageItem]>.self), let unreadMessages = array.data?.data {
                unreadMessages.forEach {
                    RealmProvider.share.addMessage(model: $0)
                }
            }
        }else if type == IMSocketParseSubType.CHAT.MESSAGE_RSP.rawValue {
            if let model = model(from: content, IMSocketModel<IMSocketMessageRSPModel>.self), let data = model.data?.data, let message = RealmProvider.share.queryMessage(from: data.messageId) {
                RealmProvider.share.openTransaction { _ in
                    message.contentStatus = IMSocketMessageStatusType.READ.rawValue
                }
            }
        }
        if let page = UIApplication.mainWindow.rootViewController as? LoaferTabBarPage {
            page.refreshUnreadCount()
        }
    }
    
    static func parseCALLSocket(content: String) {
        guard let socketModel = model(from: content, IMSocketModel<Any>.self), let type = socketModel.data?.type else { return }
        if type == IMSocketParseSubType.CALL.CALL_INVITE.rawValue {
            if let roomModel = model(from: content, IMSocketModel<IMSocketCallRoomInfoModel>.self), let model = roomModel.data?.data {
                if let currentPresentedPage = UIApplication.mainWindow.rootViewController?.presentedViewController {
                    currentPresentedPage.dismiss(animated: true)
                }
                let saveModel = CallRoomInfoModel()
                saveModel.callNo = model.callNo
                saveModel.callPrice = model.callPrice
                saveModel.payUserId = model.payUserId
                saveModel.createUserId = model.createUserId
                saveModel.createUserRtcToken = model.createUserRtcToken
                saveModel.toUserId = model.toUserId
                saveModel.toUserRtcToken = model.toUserRtcToken
                saveModel.anchorInfo = model.anchorInfo.kj.JSONString()
                saveModel.userInfo = model.userInfo.kj.JSONString()
                saveModel.createTime = model.createTime
                saveModel.callTime = model.callTime
                saveModel.status = model.status
                saveModel.callType = "incoming"
                RealmProvider.share.openTransaction { realm in
                    realm.add(saveModel)
                }
                PopUtil.dismissAll()
                let page = VideoCallPage()
                page.isCaller = false
                page.setSourceData(saveModel)
                UIApplication.mainWindow.rootViewController?.present(page, animated: true) {
                    ToastTool.dismiss()
//                    VoiceSession.playSound(voiceName: "CallingVoice")
                }
            }else {
                ToastTool.dismiss()
            }
        }else if type == IMSocketParseSubType.CALL.CALL_RESPONSE.rawValue {
            if let roomModel = model(from: content, IMSocketModel<IMSocketCallResponseModel>.self), let model = roomModel.data?.data {
                RealmProvider.share.openTransaction { realm in
                    if let callModel = realm.object(ofType: CallRoomInfoModel.self, forPrimaryKey: model.callNo) {
                        callModel.status = model.status
                    }
                }
            }
        }else if type == IMSocketParseSubType.CALL.CALL_ROOM_INFO.rawValue {
            if let roomModel = model(from: content, IMSocketModel<IMSocketCallRoomInfoModel>.self), let model = roomModel.data?.data {
                if let currentPresentedPage = UIApplication.mainWindow.rootViewController?.presentedViewController {
                    currentPresentedPage.dismiss(animated: true)
                }
                let saveModel = CallRoomInfoModel()
                saveModel.callNo = model.callNo
                saveModel.callPrice = model.callPrice
                saveModel.payUserId = model.payUserId
                saveModel.createUserId = model.createUserId
                saveModel.createUserRtcToken = model.createUserRtcToken
                saveModel.toUserId = model.toUserId
                saveModel.toUserRtcToken = model.toUserRtcToken
                saveModel.anchorInfo = model.anchorInfo.kj.JSONString()
                saveModel.userInfo = model.userInfo.kj.JSONString()
                saveModel.createTime = model.createTime
                saveModel.callTime = model.callTime
                saveModel.status = model.status
                saveModel.callType = model.callType
                RealmProvider.share.openTransaction { realm in
                    realm.add(saveModel)
                }
                PopUtil.dismissAll()
                let page = VideoCallPage()
                page.isCaller = true
                page.setSourceData(saveModel)
                UIApplication.mainWindow.rootViewController?.present(page, animated: true) {
                    ToastTool.dismiss()
//                    VoiceSession.playSound(voiceName: "CallingVoice")
                }
            }else {
                ToastTool.dismiss()
            }
        }else if type == IMSocketParseSubType.CALL.CALL_END_BILLING.rawValue {
            if let roomModel = model(from: content, IMSocketModel<IMSocketCallEndResponse>.self), let model = roomModel.data?.data {
                RealmProvider.share.openTransaction { realm in
                    if let callModel = realm.object(ofType: CallRoomInfoModel.self, forPrimaryKey: model.callId) {
                        callModel.status = model.status
                        callModel.callTime = Int(model.callTime)
                    }
                }
            }
        }else if type == IMSocketParseSubType.CALL.MATCH_CALL_REQUEST.rawValue {
            if !LoaferAppSettings.Match.isMatching {
                return
            }
            if let roomModel = model(from: content, IMSocketModel<IMSocketCallMatchSuccessResponse>.self), let model = roomModel.data?.data {
                let successView = MatchSuccessPage()
                successView.setSourceData(model)
                PopUtil.pop(show: successView)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MATCH_SUCCESS"), object: model)
            }else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MATCH_EMPTY_NOTIFICATION"), object: nil)
            }
        }
    }
    
}
