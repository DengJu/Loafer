
import UIKit
import JXSegmentedView

class AnchorPage: LoaferPage {
    
    private let anchorView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var currentPage = 1
    private var dataSource: [SessionResponseHostListModel] = []
    private let noDataStatus = Status(description: "The current list is nothing~", image: "Loafer_EmptyPage_Box".toImage)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        backGroundImageView.loafer_isHidden(true)
        view.subviews {
            anchorView
        }
        anchorView.fillContainer()
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5.FIT
        layout.minimumInteritemSpacing = 5.FIT
        layout.sectionInset = UIEdgeInsets(top: 10.FIT, left: 10.FIT, bottom: 10.FIT, right: 10.FIT)
        layout.itemSize = CGSize(width: (UIDevice.screenWidth-30.FIT)/2, height: (UIDevice.screenWidth-30.FIT)/2*(255/175))
        anchorView
            .loafer_layout(layout)
            .loafer_delegate(self)
            .loafer_dataSource(self)
            .loafer_showsVerticalScrollIndicator(false)
            .loafer_backColor(.clear)
            .loafer_register(AnchorItem.self, AnchorItem.description())
            .addHeaderRefreshControl {[weak self] in
                self?.loadData()
            }
        anchorView.show(status: loadingStatus)
        loadData()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "BLOCK-USER-NOTIFICATION"), object: nil, queue: nil) {[weak self] _ in
            self?.loadData()
        }
    }
    
    func loadData() {
        currentPage = 1
        loadSource()
    }
    
    func loadMore() {
        currentPage += 1
        loadSource()
    }
    
    func loadSource() {
        URLSessionProvider.request(.URLInterfaceHostList(model: SessionRequestHostListModel(page: currentPage)), type: [SessionResponseHostListModel].self)
            .compactMap({ $0.data })
            .done {[weak self] result in
                guard let `self` = self else { return }
                if self.currentPage <= 1 {
                    self.dataSource.removeAll()
                    if !result.isEmpty {
                        self.dataSource = result
                    }
                    if result.count < 12 {
                        self.anchorView.headerEndAndFooterNoMoreData()
                    }else {
                        self.anchorView.headerEndRefresh()
                        self.anchorView.addFooterRefreshControl {[weak self] in
                            self?.loadMore()
                        }
                    }
                }else {
                    if !result.isEmpty {
                        self.dataSource.append(contentsOf: result)
                    }
                    if result.count < 12 {
                        self.anchorView.headerEndAndFooterNoMoreData()
                    }else {
                        self.anchorView.footerEndRefresh(false)
                    }
                }
                DispatchQueue.main.async {
                    if self.dataSource.isEmpty {
                        self.anchorView.show(status: self.noDataStatus)
                    }else {
                        self.anchorView.hideStatus()
                    }
                    self.anchorView.reloadData()
                }
            }
            .catch {[weak self] error in
                error.handle()
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.anchorView.show(status: self.noDataStatus)
                    self.anchorView.bothEndRefresh()
                }
            }
    }

}

extension AnchorPage: UICollectionViewDelegate & UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: AnchorItem.description(), for: indexPath) as? AnchorItem else { return UICollectionViewCell() }
        item.setSourceData(dataSource[indexPath.row])
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let page = AnchorDetailPage()
        page.setSourceData(dataSource[indexPath.row].userId)
        navigationController?.pushViewController(page, animated: true)
    }
    
}

extension AnchorPage: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

private class AnchorItem: UICollectionViewCell, SourceProtocol {
    
    func setSourceData(_ data: SessionResponseHostListModel) {
        hostModel = data
        mainView.loadImage(url: data.avatar)
        nameView.loafer_text(data.nickname)
        if data.onlineStatus == 0 {
            statusView.loafer_backColor("02FF76")
        }else if data.onlineStatus == 1 {
            statusView.loafer_backColor("D3D3D3")
        }else if data.onlineStatus == 2 {
            statusView.loafer_backColor("FF0202")
        }
        countryView.loafer_text(LoaferAppSettings.queryCountryInfo("\(data.country)")?.1 ?? "")
        socialButton.loafer_isSelect(data.onlineStatus > 0)
    }
    
    private var hostModel: SessionResponseHostListModel?
    private let mainView = UIImageView(image: "Loafer_Basic_Empty".toImage)
    private let nameView = UILabel()
    private let countryView = UILabel()
    private let statusView = UIView()
    private let stackView = UIStackView()
    private let socialButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.loafer_cornerRadius(10.FIT)
        contentView.loafer_clipsToBounds(true)
        contentView.subviews {
            mainView
            nameView
            stackView
            socialButton
        }
        mainView.fillContainer()
        socialButton.trailing(10.FIT).bottom(10.FIT).size(45.FIT)
        stackView.leading(10.FIT).bottom(15.FIT).height(15.FIT)
        stackView.Trailing == socialButton.Leading - 10.FIT
        nameView.Bottom == stackView.Top - 2.FIT
        nameView.leading(10.FIT).height(19.FIT)
        nameView.Trailing == socialButton.Leading - 10.FIT
        statusView.size(12.FIT)
        stackView.addArrangedSubview(statusView)
        stackView.addArrangedSubview(countryView)
        stackView
            .loafer_axis(.horizontal)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.fill)
        nameView
            .loafer_font(15, .bold)
            .loafer_text("Name")
            .loafer_textColor("FFFFFF")
            .setShadowText()
        countryView
            .loafer_font(11, .medium)
            .loafer_text("Country name")
            .loafer_textColor("FFFFFF")
            .setShadowText()
        statusView
            .loafer_backColor("1BC348")
            .loafer_cornerRadius(6.FIT)
            .loafer_border("FFFFFF", 1.FIT)
        socialButton
            .loafer_image("Loafer_ListPage_VideoCall", .normal)
            .loafer_image("Loafer_ListPage_Chat", .selected)
            .loafer_target(self, selector: #selector(loaferAnchorPageSocialButton(_:)))
    }
    
    @objc private func loaferAnchorPageSocialButton(_ sender: UIButton) {
        guard let hostModel else { return }
        if sender.isSelected {
            guard let page = iq.parentContainerViewController() else { return }
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
            page.navigationController?.pushViewController(chatPage, animated: true)
        }else {
            if LoaferAppSettings.UserInfo.user.coinBalance < hostModel.callPrice {
                InsufficientPolicy.insufficientPop(type: .CallPre(hostModel: hostModel))
            }else {
                LoaferAppSettings.AOP.callSource = "主播列表"
                CallUtil.call(to: hostModel.userId)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
