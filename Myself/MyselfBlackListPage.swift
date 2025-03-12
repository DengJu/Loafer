
import UIKit

class MyselfBlackListPage: LoaferPage {

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var noDataStatus = Status()
    private var currentPage: Int32 = 1
    private var blocks: [SessionResponseHostListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        show(status: loadingStatus)
        noDataStatus = Status(description: "The current list is nothing~", image: "Loafer_EmptyPage_Box".toImage) {[weak self] in
            self?.refreshData()
        }
        navigationItem.title = "Blocklist"
        view.subviews(collectionView)
        collectionView.followEdges(view, top: UIDevice.topFullHeight)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIDevice.screenWidth, height: 80.FIT)
        collectionView.style { v in
            v.collectionViewLayout = layout
            v.delegate = self
            v.dataSource = self
            v.backgroundColor = .clear
            v.showsVerticalScrollIndicator = false
            v.register(BlockOrFollowItem.self, forCellWithReuseIdentifier: BlockOrFollowItem.description())
            v.addHeaderRefreshControl {[weak self] in
                self?.refreshData()
            }
        }
        refreshData()
    }
    
    private func refreshData() {
        currentPage = 1
        loadData()
    }
    
    private func loadMore() {
        currentPage += 1
        loadData()
    }
    
    private func loadData() {
        URLSessionProvider.request(.URLInterfaceBlockList(model: SessionRequestBlockModel(page: currentPage)), type: [SessionResponseHostListModel].self)
            .compactMap{ $0.data }
            .done {[weak self] result in
                guard let `self` = self else { return }
                if self.currentPage <= 1 {
                    self.blocks.removeAll()
                    if !result.isEmpty {
                        self.blocks = result
                    }
                    if result.count < 12 {
                        self.collectionView.headerEndAndFooterNoMoreData()
                    }else {
                        self.collectionView.addFooterRefreshControl {[weak self] in
                            self?.loadMore()
                        }
                    }
                }else {
                    if !result.isEmpty {
                        self.blocks.append(contentsOf: result)
                    }
                    if result.count < 12 {
                        self.collectionView.headerEndAndFooterNoMoreData()
                    }else {
                        self.collectionView.footerEndRefresh(false)
                    }
                }
                DispatchQueue.main.async {
                    if self.blocks.isEmpty {
                        self.show(status: self.noDataStatus)
                    }else {
                        self.hideStatus()
                    }
                    self.collectionView.reloadData()
                }
            }
            .catch { error in
                error.handle()
            }
    }
    
}

extension MyselfBlackListPage: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        blocks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: BlockOrFollowItem.description(), for: indexPath) as? BlockOrFollowItem else { return UICollectionViewCell() }
        item.setSourceData(blocks[indexPath.row])
        item.funcItemHandle = {[weak self] in
            self?.loadData()
        }
        return item
    }
    
}

class BlockOrFollowItem: UICollectionViewCell, SourceProtocol {
    
    typealias SourceData = SessionResponseHostListModel
    
    enum BlockOrFollowItemType {
        case Block
        case Follow
    }
    
    private let iConView = UIImageView(image: "Loafer_Basic_EmptyIcon".toImage)
    private let statusView = UIView()
    private let nameView = UILabel()
    private let funcBtn = UIButton(type: .custom)
    
    var type: BlockOrFollowItemType = .Block
    private var hostModel: SessionResponseHostListModel!
    
    var funcItemHandle: (() -> Void)?
    
    func setSourceData(_ data: SessionResponseHostListModel) {
        hostModel = data
        iConView.loadImage(url: data.avatar)
        nameView.text = data.nickname
        if data.onlineStatus == 0 {
            statusView.backgroundColor = "1BC348".toColor
        }else if data.onlineStatus == 1 {
            statusView.backgroundColor = "D3D3D3".toColor
        }else {
            statusView.backgroundColor = "FF2B2B".toColor
        }
        if type == .Block {
            funcBtn.setTitle("Remove", for: .normal)
        }else {
            funcBtn.setTitle("Unfollow", for: .normal)
            funcBtn.titleLabel?.font = .setFont(14, .medium)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.subviews {
            iConView
            statusView
            nameView
            funcBtn
        }
        |-15.FIT-iConView.size(50.FIT).centerVertically()-10.FIT-nameView.centerVertically()-10.FIT-funcBtn.centerVertically().width(100.FIT).height(38.FIT)-15.FIT-|
        statusView.size(12.FIT)
        statusView.Bottom == iConView.Bottom
        statusView.Trailing == iConView.Trailing
        nameView
            .loafer_font(17, .bold)
            .loafer_textColor("FFFFFF")
        funcBtn
            .loafer_font(18, .bold)
            .loafer_titleColor("FFFFFF")
            .loafer_cornerRadius(19.FIT)
            .loafer_target(self, selector: #selector(completionBlockOrFollowItemFuncButton(_:)))
            .setGrandient(color: .themeColor(direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: 100.FIT, height: 38.FIT))
        iConView
            .loafer_contentMode(.scaleAspectFill)
            .loafer_cornerRadius(18.FIT)
        statusView
            .loafer_cornerRadius(6.FIT)
            .loafer_border("FFFFFF", 1.FIT)
    }
    
    @objc private func completionBlockOrFollowItemFuncButton(_ sender: UIButton) {
        guard let hostModel else { return }
        if type == .Block {
            URLSessionProvider.request(.URLInterfaceBlock(model: SessionRequestBlockStatusModel(blackUserId: self.hostModel.userId, black: false)))
                .compactMap{$0.data}
                .done {[weak self] _ in
                    guard let `self` = self else { return }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BLOCK-USER-NOTIFICATION"), object: nil)
                    DispatchQueue.main.async {
                        if let conv = RealmProvider.share.queryConversation(from: LoaferAppSettings.URLSettings.IMPRE + "\(self.hostModel.userId)&" + "\(LoaferAppSettings.UserInfo.user.userId)") {
                            RealmProvider.share.openTransaction { realm in
                                conv.isBlock = false
                            }
                        }
                    }
                    if let closure = self.funcItemHandle {
                        closure()
                    }
                }
                .catch { error in
                    error.handle()
                }
        }else {
            sender.isUserInteractionEnabled = false
            URLSessionProvider.request(.URLInterfaceFollow(model: SessionRequestFollowModel(followUserId: hostModel.userId, follow: false)))
                .compactMap { $0.data }
                .done {[weak self] result in
                    debugPrint(result)
                    if let closure = self?.funcItemHandle {
                        closure()
                    }
                }
                .ensure {
                    sender.isUserInteractionEnabled = true
                }
                .catch { error in
                    error.handle()
                }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
