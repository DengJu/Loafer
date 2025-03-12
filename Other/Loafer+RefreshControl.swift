
import MJRefresh

class RefreshHeaderView: MJRefreshHeader {
    let activityView = UIActivityIndicatorView(style: .medium)

    override func prepare() {
        super.prepare()
        mj_h = 50
        activityView.color = "FFFFFF".toColor
        addSubview(activityView)
    }

    override func placeSubviews() {
        super.placeSubviews()
        activityView.frame = CGRect(x: mj_w * 0.5 - 25, y: 0, width: 50, height: 50)
    }

    override var state: MJRefreshState {
        didSet {
            if state == .refreshing {
                activityView.startAnimating()
            } else if state == .idle {
                activityView.startAnimating()
            } else if state == .pulling {
                activityView.startAnimating()
            }
        }
    }

    override func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentOffsetDidChange(change)
    }

    override func scrollViewContentSizeDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentSizeDidChange(change)
    }

    override func scrollViewPanStateDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewPanStateDidChange(change)
    }
}


extension UIScrollView {
    @discardableResult
    func addHeaderRefreshControl(complete: @escaping MJRefreshComponentAction) -> Self {
        let header = RefreshHeaderView(refreshingBlock: complete)
        mj_header = header
        return self
    }

    @discardableResult
    func addFooterRefreshControl(complete: @escaping MJRefreshComponentAction) -> Self {
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: complete)
        footer.loadingView?.style = .medium
        footer.loadingView?.color = "FFFFFF".toColor
        footer.setTitle("", for: .idle)
        footer.setTitle("— Oops! No More Data —", for: .noMoreData)
        footer.stateLabel?.font = .setFont(14, .semiBold)
        footer.stateLabel?.textColor = "181946".toColor
        footer.isRefreshingTitleHidden = true
        mj_footer = footer
        return self
    }

    func headerEndRefresh() {
        mj_header?.endRefreshing()
    }

    func footerEndRefresh(_ isNomoreData: Bool = false) {
        if isNomoreData {
            mj_footer?.endRefreshingWithNoMoreData()
        } else {
            mj_footer?.endRefreshing()
        }
    }

    func headerEndAndFooterNoMoreData() {
        mj_header?.endRefreshing()
        footerEndRefresh(true)
    }

    func bothEndRefresh() {
        mj_header?.endRefreshing()
        footerEndRefresh(false)
    }
}
