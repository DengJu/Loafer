
import UIKit
import RealmSwift
import FSPagerView
import SafariServices

class ConversationPage: LoaferPage, FSPagerViewDelegate, FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        banners.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: FSPagerViewCell.description(), at: index)
        cell.imageView?.loadImage(url: banners[index].cover)
        cell.imageView?.contentMode = .scaleAspectFill
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        if let url = banners[index].url.toURL {
            let safari = SFSafariViewController(url: url)
            present(safari, animated: true, completion: nil)
        }
    }
    
    private let stackView = UIStackView()
    private let recommondView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let messageView = UITableView(frame: .zero, style: .plain)
    private let bannerView = FSPagerView()
    private let noDataStatus = Status(description: "You haven’t received any news yet~", image: "Loafer_EmptyPage_Conversation".toImage)
    private var conversationToken: NotificationToken?
    private var updateTimeTimer: Timer?
    private var conversations: [IMSocketConversationSaveItem] = []
    private var banners: [SessionResponseBannerModel] = []
    private var recomends: [SessionResponseHostListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews {
            stackView
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "REFRESH-USER-BALANCE"), object: nil, queue: .main) {[weak self] _ in
            self?.refreshRightItem()
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: "Loafer_ConversationPage_titleView".toImage))
        stackView.followEdges(view, top: UIDevice.topFullHeight, bottom: -UIDevice.bottomFullHeight)
        recommondView.height(160.FIT).width(UIDevice.screenWidth)
        bannerView.height(110.FIT).width(UIDevice.screenWidth-20.FIT)
        messageView.width(UIDevice.screenWidth)
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(10.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.fill)
        stackView.addArrangedSubview(bannerView)
        stackView.addArrangedSubview(recommondView)
        stackView.addArrangedSubview(messageView)
        messageView
            .loafer_delegate(self)
            .loafer_dataSource(self)
            .loafer_showsVerticalScrollIndicator(false)
            .loafer_backColor(.clear)
            .loafer_register(ConversationCell.self, ConversationCell.description())
            .addHeaderRefreshControl {
                IMChatProvider.sendIMSocket(.CONVERSATION_LIST)
            }
        messageView.show(status: loadingStatus)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 105.FIT, height: 140.FIT)
        layout.minimumLineSpacing = 8.FIT
        layout.minimumInteritemSpacing = 8.FIT
        layout.sectionInset = UIEdgeInsets(top: 10.FIT, left: 15.FIT, bottom: 10.FIT, right: 15.FIT)
        recommondView
            .loafer_layout(layout)
            .loafer_delegate(self)
            .loafer_dataSource(self)
            .loafer_showsHorizontalScrollIndicator(false)
            .loafer_backColor(.clear)
            .loafer_register(RecommondItem.self, RecommondItem.description())
        observerConversations()
        updateTimeTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: {[weak self] t in
            UIView.performWithoutAnimation {
                self?.messageView.reloadData()
            }
        })
        bannerView.style { v in
            v.itemSize = CGSize(width: UIDevice.screenWidth-20.FIT, height: 110.FIT)
            v.isInfinite = true
            v.scrollDirection = .horizontal
            v.interitemSpacing = 5.FIT
            v.automaticSlidingInterval = 3
            v.loafer_cornerRadius(15.FIT)
            v.loafer_clipsToBounds(true)
            v.register(FSPagerViewCell.self, forCellWithReuseIdentifier: FSPagerViewCell.description())
            v.delegate = self
            v.dataSource = self
            v.loafer_isHidden(true)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ConversationListEmptyNoty"), object: nil, queue: .main) {[weak self] _ in
            self?.messageView.headerEndRefresh()
        }
        URLSessionProvider.request(.URLInterfaceQueryBanner(model: SessionRequestQueryBannerModel()), type: [SessionResponseBannerModel].self)
            .compactMap({ $0.data })
            .then {[weak self] result in
                self?.banners = result
                DispatchQueue.main.async {
                    self?.bannerView.loafer_isHidden(result.isEmpty)
                    self?.bannerView.reloadData()
                }
                IMChatProvider.sendIMSocket(.CONVERSATION_LIST)
                return URLSessionProvider.request(.URLInterfaceRecommondHost(model: SessionRequestRecommondHostModel()), type: [SessionResponseHostListModel].self)
            }
            .done {[weak self] result in
                if let data = result.data {
                    self?.recomends = data
                    DispatchQueue.main.async {
                        self?.recommondView.reloadData()
                    }
                }
            }
            .catch { error in
                error.handle()
                self.bannerView.loafer_isHidden(true)
            }
    }
    
    func observerConversations() {
        let result = RealmProvider.share.aRealm.objects(IMSocketConversationSaveItem.self)
        conversationToken = result.observe { [weak self] changes in
            guard let `self` = self else { return }
            switch changes {
            case .initial:
                self.loadData()
            case .update:
                self.loadData()
                if let page = UIApplication.mainWindow.rootViewController as? LoaferTabBarPage {
                    page.refreshUnreadCount()
                }
            case let .error(error):
                fatalError("\(error)")
            }
        }
    }
    
    func loadData() {
        conversations = RealmProvider.share.queryConversations().filter { $0.latestMessageContent.count > 0 && $0.userInfo.count > 0 && !$0.isBlock && !RealmProvider.share.queryMessages(from: $0.conversationId).isEmpty }
        if conversations.isEmpty {
            messageView.show(status: noDataStatus)
        }else {
            messageView.hideStatus()
        }
        messageView.headerEndRefresh()
        messageView.reloadData()
    }
    
    func refreshRightItem() {
        if LoaferAppSettings.Gems.isNeedPopup && !LoaferAppSettings.UserInfo.user.isRecharge {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: ActivityTitleView())
        }else if LoaferAppSettings.Gems.limitOnceItems != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: OnlyonceView())
        }else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: BalanceView())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshRightItem()
    }
    
    deinit {
        conversationToken?.invalidate()
        conversationToken = nil
        updateTimeTimer?.invalidate()
        updateTimeTimer = nil
    }
    
}

extension ConversationPage: UICollectionViewDelegate & UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recomends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: RecommondItem.description(), for: indexPath) as? RecommondItem else { return UICollectionViewCell() }
        item.setSourceData(recomends[indexPath.row])
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let page = AnchorDetailPage()
        page.setSourceData(recomends[indexPath.row].userId)
        navigationController?.pushViewController(page, animated: true)
    }
    
}

extension ConversationPage: UITableViewDelegate & UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.description()) as? ConversationCell else { return UITableViewCell() }
        cell.setSourceData(conversations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let page = ChatPage()
        page.setSourceData(conversations[indexPath.row])
        navigationController?.pushViewController(page, animated: true)
    }
    
    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        let deleteAction = UIContextualAction(style: .normal, title: nil) {[weak self] _, _, completion in
            guard let `self` = self else { return }
            let conversation = self.conversations[indexPath.row]
            RealmProvider.share.deleteConversationFrom(conversationId: conversation.conversationId)
            completion(true)
        }
        let callAction = UIContextualAction(style: .normal, title: nil) {[weak self] _, _, completion in
            guard let `self` = self, let hostModel = self.conversations[indexPath.row].anchorModel else { return }
            if LoaferAppSettings.UserInfo.user.coinBalance < hostModel.callPrice {
                InsufficientPolicy.insufficientPop(type: .CallPre(hostModel: model(from: hostModel.kj.JSONObject(), SessionResponseHostListModel.self)))
            }else {
                LoaferAppSettings.AOP.callSource = "会话列表"
                CallUtil.call(to: hostModel.userId)
            }
            completion(true)
        }
        callAction.backgroundColor = "32E19F".toColor
        callAction.image = "Loafer_ConversationPage_VideoCall".toImage
        actions.append(callAction)
        deleteAction.backgroundColor = "FF215F".toColor
        deleteAction.image = "Loafer_ConversationPage_Delete".toImage
        actions.append(deleteAction)
        let config = UISwipeActionsConfiguration(actions: actions)
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.FIT
    }
    
}

class ConversationCell: UITableViewCell, SourceProtocol {
    
    typealias SourceData = IMSocketConversationSaveItem
    
    func setSourceData(_ data: IMSocketConversationSaveItem) {
        if let info = data.anchorModel {
            iconView.loadImage(url: info.avatar)
            nameView.text = info.nickname
            if info.onlineStatus == 0 {
                statuView.backgroundColor = "14C5A4".toColor
            }else if info.onlineStatus == 1 {
                statuView.backgroundColor = "B2B2B2".toColor
            }else {
                statuView.backgroundColor = "FD3C6E".toColor
            }
        }
        if data.latestMessageType == IMSocketMessageBodyType.TEXT.rawValue {
            msgView.text = data.latestMessageContent
        }else if data.latestMessageType == IMSocketMessageBodyType.VIDEO.rawValue {
            msgView.text = "[Video]"
        }else if data.latestMessageType == IMSocketMessageBodyType.VOICE.rawValue {
            msgView.text = "[Voice]"
        }else if data.latestMessageType == IMSocketMessageBodyType.IMAGE.rawValue {
            msgView.text = "[Picture]"
        }else if data.latestMessageType == IMSocketMessageBodyType.GIFT.rawValue {
            msgView.text = "[Gift]"
        }else if data.latestMessageType == IMSocketMessageBodyType.CALLEVENT.rawValue {
            msgView.text = "[Call]"
        }else {
            msgView.text = "[Other]"
        }
        timeView.text = data.times.toChatTime
        let unreadCount = RealmProvider.share.queryUnreadMessageCount(from: data.conversationId)
        unreadBtn.setTitle(unreadCount > 99 ? "99+" : "\(unreadCount)", for: .normal)
        unreadBtn.isHidden = unreadCount == 0
    }
    
    private let iconView = UIImageView(image: "Loafer_Basic_Empty".toImage)
    private let nameView = UILabel()
    private let msgView = UILabel()
    private let statuView = UIView()
    private let timeView = UILabel()
    private let unreadBtn = UIButton(type: .custom)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.subviews {
            iconView
            nameView
            msgView
            statuView
            timeView
            unreadBtn
        }
        iconView.leading(15.FIT).centerVertically().size(50.FIT)
        timeView.trailing(15.FIT).top(23.FIT).height(15.FIT)
        nameView.Top == iconView.Top
        nameView.Leading == iconView.Trailing + 10.FIT
        nameView.height(22.FIT)
        statuView.Trailing == iconView.Trailing
        statuView.Bottom == iconView.Bottom
        statuView.size(12.FIT)
        msgView.Bottom == iconView.Bottom - 5.FIT
        msgView.height(21.FIT)
        msgView.Leading == nameView.Leading
        unreadBtn.Top == timeView.Bottom + 7.FIT
        unreadBtn.trailing(15.FIT).size(18.FIT)
        msgView.Trailing == unreadBtn.Leading - 10.FIT
        iconView
            .loafer_contentMode(.scaleAspectFill)
            .loafer_cornerRadius(25.FIT)
        timeView
            .loafer_font(12, .medium)
            .loafer_textColor("FFFFFF", 0.6)
            .loafer_textAligment(.right)
            .loafer_text("Time")
        nameView
            .loafer_font(17, .bold)
            .loafer_textColor("FFFFFF")
            .loafer_text("Name")
        msgView
            .loafer_font(14, .medium)
            .loafer_textColor("FFFFFF", 0.6)
            .loafer_text("New message content")
        unreadBtn
            .loafer_font(12, .semiBold)
            .loafer_text("0")
            .loafer_backColor("FF215F")
            .loafer_cornerRadius(9.FIT)
            .loafer_isUserInteractionEnabled(false)
        statuView
            .loafer_backColor("1BC348")
            .loafer_cornerRadius(6.FIT)
            .loafer_border("FFFFFF", 1.FIT)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class RecommondItem: UICollectionViewCell, SourceProtocol {
    
    func setSourceData(_ data: SessionResponseHostListModel) {
        hostModel = data
        mainView.loadImage(url: data.avatar)
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
    
    private let mainView = UIImageView()
    private let nameView = UIButton(type: .custom)
    private let statusView = UIView()
    private let stackView = UIStackView()
    private var hostModel: SessionResponseHostListModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.subviews {
            mainView
            stackView
        }
        contentView.loafer_cornerRadius(25.FIT)
        mainView.fillContainer()
        stackView.bottom(10).height(18).centerHorizontally().width(<=105.FIT)
        statusView.size(12.FIT)
        stackView.addArrangedSubview(statusView)
        stackView.addArrangedSubview(nameView)
        stackView
            .loafer_axis(.horizontal)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalCentering)
        mainView
            .loafer_contentMode(.scaleAspectFill)
            .loafer_cornerRadius(15)
            .loafer_backColor(.randomColor)
        nameView
            .loafer_titleColor("FFFFFF")
            .loafer_font(10, .bold)
            .loafer_text("Name")
        statusView
            .loafer_backColor("1BC348")
            .loafer_cornerRadius(6.FIT)
            .loafer_border("FFFFFF", 1.FIT)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
