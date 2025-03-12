
import UIKit
import KakaJSON

class ChatTitleView: UIView, SourceProtocol {
    
    func setSourceData(_ data: IMSocketConversationUserInfoItem) {
        hostModel = data
        nameView.loafer_text(data.nickname)
        if LoaferAppSettings.UserInfo.user.isRecharge {
            if data.onlineStatus == 0 {
                statusView.loafer_backColor("02FF76")
            }else if data.onlineStatus == 1 {
                statusView.loafer_backColor("D3D3D3")
            }else if data.onlineStatus == 2 {
                statusView.loafer_backColor("FF0202")
            }
        }else {
            statusView.loafer_backColor("02FF76")
        }
    }
    
    private let closeBtn = UIButton(type: .custom)
    private let moreBtn = UIButton(type: .custom)
    private let callBtn = UIButton(type: .custom)
    private let statusView = UIView()
    private let nameView = UILabel()
    private let nameStackView = UIStackView()
    private var hostModel: IMSocketConversationUserInfoItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            closeBtn
            nameStackView
            moreBtn
            callBtn
        }
        closeBtn.centerVertically().size(45.FIT).leading(15.FIT)
        callBtn.size(35.FIT).centerVertically()
        callBtn.Trailing == moreBtn.Leading - 5.FIT
        moreBtn.size(40.FIT).centerVertically().trailing(15.FIT)
        nameStackView.centerInContainer().width(<=(UIDevice.screenWidth-160.FIT))
        statusView.size(14.FIT)
        nameStackView.addArrangedSubview(statusView)
        nameStackView.addArrangedSubview(nameView)
        statusView
            .loafer_cornerRadius(7.FIT)
            .loafer_backColor("29DD52")
            .loafer_border("FFFFFF", 1.FIT)
        nameView
            .loafer_font(21, .bold)
            .loafer_text("Name")
            .loafer_textColor("E1D2EA")
            .loafer_textAligment(.center)
        nameStackView
            .loafer_axis(.horizontal)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalCentering)
        closeBtn
            .loafer_image("Loafer_AnchorDetailPage_Close")
            .loafer_target(self, selector: #selector(loaferChatTitleViewCloseBtn))
        callBtn
            .loafer_image("Loafer_ChatTitleView_Call")
            .loafer_target(self, selector: #selector(loaferChatTitleViewCallBtn))
        moreBtn
            .loafer_image("Loafer_AnchorDetailPage_More")
            .loafer_target(self, selector: #selector(loaferChatTitleViewMoreBtn))
    }
    
    @objc private func loaferChatTitleViewCloseBtn() {
        if let page = iq.parentContainerViewController() {
            page.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func loaferChatTitleViewCallBtn() {
        guard let hostModel else { return }
        if LoaferAppSettings.UserInfo.user.coinBalance < hostModel.callPrice {
            InsufficientPolicy.insufficientPop(type: .CallPre(hostModel: model(from: hostModel.kj.JSONObject(), SessionResponseHostListModel.self)))
        }else {
            LoaferAppSettings.AOP.callSource = "聊天界面"
            CallUtil.call(to: hostModel.userId)
        }
    }
    
    @objc private func loaferChatTitleViewMoreBtn() {
        guard let hostModel else { return }
        let more = LoaferActionSheetView(items: [.Report, .Block])
        more.didSelectItems = { item in
            if item == .Block {
                PopUtil.pop(show: BlockTipView(avatar: hostModel.avatar, userId: hostModel.userId))
            }else if item == .Report {
                PopUtil.pop(show: ReportView(userId: hostModel.userId))
            }
        }
        PopUtil.pop(show: more)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ChatResponderView: UIView, UITextFieldDelegate, SourceProtocol {
    
    func setSourceData(_ data: IMSocketConversationUserInfoItem) {
        hostModel = data
    }
    
    private let stackView = UIStackView()
    private let pictureBtn = UIButton(type: .custom)
    private let giftBtn = UIButton(type: .custom)
    private let chatTextField = UITextField()
    private var hostModel: IMSocketConversationUserInfoItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            stackView
        }
        layout {
            10.FIT
            |-10.FIT-stackView-10.FIT-| ~ 40.FIT
        }
        stackView
            .loafer_axis(.horizontal)
            .loafer_spacing(10.FIT)
            .loafer_alignment(.fill)
            .loafer_distribution(.fill)
        pictureBtn.size(40.FIT)
        giftBtn.size(40.FIT)
        let emptyView = UIView()
        emptyView.size(15.FIT)
        chatTextField
            .loafer_cornerRadius(20.FIT)
            .loafer_font(16, .medium)
            .loafer_placeholder("Say Hi~")
            .loafer_placeholderFont(16, .medium)
            .loafer_placeholderColor("FFFFFF", 0.32)
            .loafer_tintColor("FFFFFF")
            .loafer_textColor("FFFFFF")
            .loafer_backColor("FFFFFF", 0.14)
            .delegate = self
        chatTextField.returnKeyType = .send
        chatTextField.enablesReturnKeyAutomatically = true
        chatTextField.leftView = emptyView
        chatTextField.rightView = emptyView
        chatTextField.leftViewMode = .always
        chatTextField.rightViewMode = .always
        stackView.addArrangedSubview(pictureBtn)
        stackView.addArrangedSubview(giftBtn)
        stackView.addArrangedSubview(chatTextField)
        pictureBtn
            .loafer_image("Loafer_ChatTitleView_Picture")
            .loafer_target(self, selector: #selector(loaferChatResponderViewPictureButton))
        giftBtn
            .loafer_image("Loafer_ChatTitleView_Gift")
            .loafer_target(self, selector: #selector(loaferChatResponderViewGiftButton))
    }
    
    @objc private func loaferChatResponderViewGiftButton() {
        guard let hostModel else { return }
        PopUtil.pop(show: SendGiftView(hostModel: model(from: hostModel.kj.JSONObject(), IMSocketConversationUserInfoItem.self), policy: .default))
    }
    
    @objc private func loaferChatResponderViewPictureButton() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let hostModel else { return false }
        guard let text = textField.text, !text.isBlank, !text.isEmpty, text.count > 0 else {
            ToastTool.show(.failure, "Can not send empty message!")
            return false
        }
        debugPrint(text)
        guard LoaferAppSettings.UserInfo.canSendMessage else {
            InsufficientPolicy.insufficientPop(type: .SendMessage(hostModel: model(from: hostModel.kj.JSONObject(), SessionResponseHostListModel.self)))
            return false
        }
        var model = IMSocketMessageItem()
        model.content = text
        model.messageId = "\(Int64(Date().timeIntervalSince1970 * 1000))" + "\(Int64(arc4random_uniform(99_999_999)))"
        model.sendId = LoaferAppSettings.UserInfo.user.userId
        model.recvId = hostModel.userId
        model.contentStatus = IMSocketMessageStatusType.UNREAD_UNDELIVERED.rawValue
        model.contentType = IMSocketMessageBodyType.TEXT.rawValue
        model.conversationId = LoaferAppSettings.URLSettings.IMPRE + "\(hostModel.userId)&" + "\(LoaferAppSettings.UserInfo.user.userId)"
        model.times = Int64(Date().timeIntervalSince1970 * 1000)
        IMChatProvider.sendIMSocket(IMSocketSubType.CHAT.MESSAGE(model: model, user: hostModel))
        RealmProvider.share.addMessage(model: model)
        textField.text = nil
        return true
    }
    
}


// MARK: - ChatTextCell

class ChatTextCell: UITableViewCell, SourceProtocol {
    typealias SourceData = (IMSocketMessageSaveItem, IMSocketConversationUserInfoItem?)
    
    func setSourceData(_ t: (IMSocketMessageSaveItem, IMSocketConversationUserInfoItem?)) {
        let isOwner = t.0.sendId == LoaferAppSettings.UserInfo.user.userId
        contentBackView.loafer_backColor(isOwner ? "F047A2" : "FE269C", isOwner ? 0.24 : 1)
        contentLabel.leadingConstraint?.constant = isOwner ? 25.FIT : 85.FIT
        containerView.semanticContentAttribute = isOwner ? .forceRightToLeft : .forceLeftToRight
        contentBackView.loafer_cornerRadius(15.FIT, isOwner ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner] : [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner])
        iconView.isHidden = isOwner
        if let urlString = t.1?.avatar {
            iconView.loadImage(url: urlString)
        }
        source = t.0
        contentLabel.loafer_text(t.0.content)
    }
    
    var appearTime: Int? {
        didSet {
            guard let time = appearTime, time > 0 else {
                timeLabel.isHidden = true
                timeLabel.heightConstraint?.constant = 0
                return
            }
            timeLabel.isHidden = false
            let date = Date().transformChatTime(timeInterval: TimeInterval(time / 1000))
            timeLabel.text = date
            timeLabel.heightConstraint?.constant = 20
        }
    }
    
    private let timeLabel = UILabel()
    private(set) var source: IMSocketMessageSaveItem?
    private let containerView = UIView()
    private let iconView = UIImageView(image: "Loafer_Basic_EmptyIcon".toImage)
    private let contentLabel = UILabel()
    private let contentBackView = UIView()
    private let translateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.subviews {
            containerView.subviews {
                timeLabel
                contentBackView
                contentLabel
                iconView
            }
        }
        containerView.fillSuperview()
        timeLabel.top(0).leading(0).trailing(0).height(0)
        contentLabel.leading(85.FIT).bottom(20.FIT).width(>=30.FIT).width(<=240.FIT)
        contentLabel.Top == timeLabel.Bottom + 35.FIT
        contentBackView.followEdges(contentLabel, top: -10.FIT, bottom: 10.FIT, leading: -10.FIT, trailing: 10.FIT)
        iconView.leading(15.FIT).bottom(10.FIT).size(50.FIT)
        contentLabel
            .loafer_font(16, .semiBold)
            .loafer_textColor("FFFFFF")
            .loafer_numberOfLines(0)
        timeLabel
            .loafer_font(12, .semiBold)
            .loafer_textColor("C7B0CE")
            .loafer_textAligment(.center)
        iconView.loafer_cornerRadius(25.FIT)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ChatPhotoCell

class ChatPhotoCell: UITableViewCell, SourceProtocol {
    typealias SourceData = (IMSocketMessageSaveItem, IMSocketConversationUserInfoItem?)
    
    func setSourceData(_ t: (IMSocketMessageSaveItem, IMSocketConversationUserInfoItem?)) {
        mainView.loadImage(url: t.0.content)
        let isOwner = t.0.sendId == LoaferAppSettings.UserInfo.user.userId
        iconView.loafer_isHidden(isOwner)
        containerView.semanticContentAttribute = isOwner ? .forceRightToLeft : .forceLeftToRight
        backView.loafer_cornerRadius(15.FIT, isOwner ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner] : [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner])
        iconView.widthConstraint?.constant = isOwner ? 0.FIT : 30.FIT
        iconView.leadingConstraint?.constant = isOwner ? 0.FIT : 15.FIT
        if let m = t.1, !isOwner {
            iconView.loadImage(url: m.avatar)
        }
        source = t.0
    }
    
    var appearTime: Int? {
        didSet {
            guard let time = appearTime, time > 0 else {
                timeLabel.isHidden = true
                timeLabel.heightConstraint?.constant = 0
                return
            }
            timeLabel.isHidden = false
            let date = Date().transformChatTime(timeInterval: TimeInterval(time / 1000))
            timeLabel.text = date
            timeLabel.heightConstraint?.constant = 20.FIT
        }
    }
    
    private(set) var source: IMSocketMessageSaveItem?
    var browserClosure: ((_ url: String) -> Void)?
    private let timeLabel = UILabel()
    private let backView = UIView()
    private let mainView = UIImageView(image: "Loafer_Basic_Empty".toImage)
    private let iconView = UIImageView(image: "Loafer_Basic_EmptyIcon".toImage)
    private let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.subviews {
            containerView.subviews {
                iconView
                backView.subviews(mainView)
                timeLabel
            }
        }
        containerView.fillContainer()
        timeLabel.top(0).leading(0).trailing(0).height(0)
        iconView.leading(15.FIT).bottom(10.FIT).size(50.FIT)
        backView.Leading == iconView.Trailing + 10.FIT
        backView.Bottom == iconView.Bottom
        backView.size(180.FIT)
        backView.Top == timeLabel.Bottom + 15.FIT
        mainView.fillContainer()
        backView.loafer_clipsToBounds(true)
        iconView.loafer_cornerRadius(25.FIT)
        timeLabel
            .loafer_font(12, .semiBold)
            .loafer_textColor("C7B0CE")
            .loafer_textAligment(.center)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ChatCallCell

class ChatCallCell: UITableViewCell, SourceProtocol {
    
    typealias SourceData = (IMSocketMessageSaveItem, IMSocketConversationUserInfoItem?)
    
    func setSourceData(_ t: (IMSocketMessageSaveItem, IMSocketConversationUserInfoItem?)) {
        userModel = t.1
        let isOwner = t.0.sendId == LoaferAppSettings.UserInfo.user.userId
        if let callModel = model(from: t.0.content, IMSocketMessageCallEventModel.self) {
            if callModel.type == "connect" {
                statusLabel.loafer_text(callModel.time)
            } else {
                if callModel.type == "refuse" {
                    statusLabel.loafer_text("Declined")
                } else if callModel.type == "timeout" {
                    statusLabel.loafer_text("Call not answered")
                } else if callModel.type == "cancel" {
                    statusLabel.loafer_text("Call canceled by caller")
                }
            }
        }
        backView.loafer_backColor(isOwner ? "F047A2" : "FE269C", isOwner ? 0.24 : 1)
        
        iconView.loafer_isHidden(isOwner)
        containerView.semanticContentAttribute = isOwner ? .forceRightToLeft : .forceLeftToRight
        backView.semanticContentAttribute = isOwner ? .forceRightToLeft : .forceLeftToRight
        backView.loafer_cornerRadius(15.FIT, isOwner ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner] : [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner])
        iconView.widthConstraint?.constant = isOwner ? 0.FIT : 50.FIT
        iconView.leadingConstraint?.constant = isOwner ? 0.FIT : 15.FIT
        if let m = t.1, !isOwner {
            iconView.loadImage(url: m.avatar)
        }
    }

    var appearTime: Int? {
        didSet {
            guard let time = appearTime, time > 0 else {
                timeLabel.isHidden = true
                return
            }
            timeLabel.isHidden = false
            timeLabel.heightConstraint?.constant = 20
            let date = Date().transformChatTime(timeInterval: TimeInterval(time / 1000))
            timeLabel.text = date
        }
    }
    private var userModel: IMSocketConversationUserInfoItem?
    private let iconView = UIImageView(image: "Loafer_Basic_EmptyIcon".toImage)
    private let containerView = UIView()
    private let timeLabel = UILabel()
    private let statusLabel = UILabel()
    private let statuView = UIImageView()
    private let backView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.subviews {
            containerView.subviews {
                timeLabel
                iconView
                backView.subviews {
                    statuView
                    statusLabel
                }
            }
        }
        containerView.fillContainer()
        timeLabel.leading(0).trailing(0).top(0).height(0)
        iconView.leading(15.FIT).bottom(10.FIT).size(50.FIT)
        backView.Leading == iconView.Trailing + 10.FIT
        backView.Top == timeLabel.Bottom
        backView.width(>=100.FIT).bottom(10.FIT).height(50.FIT)
        |-15.FIT-statuView.centerVertically().width(20.FIT).height(16.FIT)-5.FIT-statusLabel.top(0).bottom(0)-10.FIT-|
        statusLabel
            .loafer_font(16, .semiBold)
            .loafer_textColor("FFFFFF")
        backView
            .loafer_cornerRadius(15.FIT)
        timeLabel
            .loafer_font(12, .semiBold)
            .loafer_textColor("C7B0CE")
            .loafer_textAligment(.center)
        iconView
            .loafer_cornerRadius(25.FIT)
            .loafer_isUserInteractionEnabled(true)
        statuView
            .loafer_image("Loafer_ChatCallCell_CallMiss")
        let tap = UITapGestureRecognizer(target: self, action: #selector(chatCallCellToCall))
        addGestureRecognizer(tap)
    }
    
    @objc private func chatCallCellToCall() {
        guard let hostModel = userModel else { return }
        if LoaferAppSettings.UserInfo.user.coinBalance < hostModel.callPrice {
            InsufficientPolicy.insufficientPop(type: .CallPre(hostModel: model(from: hostModel.kj.JSONObject(), SessionResponseHostListModel.self)))
        }else {
            CallUtil.call(to: hostModel.userId)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ChatGiftCell

class ChatGiftCell: UITableViewCell, SourceProtocol {
    
    func setSourceData(_ t: (IMSocketMessageSaveItem, IMSocketConversationUserInfoItem?)) {
        userModel = t.1
        let isOwner = t.0.sendId == LoaferAppSettings.UserInfo.user.userId
        if let giftModel = model(from: t.0.content, SessionResponsePonyModel.self) {
            giftView.loadImage(url: giftModel.image)
        }
        sendLabel.loafer_textColor(isOwner ? "FAFAFA" : "FFE0E0")
        backView.loafer_backColor(isOwner ? "F047A2" : "FE269C", isOwner ? 0.24 : 1)
        containerView.semanticContentAttribute = isOwner ? .forceRightToLeft : .forceLeftToRight
        backView.semanticContentAttribute = !isOwner ? .forceRightToLeft : .forceLeftToRight
        backView.loafer_cornerRadius(15.FIT, isOwner ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner] : [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner])

    }

    var appearTime: Int? {
        didSet {
            guard let time = appearTime, time > 0 else {
                timeLabel.isHidden = true
                return
            }
            timeLabel.isHidden = false
            timeLabel.heightConstraint?.constant = 20
            let date = Date().transformChatTime(timeInterval: TimeInterval(time / 1000))
            timeLabel.text = date
        }
    }
    private var userModel: IMSocketConversationUserInfoItem?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.subviews {
            containerView.subviews {
                timeLabel
                backView.subviews {
                    giftView
                    sendLabel
                }
            }
        }
        containerView.fillContainer()
        timeLabel.leading(0).trailing(0).top(0).height(0)
        backView.Top == timeLabel.Bottom + 15.FIT
        backView.width(>=100.FIT).bottom(10.FIT).height(50.FIT).leading(15.FIT)
        |-15.FIT-sendLabel.width(<=80.FIT).top(0).bottom(0)-0-giftView.centerVertically().size(52.FIT)-10.FIT-|
        backView
            .loafer_cornerRadius(15.FIT)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var containerView: UIView = {$0}(UIView())
    
    private lazy var sendLabel: UILabel = {
        $0
            .loafer_font(16, .semiBold)
            .loafer_textColor("FFFFFF")
            .loafer_text("Send to")
    }(UILabel())
    
    private lazy var giftView: UIImageView = {
        $0
    }(UIImageView())
    
    private lazy var backView: UIView = {
        $0.loafer_clipsToBounds(true)
    }(UIView())
    
    private lazy var timeLabel: UILabel = {
        $0
            .loafer_font(12, .semiBold)
            .loafer_textColor("C7B0CE")
            .loafer_textAligment(.center)
    }(UILabel())
}
