
import UIKit
import KakaJSON
import RealmSwift

protocol CallControlViewDelegate {
    func camera(isOpen: Bool)
    func micphone(isOpen: Bool)
    func hungupcall()
}

class CallControlView: UIView, SourceProtocol {
    
    func setSourceData(_ data: (CallRoomInfoModel, SessionResponseHostListModel)) {
        hostModel = data.1
        callModel = data.0
        messageToolView.setSourceData(data.1)
        nameView.loafer_text(data.1.nickname)
        nameView.setShadowText()
        timeView.setShadowText()
        observeMessageChange()
        let tipCoinsMsg = IMSocketMessageSaveItem()
        tipCoinsMsg.sendId = 123
        tipCoinsMsg.content = "Each minute will deduct \(data.0.callPrice) coins."
        tipCoinsMsg.contentType = IMSocketMessageBodyType.TEXT.rawValue
        messages.insert(tipCoinsMsg, at: 0)
        let tipRuleMsg = IMSocketMessageSaveItem()
        tipRuleMsg.sendId = 123
        tipRuleMsg.content = "Please keep all interactions respectful and refrain from topics involving violence, explicit material or gambling."
        tipRuleMsg.contentType = IMSocketMessageBodyType.TEXT.rawValue
        messages.insert(tipRuleMsg, at: 0)
        msgView.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            hungUpBtn
            nameStackView
            bottomStackView
            msgView
            messageToolView
        }
        layout {
            UIDevice.safeTop + 10.FIT
            |-15.FIT-hungUpBtn.size(44.FIT)-5.FIT-nameStackView.height(44.FIT).width(<=180.FIT)
            >=0
            |-15.FIT-msgView.width(66%).height(300.FIT)
            10.FIT
            bottomStackView.centerHorizontally().height(70.FIT)
            UIDevice.safeBottom
        }
        messageToolView.leading(0).trailing(0).bottom(0).height(60.FIT)
        for i in 0..<bottomItems.count {
            let btn = UIButton(type: .custom)
            btn
                .loafer_image(bottomItems[i])
                .loafer_tag(i+1001)
                .loafer_target(self, selector: #selector(CallControlViewBottomItemsButton(_:)))
            if i > 0 {
                btn.loafer_image(bottomItems[i]+"_SEL", .selected)
            }
            btn.size(60.FIT)
            bottomStackView.addArrangedSubview(btn)
        }
        addGestureRecognizer(leftGesture)
        addGestureRecognizer(rightGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        delegate = nil
        messageToken?.invalidate()
        messageToken = nil
        callTimer?.invalidate()
        callTimer = nil
    }
    
    var delegate: CallControlViewDelegate?
    private let bottomItems: [String] = ["Loafer_VideoCall_Message", "Loafer_VideoCall_Micphone", "Loafer_VideoCall_Camera", "Loafer_VideoCall_Recharge", "Loafer_VideoCall_Gift"]
    private(set) var hostModel: SessionResponseHostListModel = SessionResponseHostListModel()
    private(set) var callModel: CallRoomInfoModel = CallRoomInfoModel()
    private var messageToken: NotificationToken?
    private var messages: [IMSocketMessageSaveItem] = []
    private var callTimer: Timer?
    var callTime: Int = 0
    
    private lazy var nameView: UILabel = {
        $0
            .loafer_font(20, .bold)
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
            .loafer_text("Name")
    }(UILabel())
    
    private lazy var timeView: UILabel = {
        $0
            .loafer_font(16, .medium)
            .loafer_textColor("FFFFFF")
            .loafer_text("00:00:00")
            .loafer_textAligment(.left)
            .loafer_isHidden(true)
    }(UILabel())
    
    private lazy var hungUpBtn: UIButton = {
        $0
            .loafer_image("Loafer_VideoCall_Hangup")
            .loafer_target(self, selector: #selector(callControlviewHungUpButton))
            .size(20.FIT)
    }(UIButton(type: .custom))
    
    private lazy var msgView: UITableView = {
        $0.loafer_backColor(.clear).loafer_separatorStyle(.none).loafer_register(VideoCallMsgCell.self, VideoCallMsgCell.description())
        $0.dataSource = self
        $0.delegate = self
        $0.transform = CGAffineTransform(scaleX: 1, y: -1)
        return $0
    }(UITableView(frame: .zero, style: .plain))
    
    private lazy var timeStackView: UIStackView = {
        $0
            .loafer_axis(.horizontal)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.leading)
            .loafer_distribution(.equalSpacing)
            .height(20.FIT)
    }(UIStackView(arrangedSubviews: [timeView]))
    
    private lazy var messageToolView: VideoCallMessageTool = {
        $0.loafer_isHidden(true)
    }(VideoCallMessageTool())
    
    private lazy var bottomStackView: UIStackView = {
        $0
            .loafer_axis(.horizontal)
            .loafer_spacing(10.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalSpacing)
    }(UIStackView())
    
    private lazy var nameStackView: UIStackView = {
        $0
            .loafer_axis(.vertical)
            .loafer_spacing(0)
            .loafer_alignment(.leading)
            .loafer_distribution(.equalSpacing)
    }(UIStackView(arrangedSubviews: [nameView, timeStackView]))
    
//    private lazy var avatarView: UIImageView = {
//        $0
//            .loafer_cornerRadius(22.FIT)
//            .loafer_contentMode(.scaleAspectFill)
//    }(UIImageView(image: "Basic.Placeholder.Squre".toImage))
    
    private lazy var leftGesture: UISwipeGestureRecognizer = {
        let s = UISwipeGestureRecognizer(target: self, action: #selector(videoCallControlViewSwipLeft))
        s.direction = .left
        return s
    }()
    
    private lazy var rightGesture: UISwipeGestureRecognizer = {
        let s = UISwipeGestureRecognizer(target: self, action: #selector(videoCallControlViewSwipRight))
        s.direction = .right
        return s
    }()
    
}

extension CallControlView {
    
    func hiddenTipMsg() {
        messages.removeAll(where: { $0.sendId == 123 })
        msgView.reloadData()
    }
    
    @objc private func videoCallControlViewSwipLeft() {
        hungUpBtn.loafer_isHidden(false)
        bottomStackView.loafer_isHidden(false)
        nameStackView.loafer_isHidden(false)
        msgView.loafer_isHidden(false)
    }
    
    @objc private func videoCallControlViewSwipRight() {
        hungUpBtn.loafer_isHidden(true)
        bottomStackView.loafer_isHidden(true)
        nameStackView.loafer_isHidden(true)
        msgView.loafer_isHidden(true)
    }
    
    private func observeMessageChange() {
        let conversationId = (LoaferAppSettings.URLSettings.IMPRE + "\(hostModel.userId)&" + "\(LoaferAppSettings.UserInfo.user.userId)")
        let result = RealmProvider.share.aRealm
            .objects(IMSocketMessageSaveItem.self)
            .where { $0.conversationId == conversationId }
            .sorted(by: \.times)
        messageToken = result.observe { [weak self] changes in
            guard let `self` = self else { return }
            switch changes {
            case .initial: break
            case .update(let results, _, let insertions, _):
                if !insertions.isEmpty, let index = insertions.map({ $0 }).first {
                    if results[index].contentType == IMSocketMessageBodyType.TEXT.rawValue {
                        self.messages.insert(result[index], at: 0)
                        DispatchQueue.main.async {
                            self.msgView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                            self.msgView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
                        }
                    }
                }
                RealmProvider.share.clearAllUnreadMessageCount(from: conversationId)
                if let page = UIApplication.mainWindow.rootViewController as? LoaferTabBarPage {
                    page.refreshUnreadCount()
                }
            case let .error(error):
                debugPrint(error)
            }
        }
    }
    
    public func updateMessageToolView(constrant: CGFloat) {
        messageToolView.loafer_isHidden(constrant == 0)
        messageToolView.bottomConstraint?.constant = constrant
    }
    
    @objc private func CallControlViewBottomItemsButton(_ sender: UIButton) {
        if sender.tag == 1001 {
            messageToolView.beginEdit()
        }else if sender.tag == 1002 {
            sender.loafer_isSelect(!sender.isSelected)
            if let d = delegate {
                d.micphone(isOpen: !sender.isSelected)
            }
        }else if sender.tag == 1003 {
            sender.loafer_isSelect(!sender.isSelected)
            if let d = delegate {
                d.camera(isOpen: !sender.isSelected)
            }
        }else if sender.tag == 1004 {
            InsufficientPolicy.insufficientPop(type: .CallingPolicy(hostModel: hostModel))
        }else if sender.tag == 1005 {
            PopUtil.pop(show: SendGiftView(hostModel: model(from: hostModel.kj.JSONObject(), IMSocketConversationUserInfoItem.self), policy: .Call))
        }
    }
    
    @objc private func callControlviewHungUpButton() {
        if let d = delegate {
            d.hungupcall()
        }
    }
    
    func beginCallTime(_ time: Int = 0) {
        if time > 0 {
            callTime = time
            let hours = callTime / 3600
            let minutes = (callTime / 60) % 60
            let seconds = callTime % 60
            timeView.loafer_text(String(format: "%02d:%02d:%02d", hours, minutes, seconds))
            callTimer?.invalidate()
            callTimer = nil
        }else {
            if callTimer == nil {
                timeView.loafer_isHidden(false)
                callTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {[weak self] _ in
                    guard let `self` = self else { return }
                    DispatchQueue.main.async {
                        let hours = self.callTime / 3600
                        let minutes = (self.callTime / 60) % 60
                        let seconds = self.callTime % 60
                        self.timeView.loafer_text(String(format: "%02d:%02d:%02d", hours, minutes, seconds))
                        self.callTime += 1
                    }
                })
            }
        }
    }
    
}

extension CallControlView: UITableViewDelegate & UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoCallMsgCell.description()) as? VideoCallMsgCell else { return UITableViewCell() }
        cell.setSourceData((messages[indexPath.row], hostModel))
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
    
}

class VideoCallMsgCell: UITableViewCell, SourceProtocol {
    
    func setSourceData(_ t: (IMSocketMessageSaveItem, SessionResponseHostListModel?)) {
        let isOwner = t.0.sendId == LoaferAppSettings.UserInfo.user.userId
        source = t.0
        contentLabel.text = t.0.content
        if t.0.conversationId.isEmpty { return }
        if let hostModel = t.1, !isOwner {
            contentLabel.loafer_attributeString(hostModel.nickname + ": " + t.0.content, [.foregroundColor : "FF0A56".toColor], NSRange(location: 0, length: hostModel.nickname.count + 1))
        }
    }
    
    private(set) var source: IMSocketMessageSaveItem?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.subviews {
            contentBackView
            contentLabel
        }
        contentLabel.leading(10.FIT).bottom(10.FIT).width(>=30.FIT).width(<=(UIDevice.screenWidth*0.66-20)).top(20.FIT)
        contentBackView.followEdges(contentLabel, top: -10.FIT, bottom: 10.FIT, leading: -10.FIT, trailing: 10.FIT)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var contentLabel: UILabel = {
        $0
            .loafer_font(16, .medium)
            .loafer_textColor("FFE0E0")
            .loafer_numberOfLines(0)
    }(UILabel())
    
    private lazy var contentBackView: UIView = {
        $0
            .loafer_backColor("2F0021", 0.2)
            .loafer_cornerRadius(20.FIT)
    }(UIView())
    
}

class VideoCallMessageTool: UIView, UITextFieldDelegate, SourceProtocol {
    
    private(set) var hostInfo: SessionResponseHostListModel?
    
    func setSourceData(_ data: SessionResponseHostListModel) {
        hostInfo = data
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loafer_backColor("151417")
        subviews {
            chatTextField
        }
        layout {
            10.FIT
            |-10.FIT-chatTextField-10.FIT-| ~ 40.FIT
            10.FIT
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginEdit() {
        chatTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let hostInfo else { return false }
        guard let text = textField.text, !text.isEmpty, !text.isBlank, text.count > 0 else {
            ToastTool.show(.success, "Can not send a empty message!")
            return false
        }
        var msgModel = IMSocketMessageItem()
        msgModel.content = text
        msgModel.messageId = "\(Int64(Date().timeIntervalSince1970 * 1000))" + "\(Int64(arc4random_uniform(99_999_999)))"
        msgModel.sendId = LoaferAppSettings.UserInfo.user.userId
        msgModel.recvId = hostInfo.userId
        msgModel.contentStatus = IMSocketMessageStatusType.UNREAD_UNDELIVERED.rawValue
        msgModel.contentType = IMSocketMessageBodyType.TEXT.rawValue
        msgModel.conversationId = LoaferAppSettings.URLSettings.IMPRE + "\(hostInfo.userId)&" + "\(LoaferAppSettings.UserInfo.user.userId)"
        msgModel.times = Int64(Date().timeIntervalSince1970 * 1000)
        IMChatProvider.sendIMSocket(IMSocketSubType.CHAT.MESSAGE(model: msgModel, user: model(from: hostInfo.kj.JSONObject(), IMSocketConversationUserInfoItem.self)))
        RealmProvider.share.addMessage(model: msgModel)
        textField.text = nil
        return true
    }
    
    @objc func chatResponderViewSendBtn(_ sender: UIButton) {
        guard let hostInfo else { return }
        guard let text = chatTextField.text, !text.isEmpty, !text.isBlank, text.count > 0 else {
            ToastTool.show(.success, "Can not send a empty message!")
            return
        }
        sender.loafer_isUserInteractionEnabled(false)
        var msgModel = IMSocketMessageItem()
        msgModel.content = text
        msgModel.messageId = "\(Int64(Date().timeIntervalSince1970 * 1000))" + "\(Int64(arc4random_uniform(99_999_999)))"
        msgModel.sendId = LoaferAppSettings.UserInfo.user.userId
        msgModel.recvId = hostInfo.userId
        msgModel.contentStatus = IMSocketMessageStatusType.UNREAD_UNDELIVERED.rawValue
        msgModel.contentType = IMSocketMessageBodyType.TEXT.rawValue
        msgModel.conversationId = LoaferAppSettings.URLSettings.IMPRE + "\(hostInfo.userId)&" + "\(LoaferAppSettings.UserInfo.user.userId)"
        msgModel.times = Int64(Date().timeIntervalSince1970 * 1000)
        IMChatProvider.sendIMSocket(IMSocketSubType.CHAT.MESSAGE(model: msgModel, user: model(from: hostInfo.kj.JSONObject(), IMSocketConversationUserInfoItem.self)))
        RealmProvider.share.addMessage(model: msgModel)
        chatTextField.text = nil
        sender.loafer_isUserInteractionEnabled(true)
    }
    
    private lazy var sendBtn: UIButton = {
        $0
            .loafer_image("ChatPage.Send")
            .loafer_target(self, selector: #selector(chatResponderViewSendBtn(_:)))
            .size(50.FIT)
    }(UIButton(type: .custom))
    
    private lazy var chatTextField: UITextField = {
        let view = UITextField()
        view.loafer_cornerRadius(20.FIT)
        view.loafer_font(16, .medium)
        view.loafer_placeholder("Type a message")
        view.loafer_placeholderFont(16, .medium)
        view.loafer_placeholderColor("FFFFFF", 0.32)
        view.loafer_tintColor("FFFFFF")
        view.loafer_textColor("FFFFFF")
        view.loafer_backColor("FFFFFF", 0.14)
        view.spellCheckingType = .no
        view.autocorrectionType = .no
        view.returnKeyType = .send
        view.delegate = self
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15.FIT, height: 15.FIT))
        view.rightView = sendBtn
        view.leftViewMode = .always
        view.rightViewMode = .always
        return view
    }()
}
