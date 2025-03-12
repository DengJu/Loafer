
import Starscream
import UIKit
import KakaJSON
import RealmSwift

class IMSocket {
    var webSocket: WebSocket?
    var disConnectCode: UInt16 = 0
    var isConnect: Bool = false

    public static let share = IMSocket()
}

extension IMSocket: WebSocketDelegate {
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case let .connected(headers):
            debugPrint(headers)
            IMSocket.share.isConnect = true
            IMHeartProvider.sendIMSocket(.HEARTBEAT)
            IMChatProvider.sendIMSocket(.UNREAD_MESSAGE_LIST(model: IMSocketCHATOfflineMessageModelRequest()))
            IMUserProvider.sendIMSocket(.CHANGE_ONLINE(model: IMSocketUSEROnlineStatusResponse(onlineStatus: "ONLINE", sendId: LoaferAppSettings.UserInfo.user.userId)))
        case let .disconnected(reason, code):
            debugPrint(reason)
            debugPrint(code)
            IMSocket.share.isConnect = false
        case let .text(string):
            debugPrint(string)
            IMSocketParseContentProvider.parseIMSocket(string)
        case .cancelled:
            IMSocket.share.isConnect = false
        case let .error(error):
            debugPrint(error)
            IMSocket.share.isConnect = false
            if IMSocket.share.disConnectCode == 13074 || IMSocket.share.disConnectCode == 13075 { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                IMSocket.share.connect()
            }
        case .reconnectSuggested:
            IMSocket.share.isConnect = false
            if UIApplication.shared.applicationState == .active {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    IMSocket.share.connect()
                }
            }
        case .peerClosed:
            IMSocket.share.isConnect = false
            if UIApplication.shared.applicationState == .active {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    IMSocket.share.connect()
                }
            }
        default: break
        }
    }

    func connect() {
        if IMSocket.share.isConnect { return }
        guard let url = URL(string: LoaferAppSettings.Config.DEF_IM_SOCKET_URL), !LoaferAppSettings.Config.TOKEN.isEmpty else { return }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["token": LoaferAppSettings.Config.TOKEN, "packageName": LoaferAppSettings.LaunchOptions.Package, "packageVersion": LoaferAppSettings.URLSettings.VERSION]
        request.timeoutInterval = 5
        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }
    
    func disConnect(_ errorCode: UInt16 = 0) {
        IMSocket.share.isConnect = false
        IMSocket.share.disConnectCode = errorCode
        IMSocket.share.webSocket?.forceDisconnect()
    }
    
}

// MARK: - Socket Enum

enum IMSocketSendType: Int {
    case HEART
    case MSG
    case RECEIPT
    case ONREAD
    case CONVERSATION
    case CONVERSATIONS
    case POPUP
    case NEW_MESSAGE
}

// MARK: - Chat Enum

enum IMSocketMessageStatusType: String {
    case UNREAD_UNDELIVERED
    case UNREAD_DELIVERED
    case READ
    case DELETE
}

enum IMSocketMessageBodyType: String {
    case TEXT
    case IMAGE
    case VIDEO
    case VOICE
    case CUSTOM
    case CMD
    case GIFT
    case CALLEVENT
}

enum CallStatusType: String {
    case create
    case answer
    case calling
    case refuse
    case callDone
    case callTimeoutDone
    case callErrorDone
    case callingErrorDone
    case notBalanceDone
    case cancelCall
}
