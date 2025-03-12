
import UIKit
import KakaJSON

// MARK: - Parse SubType
enum IMSocketParseSubType {
    
    enum HEART: String {
        case HEARTBEAT
    }
    
    enum SYS: String {
        case SYS_MSG
    }
    
    enum CONSUMER {
        
    }
    
    enum USER: String {
        case CHANGE_ONLINE
        case CHANGE_BALANCE
        case LT_ONE_MIN
        case FOLLOW_MSG
    }
    
    enum CHAT: String {
        case MESSAGE
        case CONVERSATION_LIST
        case UNREAD_MESSAGE_LIST
        case DELETE_CONVERSATION
        case DELETE_ALL_CONVERSATION
        case MESSAGE_RSP
        case CREATE_CONVERSATION
    }
    
    enum CALL: String {
        case MATCH_CALL_REQUEST
        case CALL_REQUEST
        case CALL_INVITE
        case CALL_ROOM_INFO
        case CALL_RESPONSE
        case CALL_START_BILLING
        case CALL_END_BILLING
    }
}

// MARK: - Socket Type
enum IMSocketSubType {
    
    enum HEART {
        case HEARTBEAT
    }
    
    enum SYS {
        case SYS_MSG
    }
    
    enum CONSUMER {
        
    }
    
    enum USER {
        case CHANGE_ONLINE(model: IMSocketUSEROnlineStatusResponse)
        case CHANGE_BALANCE
        case LT_ONE_MIN
        case FOLLOW_MSG
    }
    
    enum CHAT {
        case MESSAGE(model: IMSocketMessageItem, user: IMSocketConversationUserInfoItem)
        case CONVERSATION_LIST
        case UNREAD_MESSAGE_LIST(model: IMSocketCHATOfflineMessageModelRequest)
        case DELETE_CONVERSATION(model: IMSocketConversationReadMessageRequestModel)
        case DELETE_ALL_CONVERSATION
        case MESSAGE_RSP
        case READ_CONVERSATION(model: IMSocketConversationReadMessageRequestModel)
    }
    
    enum CALL {
        case MATCH_CALL_REQUEST(model: IMSocketCallRequestModel)
        case CALL_REQUEST(model: IMSocketCallRequestModel)
        case CALL_INVITE
        case CALL_ROOM_INFO
        case CALL_RESPONSE(model: IMSocketCallEndModel)
        case CALL_START_BILLING(model: IMSocketCallStartModel)
        case CALL_END_BILLING(model: IMSocketCallEndModel)
    }
    
}

extension IMSocketSubType.HEART: IMSocketTargetType {
    
    var cmd: Int { 0 }
    
    var type: String { "HEARTBEAT" }
    
    var data: String? {
        var request = IMSocketModel<IMSocketHeartModel>(data: nil)
        request.cmd = cmd
        return request.kj.JSONString()
    }
    
}

extension IMSocketSubType.SYS: IMSocketTargetType {
    
    var cmd: Int { 1000 }
    
    var type: String { "SYS_MSG" }
    
    var data: String? {
        switch self {
            
        default: return nil
        }
    }
    
}

extension IMSocketSubType.CHAT: IMSocketTargetType {
    
    var cmd: Int { 1001 }
    
    var type: String {
        switch self {
        case .MESSAGE:                  return "MESSAGE"
        case .CONVERSATION_LIST:        return "CONVERSATION_LIST"
        case .UNREAD_MESSAGE_LIST:      return "UNREAD_MESSAGE_LIST"
        case .DELETE_CONVERSATION:      return "DELETE_CONVERSATION"
        case .DELETE_ALL_CONVERSATION:  return "DELETE_ALL_CONVERSATION"
        case .MESSAGE_RSP:              return "MESSAGE_RSP"
        case .READ_CONVERSATION:        return "READ_CONVERSATION"
        }
    }
    
    var data: String? {
        switch self {
        case .MESSAGE(let model, let user):
            var request = IMSocketModel<IMSocketMessageItem>()
            request.cmd = cmd
            request.data = IMSocketSecondModel<IMSocketMessageItem>(type: type, data: model)
            RealmProvider.share.addConversation(model: model, receiveUser: user)
            return request.kj.JSONString()
        case .CONVERSATION_LIST:
            var request = IMSocketModel<IMSocketConversationsRequestItem>()
            request.cmd = cmd
            request.data = IMSocketSecondModel<IMSocketConversationsRequestItem>(type: type, data: IMSocketConversationsRequestItem(sendId: LoaferAppSettings.UserInfo.user.userId))
            return request.kj.JSONString()
        case .READ_CONVERSATION(let model):
            var request = IMSocketModel<IMSocketConversationReadMessageRequestModel>()
            request.cmd = cmd
            request.data = IMSocketSecondModel<IMSocketConversationReadMessageRequestModel>(type: type, data: model)
            return request.kj.JSONString()
        case .DELETE_CONVERSATION(let model):
            var request = IMSocketModel<IMSocketConversationReadMessageRequestModel>()
            request.cmd = cmd
            request.data = IMSocketSecondModel<IMSocketConversationReadMessageRequestModel>(type: type, data: model)
            return request.kj.JSONString()
        case .UNREAD_MESSAGE_LIST(let model):
            var request = IMSocketModel<IMSocketCHATOfflineMessageModelRequest>()
            request.cmd = cmd
            request.data = IMSocketSecondModel<IMSocketCHATOfflineMessageModelRequest>(type: type, data: model)
            return request.kj.JSONString()
        default: return nil
        }
    }
    
}

extension IMSocketSubType.CALL: IMSocketTargetType {
    
    var cmd: Int { 1002 }
    
    var type: String {
        switch self {
        case .MATCH_CALL_REQUEST:   return "MATCH_CALL_REQUEST"
        case .CALL_REQUEST:         return "CALL_REQUEST"
        case .CALL_INVITE:          return "CALL_INVITE"
        case .CALL_ROOM_INFO:       return "CALL_ROOM_INFO"
        case .CALL_RESPONSE:        return "CALL_RESPONSE"
        case .CALL_START_BILLING:   return "CALL_START_BILLING"
        case .CALL_END_BILLING:     return "CALL_END_BILLING"
        }
    }
    
    var data: String? {
        switch self {
        case .MATCH_CALL_REQUEST(let model):
            var request = IMSocketModel<IMSocketCallRequestModel>()
            request.cmd = cmd
            request.data = IMSocketSecondModel<IMSocketCallRequestModel>(type: type, data: model)
            return request.kj.JSONString()
        case .CALL_REQUEST(let model):
            var request = IMSocketModel<IMSocketCallRequestModel>()
            request.cmd = cmd
            request.data = IMSocketSecondModel<IMSocketCallRequestModel>(type: type, data: model)
            return request.kj.JSONString()
        case .CALL_START_BILLING(let model):
            var request = IMSocketModel<IMSocketCallStartModel>()
            request.cmd = cmd
            request.data = IMSocketSecondModel<IMSocketCallStartModel>(type: type, data: model)
            return request.kj.JSONString()
        case .CALL_END_BILLING(let model):
            var request = IMSocketModel<IMSocketCallEndModel>()
            request.cmd = cmd
            request.data = IMSocketSecondModel<IMSocketCallEndModel>(type: type, data: model)
            return request.kj.JSONString()
        case .CALL_RESPONSE(let model):
            var request = IMSocketModel<IMSocketCallEndModel>()
            request.cmd = cmd
            request.data = IMSocketSecondModel<IMSocketCallEndModel>(type: type, data: model)
            return request.kj.JSONString()
        default: return nil
        }
    }
    
}

extension IMSocketSubType.CONSUMER: IMSocketTargetType {
    
    var cmd: Int { 1003 }
    
    var type: String { "CONSUMER" }
    
    var data: String? {
        switch self {
            
        default: return nil
        }
    }
    
}

extension IMSocketSubType.USER: IMSocketTargetType {
    
    var cmd: Int { 1004 }
    
    var type: String {
        switch self {
        case .CHANGE_ONLINE:    return "CHANGE_ONLINE"
        case .CHANGE_BALANCE:   return "CHANGE_BALANCE"
        case .LT_ONE_MIN:       return "LT_ONE_MIN"
        case .FOLLOW_MSG:       return "FOLLOW_MSG"
        }
    }
    
    var data: String? {
        switch self {
        case .CHANGE_ONLINE(let model):
            var request = IMSocketModel<IMSocketUSEROnlineStatusResponse>()
            request.cmd = cmd
            request.data = IMSocketSecondModel<IMSocketUSEROnlineStatusResponse>(type: type, data: model)
            return request.kj.JSONString()
        default: return nil
        }
    }
    
}

public protocol IMSocketTargetType {
    
    var cmd: Int { get }
    
    var type: String { get }
    
    var data: String? { get }
    
}
