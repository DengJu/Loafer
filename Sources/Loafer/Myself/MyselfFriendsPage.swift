
import UIKit

class MyselfFriendsPage: LoaferPage {
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var noDataStatus = Status()
    private var currentPage: Int32 = 1
    private var friends: [SessionResponseHostListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        show(status: loadingStatus)
        noDataStatus = Status(description: "The current list is nothing~", image: "Loafer_EmptyPage_Box".toImage) {[weak self] in
            self?.refreshData()
        }
        navigationItem.title = "Friends"
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
        URLSessionProvider.request(.URLInterfaceHostList(model: SessionRequestHostListModel(type: "FOLLOW")), type: [SessionResponseHostListModel].self)
            .compactMap{ $0.data }
            .done {[weak self] result in
                guard let `self` = self else { return }
                if self.currentPage <= 1 {
                    self.friends.removeAll()
                    if !result.isEmpty {
                        self.friends = result
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
                        self.friends.append(contentsOf: result)
                    }
                    if result.count < 12 {
                        self.collectionView.headerEndAndFooterNoMoreData()
                    }else {
                        self.collectionView.footerEndRefresh(false)
                    }
                }
                DispatchQueue.main.async {
                    if self.friends.isEmpty {
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

extension MyselfFriendsPage: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: BlockOrFollowItem.description(), for: indexPath) as? BlockOrFollowItem else { return UICollectionViewCell() }
        item.type = .Follow
        item.setSourceData(friends[indexPath.row])
        item.funcItemHandle = {[weak self] in
            self?.loadData()
        }
        return item
    }
    
}
