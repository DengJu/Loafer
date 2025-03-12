
import UIKit
import YDRootNavigationController

class AnchorDetailPage: LoaferPage, UIScrollViewDelegate, SourceProtocol {
    
    func setSourceData(_ data: Int64) {
        view.show(status: loadingStatus)
        URLSessionProvider.request(.URLInterfaceHostDetail(model: SessionRequestHostDetailModel(userId: data)), type: SessionResponseHostListModel.self)
            .compactMap { $0.data }
            .done {[weak self] result in
                self?.hostModel = result
                self?.likeButton.isSelected = result.followStatus > 1
                self?.videoView.setSourceData(result)
                self?.photoView.setSourceData(result)
                self?.popularView.setSourceData([("Followers:", "\(result.follower)"), ("Followings：", "\(result.following)")])
                self?.infomationView.setSourceData([("Gender:", result.gender == 0 ? "Male" : "Female"), ("Region:", LoaferAppSettings.queryCountryInfo("\(result.country)")?.1 ?? ""), ("ID:", "\(result.userId)")])
                self?.view.hideStatus()
            }
            .catch {[weak self] error in
                error.handle()
                self?.view.hideStatus()
            }
    }
    
    private let stackView = UIStackView()
    private let scrollView = UIScrollView()
    private let videoView = AnchorDetailVideoView()
    private let photoView = AnchorDetailPhotoView()
    private let infomationView = AnchorDetailInformationView()
    private let popularView = AnchorDetailPopularView()
    private let bottomView = UIView()
    private let bottomStackView = UIStackView()
    private let likeButton = UIButton(type: .custom)
    private let callButton = UIButton(type: .custom)
    private let chatButton = UIButton(type: .custom)
    private let moreButton = UIButton(type: .custom)
    private(set) var hostModel: SessionResponseHostListModel = SessionResponseHostListModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews {
            scrollView.subviews {
                stackView
            }
            bottomView.subviews(bottomStackView)
        }
        scrollView.followEdges(view)
        bottomView.bottom(0).height(UIDevice.safeBottom+80.FIT).leading(0).trailing(0)
        bottomStackView.centerInContainer()
        scrollView.layout {
            0
            |stackView|
            0
        }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIDevice.safeBottom+90.FIT, right: 0)
        stackView.width(UIDevice.screenWidth)
        photoView.width(UIDevice.screenWidth).height(<=(UIDevice.screenWidth*(460/375)+100.FIT))
        videoView.width(UIDevice.screenWidth).height(230.FIT)
        infomationView.width(UIDevice.screenWidth).height(200)
        popularView.width(UIDevice.screenWidth).height(150)
        stackView.addArrangedSubview(photoView)
        stackView.addArrangedSubview(videoView)
        stackView.addArrangedSubview(infomationView)
        stackView.addArrangedSubview(popularView)
        scrollView.bounces = false
        scrollView
            .loafer_contentInsetAdjustmentBehavior(.never)
            .delegate = self
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(0)
            .loafer_alignment(.center)
            .loafer_distribution(.equalSpacing)
        bottomStackView
            .loafer_axis(.horizontal)
            .loafer_spacing(35.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalSpacing)
        likeButton.size(45.FIT)
        callButton.size(80.FIT)
        chatButton.size(45.FIT)
        bottomStackView.addArrangedSubview(likeButton)
        bottomStackView.addArrangedSubview(callButton)
        bottomStackView.addArrangedSubview(chatButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
        likeButton
            .loafer_image("Loafer_AnchorDetailPage_Like", .normal)
            .loafer_image("Loafer_AnchorDetailPage_Unlike", .selected)
            .loafer_target(self, selector: #selector(loaferAnchorDetailPageLikeButton(_:)))
        callButton
            .loafer_image("Loafer_AnchorDetailPage_VideoCall")
            .loafer_target(self, selector: #selector(loaferAnchorDetailPageCallButton(_:)))
        chatButton
            .loafer_image("Loafer_AnchorDetailPage_Chat")
            .loafer_target(self, selector: #selector(loaferAnchorDetailPageChatButton))
        moreButton
            .loafer_image("Loafer_AnchorDetailPage_More")
            .loafer_target(self, selector: #selector(loaferAnchorDetailPageMoreButton))
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "BLOCK-USER-NOTIFICATION"), object: nil, queue: .main) {[weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func loaferAnchorDetailPageLikeButton(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        URLSessionProvider.request(.URLInterfaceFollow(model: SessionRequestFollowModel(followUserId: hostModel.userId, follow: !sender.isSelected)))
            .compactMap { $0.data }
            .done { result in
                if let isFollow = result as? Int {
                    sender.isSelected = isFollow > 1
                }
            }
            .ensure {
                sender.isUserInteractionEnabled = true
            }
            .catch { error in
                error.handle()
            }
    }
    
    @objc private func loaferAnchorDetailPageCallButton(_ sender: UIButton) {
        if LoaferAppSettings.UserInfo.user.coinBalance < hostModel.callPrice {
            InsufficientPolicy.insufficientPop(type: .CallPre(hostModel: hostModel))
        }else {
            LoaferAppSettings.AOP.callSource = "主播详情"
            CallUtil.call(to: hostModel.userId)
        }
    }
    
    @objc private func loaferAnchorDetailPageChatButton() {
        let chatPage = ChatPage()
        let finalModel = IMSocketConversationSaveItem()
        if let conversation = RealmProvider.share.queryConversation(from: LoaferAppSettings.URLSettings.IMPRE + "\(hostModel.userId)&" + "\(LoaferAppSettings.UserInfo.user.userId)"), !conversation.userInfo.isEmpty {
            finalModel.conversationId = conversation.conversationId
            finalModel.times = conversation.times
            finalModel.sendId = conversation.sendId
            finalModel.recvId = conversation.recvId
            finalModel.latestMessageType = conversation.latestMessageType
            finalModel.latestMessageContent = conversation.latestMessageContent
            finalModel.userInfo = conversation.userInfo
        }else {
            finalModel.conversationId = LoaferAppSettings.URLSettings.IMPRE + "\(hostModel.userId)&" + "\(LoaferAppSettings.UserInfo.user.userId)"
            finalModel.times = Int64(Date().timeIntervalSince1970 * 1000)
            finalModel.sendId = LoaferAppSettings.UserInfo.user.userId
            finalModel.recvId = hostModel.userId
            finalModel.userInfo = IMSocketConversationUserInfoItem(userId: hostModel.userId, avatar: hostModel.avatar, nickname: hostModel.nickname, gender: Int(hostModel.gender), onlineStatus: Int(hostModel.onlineStatus), signature: hostModel.signature, callPrice: hostModel.callPrice).kj.JSONString()
        }
        chatPage.setSourceData(finalModel)
        navigationController?.pushViewController(chatPage, animated: true)
    }
    
    @objc private func loaferAnchorDetailPageMoreButton() {
        let more = LoaferActionSheetView(items: [.Report, .Block])
        more.didSelectItems = {[weak self] item in
            guard let `self` = self else { return }
            if item == .Block {
                PopUtil.pop(show: BlockTipView(avatar: self.hostModel.avatar, userId: self.hostModel.userId))
            }else if item == .Report {
                PopUtil.pop(show: ReportView(userId: self.hostModel.userId))
            }
        }
        PopUtil.pop(show: more)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 317 {
            let a = YDNavigationBarAppearence(backgroundColor: "46133E".toColor.withAlphaComponent((scrollView.contentOffset.y-317)/30.FIT))
            updateNavigationBarAppearence(a)
        }else {
            let a = YDNavigationBarAppearence(backgroundColor: #colorLiteral(red: 0.06274509804, green: 0.07058823529, blue: 0.0862745098, alpha: 0))
            updateNavigationBarAppearence(a)
        }
    }
    
}

class AnchorDetailPhotoView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, SourceProtocol {
    private let pageBackView = UIStackView()
    private let pageDotView = UIView()
    private let nameLabel = UILabel()
    private let photoItemHeight: CGFloat = UIDevice.screenWidth*(460/375)
    private let costButton = UIButton(type: .custom)
    private let signatureLabel = UILabel()
    private let photosCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let statusView = UIView()
    private let genderView = UIImageView(image: "Loafer_AnchorDetailPage_Female".toImage)
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))

    private var dataSouce: [SessionResponseHostPictureModel] = []
    
    func setSourceData(_ data: SessionResponseHostListModel) {
        loafer_isHidden(false)
        if !data.userPictures.isEmpty {
            dataSouce.removeAll()
            for pic in data.userPictures {
                dataSouce.append(pic)
                let dotView = UIView()
                dotView.width(30).height(4)
                dotView.loafer_cornerRadius(2)
                    .loafer_backColor("FFFFFF", 0.2)
                pageBackView.addArrangedSubview(dotView)
            }
            pageBackView.loafer_isHidden(data.userPictures.count < 2)
            photosCollectionView.reloadData()
        } else {
            var picModel = SessionResponseHostPictureModel()
            picModel.url = data.avatar
            dataSouce.append(picModel)
            photosCollectionView.reloadData()
        }
        nameLabel.loafer_text(data.nickname)
        if let age = data.birthday.ageFromBirthday() {
            nameLabel.loafer_text(data.nickname + ",\(age)")
        }
        if data.signature.isEmpty {
            signatureLabel
                .loafer_text("I'm hotter than a flame and need you or a fireman.")
        } else {
            signatureLabel
                .loafer_text(data.signature)
        }
        costButton
            .loafer_imagePadding(5.FIT, UIFont.setFont(17, .bold), "\(data.callPrice)/Min", "FFFFFF")
        if data.onlineStatus == 0 {
            statusView.loafer_backColor("29DD52")
        } else if data.onlineStatus == 1 {
            statusView.loafer_backColor("D3D3D3")
        } else if data.onlineStatus == 2 {
            statusView.loafer_backColor("FF0202")
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            photosCollectionView
            blurView
            pageBackView.subviews(pageDotView)
            signatureLabel
        }
        blurView.contentView.subviews {
            statusView
            nameLabel
            genderView
            costButton
        }
        layout {
            0
            |photosCollectionView| ~ photoItemHeight
            0
            |-15.FIT-signatureLabel.height(<=100.FIT)-15.FIT-|
            0
        }
        blurView.leading(0).trailing(0).height(60.FIT)
        blurView.Bottom == photosCollectionView.Bottom
        pageBackView.Bottom == blurView.Top - 16.FIT
        pageBackView.centerHorizontally().height(4.FIT)
        pageDotView.leading(0).width(30.FIT).height(4.FIT).centerVertically()
        |-15.FIT-statusView.size(14.FIT).centerVertically()-5.FIT-nameLabel.centerVertically()-10.FIT-genderView.centerVertically().size(18.FIT)
        costButton.centerVertically().width(>=106.FIT).height(30.FIT).trailing(15.FIT)
        blurView.contentView
            .loafer_cornerRadius(26.FIT, [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        pageDotView
            .loafer_backColor("FFFFFF")
            .loafer_cornerRadius(2.FIT)
        nameLabel
            .loafer_textColor("E1D2EA")
            .loafer_font(21, .bold)
        costButton
            .loafer_image("Loafer_AnchorDetailPage_Coins")
            .loafer_backColor("FFDC1A", 0.2)
            .loafer_cornerRadius(15.FIT)
        signatureLabel
            .loafer_textColor("E1D2EA")
            .loafer_font(16, .medium)
            .loafer_numberOfLines(0)
        photosCollectionView
            .loafer_layout(HostDetailPhotoLayout())
            .loafer_delegate(self)
            .loafer_dataSource(self)
            .loafer_backColor(.clear)
            .loafer_isPageble(true)
            .loafer_cornerRadius(30.FIT, [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
            .loafer_showsVerticalScrollIndicator(false)
            .loafer_showsHorizontalScrollIndicator(false)
            .loafer_register(AnchorDetailPhotoItem.self, AnchorDetailPhotoItem.description())
            .loafer_contentInsetAdjustmentBehavior(.never)
        statusView
            .loafer_backColor("29DD52")
            .loafer_cornerRadius(7.FIT)
            .loafer_border("FFFFFF", 1)
        pageBackView
            .loafer_axis(.horizontal)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalSpacing)
            .loafer_isHidden(true)
        loafer_isHidden(true)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return dataSouce.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: AnchorDetailPhotoItem.description(), for: indexPath) as? AnchorDetailPhotoItem else { return UICollectionViewCell() }
        item.setSourceData(dataSouce[indexPath.row])
        return item
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let isEndScroll = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if isEndScroll {
            let currentIndex = photosCollectionView.contentOffset.x / UIDevice.screenWidth
            pageDotView.leadingConstraint?.constant = currentIndex * (30 + 5)
            UIView.animate(withDuration: 0.1) {
                self.layoutIfNeeded()
            }
        }
    }

    class AnchorDetailPhotoItem: UICollectionViewCell, SourceProtocol {

        func setSourceData(_ data: SessionResponseHostPictureModel) {
            photoImageView.loadImage(url: data.url)
        }
        
        let photoImageView = UIImageView()

        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.subviews {
                photoImageView
            }
            photoImageView.fillContainer()
            photoImageView
                .loafer_contentMode(.scaleAspectFill)
                .loafer_image("Loafer_Basic_Empty")
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private class HostDetailPhotoLayout: UICollectionViewFlowLayout {
        override func prepare() {
            scrollDirection = .horizontal
            minimumLineSpacing = 0
            minimumInteritemSpacing = 0
            itemSize = CGSize(width: UIDevice.screenWidth, height: UIDevice.screenWidth * (460/375))
            super.prepare()
        }

        override func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
            return true
        }
    }
}

class AnchorDetailVideoView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, SourceProtocol {

    
    func setSourceData(_ data: SessionResponseHostListModel) {
        hostModel = data
        dataSource = data.videos
        videoCollectionView.reloadData()
        loafer_isHidden(data.videos.isEmpty)
    }
    private var hostModel: SessionResponseHostListModel?
    private let titleLabel = UILabel()
    private let videoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var dataSource: [SessionResponseHostVideoModel] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            titleLabel
            videoCollectionView
        }
        layout {
            0
            |-15.FIT-titleLabel-15.FIT-| ~ 50.FIT
            0
            |videoCollectionView|
            0
        }
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15.FIT, bottom: 0, right: 15.FIT)
        layout.itemSize = CGSize(width: 140.FIT, height: 180.FIT)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        videoCollectionView
            .loafer_layout(layout)
            .loafer_dataSource(self)
            .loafer_delegate(self)
            .loafer_backColor(UIColor.clear)
            .loafer_register(VideoItem.self, VideoItem.description())
        titleLabel
            .loafer_text("Stories")
            .loafer_font(18, .bold)
            .loafer_textColor("F4F4F4")
        loafer_isHidden(true)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "VIDEO-UNLOCK-NOTIFICATION"), object: nil, queue: .main) {[weak self] notification in
            guard let `self` = self, let obj = notification.userInfo, let videoModel = obj["videoModel"] as? SessionResponseHostVideoModel else { return }
            if let videoIndex = self.dataSource.firstIndex(where: { $0.videoId == videoModel.videoId }) {
                self.dataSource[videoIndex].isPay = true
                self.videoCollectionView.reloadItems(at: [IndexPath(row: videoIndex, section: 0)])
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "VIDEO-LIKE-NOTIFICATION"), object: nil, queue: .main) {[weak self] notification in
            guard let `self` = self, let obj = notification.userInfo, let videoModel = obj["videoModel"] as? SessionResponseHostVideoModel, let isLike = obj["isLike"] as? Bool, let num = obj["personNum"] as? Int32 else { return }
            if let videoIndex = self.dataSource.firstIndex(where: { $0.videoId == videoModel.videoId }) {
                self.dataSource[videoIndex].isLike = isLike
                self.dataSource[videoIndex].likeNum = num
                self.videoCollectionView.reloadItems(at: [IndexPath(row: videoIndex, section: 0)])
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: VideoItem.description(), for: indexPath) as? VideoItem else { return UICollectionViewCell() }
        item.setSourceData(dataSource[indexPath.row])
        return item
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let hostModel else { return }
        if let page = iq.parentContainerViewController() {
            let videoPlayPage = SmallVideoPlayPage()
            videoPlayPage.setSourceData((hostModel, dataSource[indexPath.row]))
            page.navigationController?.pushViewController(videoPlayPage, animated: true)
        }
    }

    private class VideoItem: UICollectionViewCell, SourceProtocol {
        
        func setSourceData(_ data: SessionResponseHostVideoModel) {
            if data.isPay {
                statusView
                    .loafer_image("Loafer_AnchorDetailPage_Play")
                mainView.loadImage(url: data.cover)
            } else {
                statusView
                    .loafer_image("Loafer_AnchorDetailPage_Unlock")
                mainView.loadImage(url: data.cover, blur: 80)
            }
            contentView.subviews {
                statusView
            }
            statusView.fillContainer()
        }
        
        private(set) var videoLoadFailure: Bool = false

        private lazy var statusView: UIImageView = {
            let view = UIImageView()
            view.contentMode = .center
            return view
        }()

        private lazy var mainView: UIImageView = {
            let view = UIImageView(image: "Loafer_Basic_Empty".toImage)
            view.contentMode = .scaleAspectFill
            view.isUserInteractionEnabled = false
            return view
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)
            loafer_cornerRadius(20.FIT)
            loafer_clipsToBounds(true)
            contentView.subviews {
                mainView
            }
            mainView.fillContainer()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - AnchorDetailInformationView

class AnchorDetailInformationView: UIView, SourceProtocol {
    typealias SourceData = [(String, String)]
    
    func setSourceData(_ data: [(String, String)]) {
        loafer_isHidden(false)
        for arrangedSubview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(arrangedSubview)
        }
        for i in 0..<data.count {
            let view = AnchorDetailNormlView()
            view.setSourceData(data[i])
            view.width(UIDevice.screenWidth-20.FIT).height(50.FIT)
            stackView.addArrangedSubview(view)
            if data.count == 1 {
                view.loafer_cornerRadius(17.FIT)
            }else {
                if i == 0 {
                    view.loafer_cornerRadius(17.FIT, [.layerMinXMinYCorner, .layerMaxXMinYCorner])
                }else if i == data.count-1 {
                    view.loafer_cornerRadius(17.FIT, [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
                }
            }
        }
    }
    
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            titleLabel.text("Basic info")
            stackView
        }
        layout {
            0
            |-15.FIT-titleLabel| ~ 50.FIT
            0
            |stackView|
            0
        }
        stackView.width(UIDevice.screenWidth)
        titleLabel
            .loafer_font(18, .bold)
            .loafer_textColor("F4F4F4")
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(0)
            .loafer_alignment(.fill)
            .loafer_distribution(.equalSpacing)
        loafer_isHidden(true)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AnchorDetailPopularView

class AnchorDetailPopularView: UIView, SourceProtocol {
    typealias SourceData = [(String, String)]
    
    func setSourceData(_ data: [(String, String)]) {
        loafer_isHidden(false)
        for arrangedSubview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(arrangedSubview)
        }
        for i in 0..<data.count {
            let view = AnchorDetailNormlView()
            view.setSourceData(data[i])
            view.width(UIDevice.screenWidth-20.FIT).height(50.FIT)
            stackView.addArrangedSubview(view)
            if data.count == 1 {
                view.loafer_cornerRadius(17.FIT)
            }else {
                if i == 0 {
                    view.loafer_cornerRadius(17.FIT, [.layerMinXMinYCorner, .layerMaxXMinYCorner])
                }else if i == data.count-1 {
                    view.loafer_cornerRadius(17.FIT, [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
                }
            }
        }
    }
    
    let titleLabel = UILabel()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            titleLabel.text("Popularity")
            stackView
        }
        layout {
            0
            |-15.FIT-titleLabel| ~ 50.FIT
            0
            |stackView|
            0
        }
        stackView.width(UIDevice.screenWidth)
        titleLabel
            .loafer_font(18, .bold)
            .loafer_textColor("F4F4F4")
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(0)
            .loafer_alignment(.fill)
            .loafer_distribution(.equalSpacing)
        loafer_isHidden(true)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AnchorDetailNormlView

class AnchorDetailNormlView: UIView, SourceProtocol {
    
    typealias SourceData = (String, String)
    
    func setSourceData(_ data: (String, String)) {
        titleView.loafer_text(data.0)
        valueView.loafer_text(data.1)
    }
    private let titleView = UILabel()
    private let valueView = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        loafer_backColor("FFFFFF", 0.2)
        subviews {
            titleView
            valueView
        }
        |-15.FIT-titleView-10.FIT-valueView-15.FIT-| ~ 50.FIT
        equal(widths: [titleView, valueView])
        titleView
            .loafer_font(18, .medium)
            .loafer_textColor("C7B0CE")
        valueView
            .loafer_font(18, .medium)
            .loafer_titleColor("FFFFFF")
            .loafer_contentHAlignment(.trailing)
            .loafer_numberOfLines(0)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
