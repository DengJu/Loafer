

import UIKit

class RechargeGemsView: LoaferPage {
    
    private let balanceView = BalanceView()
    private let gemsView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let closeBtn = UIButton(type: .custom)
    private let nameView = UILabel()
    private var dataSource: [SessionResponseGemsListModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews {
            closeBtn
            nameView
            balanceView
            gemsView
        }
        closeBtn.leading(15.FIT).top(UIDevice.safeTop).size(45.FIT)
        nameView.centerHorizontally().top(UIDevice.safeTop).height(44.FIT)
        balanceView.top(UIDevice.safeTop+7.FIT).trailing(15.FIT)
        gemsView.top(UIDevice.topFullHeight + 10.FIT).leading(0).trailing(0).bottom(0)
        closeBtn
            .loafer_image("Loafer_AnchorDetailPage_Close")
            .loafer_target(self, selector: #selector(loaferRechargeGemsViewCloseBtn))
        nameView
            .loafer_font(21, .bold)
            .loafer_textColor("E1D2EA")
            .loafer_text("Recharge")
            .loafer_textAligment(.center)
        balanceView.loafer_isUserInteractionEnabled(false)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIDevice.screenWidth-48.FIT)/2, height: 210.FIT)
        layout.minimumLineSpacing = 15.FIT
        layout.minimumInteritemSpacing = 15.FIT
        layout.sectionInset = UIEdgeInsets(top: 15.FIT, left: 15.FIT, bottom: 15.FIT, right: 15.FIT)
        gemsView
            .loafer_layout(layout)
            .loafer_register(RechargeGemsItem.self, RechargeGemsItem.description())
            .loafer_delegate(self)
            .loafer_dataSource(self)
            .loafer_backColor(.clear)
            .loafer_showsVerticalScrollIndicator(false)
        URLSessionProvider.request(.URLInterfaceGemsList, type: [SessionResponseGemsListModel].self)
            .compactMap { $0.data }
            .done {[weak self] result in
                guard let `self` = self else { return }
                if !self.dataSource.isEmpty {
                    self.dataSource.removeAll()
                }
                self.dataSource = result
                DispatchQueue.main.async {
                    self.gemsView.reloadData()
                }
            }
            .catch { error in
                error.handle()
            }
    }
    
    @objc private func loaferRechargeGemsViewCloseBtn() {
        PopUtil.dismiss(from: self)
    }
    
}

extension RechargeGemsView: UICollectionViewDelegate & UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: RechargeGemsItem.description(), for: indexPath) as? RechargeGemsItem else { return UICollectionViewCell() }
        item.setSourceData(dataSource[indexPath.row])
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task {
            await StoreKit2Util.purchase(dataSource[indexPath.row])
        }
    }
    
}

extension RechargeGemsView: PopProtocol {
    func popViewSize() -> CGSize { CGSize(width: UIDevice.screenWidth, height: UIDevice.screenHeight) }
    func popViewStyle() -> PopType { .bottom }
    func popScreenInteraction() -> EKAttributes.UserInteraction { .dismiss }
    func popScroll() -> EKAttributes.Scroll { .enabled(swipeable: true, pullbackAnimation: .easeOut) }
}

class RechargeGemsItem: UICollectionViewCell, SourceProtocol {
    
    typealias SourceData = SessionResponseGemsListModel
    
    func setSourceData(_ data: SessionResponseGemsListModel) {
        if data.extraCoin > 0 {
            let array = ["\(data.originalCoin)", "+", "\(data.extraCoin)"]
            for i in 0..<array.count {
                let label = UILabel()
                label
                    .loafer_font(21, .bold)
                    .loafer_text(array[i])
                    .loafer_textColor(i>0 ? "FFDC1A" : "FFFFFF")
                    .loafer_textAligment(.center)
                gemsStackView.addArrangedSubview(label)
            }
        }else {
            let label = UILabel()
            label
                .loafer_font(21, .bold)
                .loafer_text("\(data.totalCoin)")
                .loafer_textColor("FFFFFF")
                .loafer_textAligment(.center)
            gemsStackView.addArrangedSubview(label)
        }
        priceBtn.loafer_text("$ \(data.price)")
        descBtn.loafer_contentEdge(0, 10.FIT, 0, 10.FIT, UIFont.setFont(14, .bold), data.words, "FFFF84")
        descBtn.loafer_isHidden(data.words.isEmpty)
    }
    
    private let gemsView = UIImageView(image: "Loafer_RechargeGemsView_1".toImage)
    private let gemsStackView = UIStackView()
    private let priceBtn = UIButton(type: .custom)
    private let descBtn = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loafer_clipsToBounds(true)
        loafer_cornerRadius(20.FIT)
        setGrandient(color: .themeColor(direction: .top2Bottom), bounds: CGRect(x: 0, y: 0, width: ((UIDevice.screenWidth-48.FIT)/2), height: 210.FIT*(210/165)))
        contentView.subviews {
            gemsView
            gemsStackView
            priceBtn
            descBtn
        }
        contentView.layout {
            10.FIT
            |gemsView| ~ 90.FIT
            10.FIT
            gemsStackView.centerHorizontally().width(<=((UIDevice.screenWidth-48.FIT)/2)) ~ 26.FIT
            >=0
            |-15.FIT-priceBtn-15.FIT-| ~ 42.FIT
            15.FIT
        }
        descBtn.top(0).centerHorizontally().height(27.FIT)
        gemsStackView
            .loafer_axis(.horizontal)
            .loafer_spacing(0)
            .loafer_alignment(.center)
            .loafer_distribution(.equalCentering)
        descBtn
            .loafer_backColor("000000", 0.1)
            .loafer_cornerRadius(10.FIT, [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
            .loafer_isUserInteractionEnabled(false)
        priceBtn
            .loafer_font(19, .bold)
            .loafer_titleColor("FF26C5")
            .loafer_text("$ 0.99")
            .loafer_cornerRadius(21.FIT)
            .loafer_isUserInteractionEnabled(false)
            .setGrandient(color: .customColor(colors: ["FFF365".toColor, "FFF795".toColor], direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: ((UIDevice.screenWidth-48.FIT)/2)-30.FIT, height: 42.FIT))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
