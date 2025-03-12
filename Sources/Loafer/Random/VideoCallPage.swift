import UIKit
import RealmSwift
import AgoraRtcKit

class VideoCallPage: LoaferPage, SourceProtocol {
    
    var isCaller: Bool = true
    private var callBeginTime: Int = 0
    private(set) var callModel: CallRoomInfoModel = CallRoomInfoModel()
    private(set) var hostModel: SessionResponseHostListModel = SessionResponseHostListModel()
    override var prefersNavigationBarHidden: Bool { true }
    override var isFullScreenPopGestureEnabled: Bool { false }
    override var isInteractivePopGestureEnabled: Bool { false }
    private var callToken: NotificationToken?
    private var isCalling: Bool = false
    private var remoteVideoIsDecoding: Bool = false
    private var remoteVideoDecodeTimer: Timer?
    private var isStreamPushSuccess: Bool = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews {
            remoteCloseView
            remoteView
            controlView
            localView.subviews {
                flipCameraBtn
            }
            cutTimingView
            localCloseView
            preView
        }
        remoteCloseView.fillContainer()
        remoteView.fillContainer()
        controlView.fillContainer()
        preView.fillContainer()
        localView.trailing(15.FIT).top(UIDevice.safeTop+10.FIT).width(120.FIT).height(170.FIT)
        localCloseView.followEdges(localView)
        flipCameraBtn.centerHorizontally().bottom(15.FIT).size(40.FIT)
        cutTimingView.CenterX == localView.CenterX
        cutTimingView.Top == localView.Bottom + 10.FIT
        cutTimingView.size(60.FIT)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAction(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAction(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    func setSourceData(_ data: CallRoomInfoModel) {
        callModel = data
        callBeginTime = data.createTime
        if let anchorModel = data.anchorModel {
            URLSessionProvider.request(.URLInterfaceHostDetail(model: SessionRequestHostDetailModel(userId: anchorModel.userId)), type: SessionResponseHostListModel.self)
                .compactMap { $0.data }
                .done {[weak self] result in
                    self?.hostModel = result
                    self?.preView.setSourceData((data, result))
                    self?.controlView.setSourceData((data, result))
                }
                .catch { error in
                    error.handle()
                }
        }
        perform(#selector(checkIsBeginCall), with: nil, afterDelay: 60)
        initializedLocalVideo()
        if let callModel = RealmProvider.share.aRealm.object(ofType: CallRoomInfoModel.self, forPrimaryKey: data.callNo) {
            callToken = callModel.observe { [weak self] change in
                guard let `self` = self else { return }
                if callModel.balanceInsufficient {
                    InsufficientPolicy.insufficientPop(type: .CallingPolicy(hostModel: self.hostModel))
                    return
                }
                if callModel.status == CallStatusType.answer.rawValue {
                    //TODO: -
//                    VoiceSessionManager.shared.stopSound()
                    let joinRoomStatus = self.rtcClient.joinChannel(byToken: Int64(callModel.toUserId) == LoaferAppSettings.UserInfo.user.userId ? callModel.toUserRtcToken : callModel.createUserRtcToken, channelId: callModel.callNo, info: nil, uid: UInt(LoaferAppSettings.UserInfo.user.userId))
                    if joinRoomStatus == -17 {
                        return
                    }
                    if joinRoomStatus < 0 {
                        ToastTool.show(.failure, "Call Failure, please try again later!")
                        IMCallProvider.sendIMSocket(.CALL_END_BILLING(model: IMSocketCallEndModel(recvId: callModel.anchorModel?.userId ?? 0, callNo: callModel.callNo, status: CallStatusType.callErrorDone.rawValue)))
                        self.leaveChannel()
                    }
                }else if callModel.status == CallStatusType.refuse.rawValue {
                    if isCaller {
                        ToastTool.show(.failure, "The other party refused!")
                    }
                    self.leaveChannel()
                }else if callModel.status == CallStatusType.cancelCall.rawValue {
                    if !isCaller {
                        ToastTool.show(.failure, "The other party cancelled!")
                    }
                    self.leaveChannel()
                }else if callModel.status == CallStatusType.callDone.rawValue {
                    if callModel.callTime > 0 {
                        controlView.beginCallTime(callModel.callTime)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.leaveChannel()
                    }
                }
            }
        }
    }
    
    private lazy var rtcConfiguration: AgoraVideoEncoderConfiguration = {
        let configuration = AgoraVideoEncoderConfiguration(size: AgoraVideoDimension1280x720, frameRate: .fps30, bitrate: AgoraVideoBitrateStandard, orientationMode: .fixedPortrait, mirrorMode: .auto)
        return configuration
    }()

    private lazy var rtcClient: AgoraRtcEngineKit = {
        let config = AgoraRtcEngineConfig()
        config.appId = LoaferAppSettings.Config.DEF_AGORA_APP_ID
        config.areaCode = AgoraAreaCodeType(rawValue: AgoraAreaCodeType.global.rawValue ^ AgoraAreaCodeType.CN.rawValue)!
        let rtc = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        rtc.setChannelProfile(.liveBroadcasting)
        rtc.setClientRole(.broadcaster)
        rtc.enableVideo()
        rtc.enableAudio()
        rtc.setVideoEncoderConfiguration(rtcConfiguration)
        rtc.setDefaultAudioRouteToSpeakerphone(true)
        rtc.setAudioProfile(.musicStandard)
        rtc.enableInstantMediaRendering()
        let options = AgoraBeautyOptions()
        options.lighteningLevel = 0.7
        options.smoothnessLevel = 0.6
        options.rednessLevel = 0.2
        options.sharpnessLevel = 0.2
        rtc.setBeautyEffectOptions(true, options: options)
        let colorEnhanceOptions = AgoraColorEnhanceOptions()
        colorEnhanceOptions.strengthLevel = 0.3
        colorEnhanceOptions.skinProtectLevel = 0.5
        rtc.setColorEnhanceOptions(true, options: colorEnhanceOptions)
        let denoiserOptions = AgoraVideoDenoiserOptions()
        denoiserOptions.mode = .auto
        denoiserOptions.level = .fast
        rtc.setVideoDenoiserOptions(true, options: denoiserOptions)
        let lowlightEnhanceOptions = AgoraLowlightEnhanceOptions()
        lowlightEnhanceOptions.mode = .auto
        lowlightEnhanceOptions.level = .fast
        rtc.setLowlightEnhanceOptions(true, options: lowlightEnhanceOptions)
        return rtc
    }()
    
    private lazy var remoteCloseView: CallRemoteVideoCloseView = {
        let aView = CallRemoteVideoCloseView()
        return aView
    }()
    
    private lazy var localCloseView: CallLocalVideoCloseView = {
        let aView = CallLocalVideoCloseView()
        aView.loafer_isHidden(true)
        return aView
    }()
    
    private lazy var flipCameraBtn: UIButton = {
        $0
            .loafer_image("VideoCallPage.FlipCamera")
            .loafer_target(self, selector: #selector(videoCallPageFlipCamera))
    }(UIButton(type: .custom))
    
    private lazy var preView: CallPreView = {
        let aView = CallPreView()
        aView.delegate = self
        return aView
    }()
    
    private lazy var controlView: CallControlView = {
        let aView = CallControlView()
        aView.delegate = self
        return aView
    }()
    
    private lazy var remoteView: UIView = {
        $0
    }(UIView())
    
    private lazy var localView: UIView = {
        $0
            .loafer_cornerRadius(20.FIT)
            .loafer_clipsToBounds(true)
    }(UIView())
    
    private lazy var cutTimingView: UIButton = {
        $0
            .loafer_cornerRadius(30.FIT)
            .loafer_clipsToBounds(true)
            .loafer_border("FF2266", 3)
            .loafer_backColor("000000", 0.4)
            .loafer_isHidden(true)
            .loafer_titleColor("FF2266")
            .loafer_font(22, .boldItalic)
            .loafer_text("\(LoaferAppSettings.Config.config.MATCH_FREE_CALL_TIME)")
    }(UIButton())
    
}

extension VideoCallPage {
    
    @objc private func keyboardAction(notification: Notification) {
        let userInfo = notification.userInfo
        let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let value = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if notification.name == UIResponder.keyboardWillShowNotification {
            controlView.updateMessageToolView(constrant: -value.height)
            UIView.animate(withDuration: duration) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        } else {
            controlView.updateMessageToolView(constrant: 0)
            UIView.animate(withDuration: duration) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }

    @objc private func videoCallPageFlipCamera() {
        rtcClient.switchCamera()
    }
    
    func initializedLocalVideo() {
        let canvas = AgoraRtcVideoCanvas()
        canvas.uid = UInt(LoaferAppSettings.UserInfo.user.userId)
        canvas.view = localView
        canvas.renderMode = .hidden
        rtcClient.setupLocalVideo(canvas)
        rtcClient.enableLocalAudio(true)
        rtcClient.startPreview()
    }
    
    @objc private func checkIsBeginCall() {
        if !remoteVideoIsDecoding {
            ToastTool.show(.failure, "The other party did not answer, please call again later!")
            sendCallEvent(event: "timeout")
            IMCallProvider.sendIMSocket(.CALL_END_BILLING(model: IMSocketCallEndModel(recvId: hostModel.userId, callNo: callModel.callNo, status: CallStatusType.callTimeoutDone.rawValue)))
            leaveChannel()
        }
    }
    
    private func sendCallEvent(event: String, time: String? = nil) {
        var model = IMSocketMessageItem()
        model.content = IMSocketMessageCallEventModel(time: time ?? "", type: event).kj.JSONString()
        model.messageId = "\(Int64(Date().timeIntervalSince1970 * 1000))" + "\(Int64(arc4random_uniform(99_999_999)))"
        model.sendId = LoaferAppSettings.UserInfo.user.userId
        model.recvId = hostModel.userId
        model.contentStatus = IMSocketMessageStatusType.UNREAD_UNDELIVERED.rawValue
        model.contentType = IMSocketMessageBodyType.CALLEVENT.rawValue
        model.conversationId = LoaferAppSettings.URLSettings.IMPRE + "\(hostModel.userId)&" + "\(LoaferAppSettings.UserInfo.user.userId)"
        model.times = Int64(Date().timeIntervalSince1970 * 1000)
        IMChatProvider.sendIMSocket(IMSocketSubType.CHAT.MESSAGE(model: model, user: IMSocketConversationUserInfoItem(userId: hostModel.userId, avatar: hostModel.avatar, nickname: hostModel.nickname, gender: Int(hostModel.gender), onlineStatus: Int(hostModel.onlineStatus), signature: hostModel.signature, callPrice: hostModel.callPrice)))
        RealmProvider.share.addMessage(model: model)
    }
    
    private func leaveChannel() {
        SwiftEntryKit.dismiss(.all)
        preView.delegate = nil
        controlView.delegate = nil
        rtcClient.leaveChannel { [weak self] _ in
            self?.localView.removeFromSuperview()
            self?.remoteView.removeFromSuperview()
        }
        rtcClient.delegate = nil
        AgoraRtcEngineKit.destroy()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        remoteVideoDecodeTimer?.invalidate()
        remoteVideoDecodeTimer = nil
        dismiss(animated: true) {
            //TODO: - 
//            VoiceSessionManager.shared.stopSound()
        }
    }
    
}

extension VideoCallPage: AgoraRtcEngineDelegate {
    
    func rtcEngine(_: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        if errorCode == .clientIsBannedByServer {
            leaveChannel()
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, networkQuality uid: UInt, txQuality: AgoraNetworkQuality, rxQuality: AgoraNetworkQuality) {

    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, localVideoStateChangedOf state: AgoraVideoLocalState, reason: AgoraLocalVideoStreamReason, sourceType: AgoraVideoSourceType) {
        
    }
    
    func rtcEngine(_: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteReason, elapsed _: Int) {
        if !remoteVideoIsDecoding {
            remoteVideoDecodeTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: {[weak self] t in
                guard let `self` = self else { return }
                if !self.remoteVideoIsDecoding {
                    IMCallProvider.sendIMSocket(.CALL_END_BILLING(model: IMSocketCallEndModel(recvId: hostModel.userId, callNo: callModel.callNo, status: CallStatusType.callingErrorDone.rawValue)))
                    self.leaveChannel()
                    return
                }
                self.remoteVideoDecodeTimer?.invalidate()
                self.remoteVideoDecodeTimer = nil
                t.invalidate()
            })
        }
        if state == .decoding && !remoteVideoIsDecoding {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            remoteVideoIsDecoding = true
            remoteVideoDecodeTimer?.invalidate()
            remoteVideoDecodeTimer = nil
            let canvas = AgoraRtcVideoCanvas()
            canvas.uid = uid
            canvas.view = remoteView
            canvas.renderMode = .hidden
            rtcClient.setupRemoteVideo(canvas)
            preView.loafer_isHidden(true)
            controlView.loafer_isHidden(false)
            localView.bringSubviewToFront(flipCameraBtn)
            if !isStreamPushSuccess && hostModel.anchorCategory == 2 {
                rtcClient.muteLocalVideoStream(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
                    self?.rtcClient.muteLocalVideoStream(false)
                    self?.isStreamPushSuccess = true
                }
            }
            if !isCalling {
                IMCallProvider.sendIMSocket(.CALL_START_BILLING(model: IMSocketCallStartModel(sendId: LoaferAppSettings.UserInfo.user.userId, recvId: hostModel.userId, callNo: callModel.callNo)))
                isCalling = true
            }
            if callModel.callType == "match" {
                beginMatchTimeing()
            }else {
                controlView.beginCallTime()
            }
            perform(#selector(hiddenTipView), with: nil, afterDelay: 3)
        }
        if state == .starting || state == .decoding {
            remoteView.loafer_isHidden(false)
            remoteCloseView.loafer_isHidden(true)
        }else {
            remoteView.loafer_isHidden(true)
            remoteCloseView.loafer_isHidden(false)
        }
    }
    
    func beginMatchTimeing() {
        cutTimingView.loafer_isHidden(false)
        var matchTime = LoaferAppSettings.Config.config.MATCH_FREE_CALL_TIME
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] t in
            guard let `self` = self else { return }
            matchTime -= 1
            self.cutTimingView.loafer_text("\(matchTime)")
            if matchTime <= 0 {
                t.invalidate()
                self.cutTimingView.loafer_isHidden(true)
                if LoaferAppSettings.UserInfo.user.coinBalance >= self.hostModel.callPrice {
                    self.controlView.beginCallTime()
                }
            }
        }
    }
    
    @objc func hiddenTipView() {
        controlView.hiddenTipMsg()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        if uid == hostModel.userId {
            leaveChannel()
        }
    }
    
}

extension VideoCallPage: CallControlViewDelegate {
    
    func camera(isOpen: Bool) {
        rtcClient.muteLocalVideoStream(!isOpen)
        localView.loafer_isHidden(!isOpen)
        localCloseView.loafer_isHidden(isOpen)
    }
    
    func micphone(isOpen: Bool) {
        rtcClient.muteLocalAudioStream(!isOpen)
    }
    
    func hungupcall() {
        let exitView = VideoCallExitView()
        exitView.exitClosure = {[weak self] in
            guard let `self` = self else { return }
            IMCallProvider.sendIMSocket(.CALL_END_BILLING(model: IMSocketCallEndModel(recvId: self.hostModel.userId, callNo: self.callModel.callNo, status: CallStatusType.callDone.rawValue)))
            if self.controlView.callTime > 0 {
                let hours = self.controlView.callTime / 3600
                let minutes = (self.controlView.callTime / 60) % 60
                let seconds = self.controlView.callTime % 60
                self.sendCallEvent(event: "connect", time: String(format: "%02d:%02d:%02d", hours, minutes, seconds))
            }
            self.leaveChannel()
        }
        PopUtil.pop(show: exitView)
    }
    
}

extension VideoCallPage: CallPreViewDelegate {
    func refuseCall() {
        sendCallEvent(event: "refuse")
        leaveChannel()
    }
    
    func agreeCall() {
        
    }
    
    func cancelCall() {
        sendCallEvent(event: "cancel")
        leaveChannel()
    }
    
    
}
