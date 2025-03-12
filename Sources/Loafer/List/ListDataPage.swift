
import UIKit
import JXSegmentedView

class ListDataPage: LoaferPage {
    
    var segmentedDataSource: JXSegmentedBaseDataSource?
    let segmentedView = JXSegmentedView(frame: .zero)
    lazy var listContainerView: JXSegmentedListContainerView! = JXSegmentedListContainerView(dataSource: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: "Loafer_ListPage_TitleView".toImage))
        view.subviews {
            segmentedView
            listContainerView!
        }
        view.layout {
            UIDevice.topFullHeight + 10.FIT
            |-15.FIT-segmentedView-15.FIT-| ~ 50.FIT
            10.FIT
            |listContainerView!|
            0
        }
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.titleNormalColor = "FFFFFF".toColor.withAlphaComponent(0.4)
        dataSource.titleSelectedColor = "FFFFFF".toColor
        dataSource.titleNormalFont = .setFont(18, .semiBold)
        dataSource.titleSelectedFont = .setFont(18, .bold)
        dataSource.isItemSpacingAverageEnabled = true
        dataSource.itemSpacing = 0
        dataSource.itemWidth = (UIDevice.screenWidth - 30.FIT) / 3
        dataSource.titles = ["All", "Popular", "New"]
        segmentedDataSource = dataSource

        let indicator = JXSegmentedIndicatorGradientLineView()
        indicator.colors = ["FE269C".toColor, "FE269C".toColor]
        indicator.indicatorHeight = 40.FIT
        indicator.indicatorCornerRadius = 20.FIT
        indicator.indicatorWidthIncrement = -10.FIT
        indicator.indicatorPosition = .center

        segmentedView.indicators = [indicator]
        segmentedView.dataSource = segmentedDataSource
        segmentedView.delegate = self
        segmentedView.loafer_backColor("FFFFFF", 0.2)
        segmentedView.loafer_cornerRadius(25.FIT)
        segmentedView.listContainer = listContainerView
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "REFRESH-USER-BALANCE"), object: nil, queue: .main) {[weak self] _ in
            self?.refreshRightItem()
        }
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
    
}
extension ListDataPage: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let dotDataSource = segmentedDataSource as? JXSegmentedDotDataSource {
            dotDataSource.dotStates[index] = false
            segmentedView.reloadItem(at: index)
        }
    }
}

extension ListDataPage: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in _: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return AnchorPage()
    }
}
