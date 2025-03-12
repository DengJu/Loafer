
import UIKit
import Lottie

protocol CallPreViewDelegate {
    func refuseCall()
    func agreeCall()
    func cancelCall()
}

class CallPreView: UIView, SourceProtocol {
    
    enum CallPreviewType {
        case Calling
        case Incoming
        case Match
        
        var connectDesc: String {
            switch self {
            case .Incoming:
                "Incoming call..."
            default:
                "Connecting..."
            }
        }
        
        var desc: [String] {
            switch self {
            case .Incoming:
                [
                    "",
                    "I just took a shower 🛀. Shall we chat?",
                    "Don't rush to answer, I'm not dressed yet👙👙",
                    "What kind of performance do you like? You can tell me on the call.",
                    "I'm a little hot right now and I need a fireman or you🔥🔥🔥"
                ]
            default:
                [
                    "",
                    "Please say hello politely during the call 😊",
                    "Compliment each other to gain more favor 😍",
                    "Giving gifts can take relationships further 😈",
                    "Get ready for a call ☎️"
                ]
            }
        }
    }
    
    private let backImageView = UIImageView(image: "Basic.Placeholder".toImage)
    private let animationView = LottieAnimationView(filePath: "CallPreAnimation".toAnimationPath)
    private let iconView = UIImageView(image: "Basic.Placeholder.Squre".toImage)
    private let nameView = UILabel()
    private let callPriceBtn = UIButton(type: .custom)
    private let connectView = UILabel()
    private let skillView = UILabel()
    private let closeButton = UIButton(type: .custom)
    private let pickupView = LottieAnimationView(filePath: "IncomingCall".toAnimationPath)
    private var waitTime: Int = 45
    private var waitTimer: Timer?
    private var type: CallPreviewType = .Calling
    private(set) var hostModel: SessionResponseHostListModel?
    private(set) var callModel: CallRoomInfoModel?
    var delegate: CallPreViewDelegate?
    
    func setSourceData(_ data: (CallRoomInfoModel, SessionResponseHostListModel)) {
        callModel = data.0
        hostModel = data.1
        if data.0.callType == "calling" {
            type = .Calling
        }else if data.0.callType == "incoming" {
            type = .Incoming
        }else if data.0.callType == "match" {
            type = .Match
        }
        nameView.loafer_text(data.1.nickname)
        iconView.loadImage(url: data.1.avatar)
        backImageView.loadImage(url: data.1.avatar, blur: 25.FIT)
        callPriceBtn.loafer_text("\(data.0.callPrice)/min")
        pickupView.isHidden = type == .Calling || type == .Match
        connectView.loafer_text(type.connectDesc)
        connectView.topConstraint?.constant = 35.FIT
        waitTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else { return }
            self.waitTime -= 1
            if self.waitTime % 3 == 0 {
                let randomNum = arc4random() % 3 + 1
                self.skillView.loafer_text(type.desc[Int(randomNum)])
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loafer_clipsToBounds(true)
        subviews {
            backImageView
            animationView
            iconView
            nameView
            callPriceBtn
            connectView
            skillView
            closeButton
            pickupView
        }
        backImageView.fillContainer()
        closeButton.leading(15.FIT).top(UIDevice.safeTop).size(45.FIT)
        iconView.top(UIDevice.topFullHeight + 105.FIT).centerHorizontally().size(120.FIT)
        animationView.followEdges(iconView, top: -105.FIT, bottom: 105.FIT, leading: -105.FIT, trailing: 105.FIT)
        nameView.Top == iconView.Bottom + 10.FIT
        nameView.centerHorizontally().height(30.FIT)
        callPriceBtn.Top == nameView.Bottom + 5.FIT
        callPriceBtn.centerHorizontally().height(30.FIT).width(>=100.FIT)
        connectView.Top == animationView.Bottom + 35.FIT
        connectView.centerHorizontally().height(35.FIT)
        skillView.Top == connectView.Bottom + 5.FIT
        skillView.leading(20.FIT).trailing(20.FIT)
        pickupView.bottom(UIDevice.safeBottom+60.FIT).centerHorizontally().size(70.FIT)
        callPriceBtn
            .loafer_backColor("000000", 0.3)
            .loafer_cornerRadius(15.FIT)
            .loafer_isHidden(true)
        pickupView.style { v in
            v.contentMode = .scaleAspectFill
            v.loopMode = .loop
            v.shouldRasterizeWhenIdle = true
            v.backgroundBehavior = .pauseAndRestore
            v.play()
        }
        animationView.style { v in
            v.contentMode = .scaleAspectFill
            v.loopMode = .loop
            v.shouldRasterizeWhenIdle = true
            v.backgroundBehavior = .pauseAndRestore
            v.play()
        }
        iconView
            .loafer_cornerRadius(60.FIT)
            .loafer_border("FF26C5", 2.FIT)
        closeButton
            .loafer_image("Loafer_AnchorDetailPage_Close")
            .loafer_target(self, selector: #selector(CallPreViewCloseBtn(_:)))
        nameView
            .loafer_font(24, .bold)
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
        connectView
            .loafer_font(28, .bold)
            .loafer_text("Connecting...")
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
        skillView
            .loafer_font(17, .medium)
            .loafer_textColor("FFFFFF", 0.8)
            .loafer_textAligment(.center)
            .loafer_numberOfLines(0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(CallPreViewPickupButton))
        pickupView.addGestureRecognizer(tap)
    }
    
    @objc private func CallPreViewPickupButton() {
        guard let hostModel, let callModel else { return }
        if LoaferAppSettings.UserInfo.user.coinBalance < hostModel.callPrice {
            InsufficientPolicy.insufficientPop(type: .CallPre(hostModel: hostModel))
            return
        }
        pickupView.loafer_isHidden(true)
        connectView.loafer_text("Connecting...")
        IMCallProvider.sendIMSocket(.CALL_RESPONSE(model: IMSocketCallEndModel(recvId: hostModel.userId, callNo: callModel.callNo, status: CallStatusType.answer.rawValue)))
        RealmProvider.share.openTransaction { realm in
            if let callModel = realm.object(ofType: CallRoomInfoModel.self, forPrimaryKey: callModel.callNo) {
                callModel.status = CallStatusType.answer.rawValue
            }
        }
        if let d = delegate {
            d.agreeCall()
        }
    }
    
    @objc private func CallPreViewCloseBtn(_ sender: UIButton) {
        guard let hostModel, let callModel else { return }
        if let d = delegate {
            if type == .Calling || type == .Match {
                IMCallProvider.sendIMSocket(.CALL_END_BILLING(model: IMSocketCallEndModel(recvId: hostModel.userId, callNo: callModel.callNo, status: CallStatusType.cancelCall.rawValue)))
                d.cancelCall()
            }else {
                IMCallProvider.sendIMSocket(.CALL_RESPONSE(model: IMSocketCallEndModel(recvId: hostModel.userId, callNo: callModel.callNo, status: CallStatusType.refuse.rawValue)))
                d.refuseCall()
            }
        }
    }
    
    deinit {
        waitTimer?.invalidate()
        waitTimer = nil
        delegate = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

