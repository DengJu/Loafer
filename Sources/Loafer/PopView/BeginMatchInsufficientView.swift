
import UIKit

struct InsufficientPolicy {
    static func insufficientPop(type: InsufficientBalanceType) { type.popup() }
}

enum InsufficientBalanceType {
    case `default`
    case CallPre(hostModel: SessionResponseHostListModel)
    case CallingPolicy(hostModel: SessionResponseHostListModel)
    case Pony(hostModel: IMSocketConversationUserInfoItem, policy: GiftViewPolicy)
    case SendMessage(hostModel: SessionResponseHostListModel)
    case UnlockVideo(hostModel: SessionResponseHostListModel, videoModel: SessionResponseHostVideoModel)
    
    var desc: String {
        switch self {
        case .CallPre(let model):
            LoaferAppSettings.AOP.rechargeSource = [LoaferAppSettings.AOP.callSource, "Call_Request_Insufficient"].joined(separator: "_")
            return "You need \(model.callPrice) coins to call " + model.nickname
        case .CallingPolicy(let model):
            LoaferAppSettings.AOP.rechargeSource = "Calling_Insufficient"
            return "Your coins are insufficient. Recharge to continue talking to \(model.nickname)."
        case .Pony(let model, _):
            LoaferAppSettings.AOP.rechargeSource = "Send_Gift_Insufficient"
            return "If you send a gift to \(model.nickname), she will surprise you."
        case .SendMessage(let model):
            LoaferAppSettings.AOP.rechargeSource = "Send_Messages_Insufficient"
            return "Your coins are insufficient. Recharge to continue chatting with \(model.nickname)."
        case .UnlockVideo(let model, let videoModel):
            LoaferAppSettings.AOP.rechargeSource = "Unlock_Video_Insufficient"
            return "You need \(videoModel.coin) coins to watch the video uploaded by \(model.nickname)."
        case .default:
            LoaferAppSettings.AOP.rechargeSource = "Service_Return_Insufficient"
            return "More sexy girls are waiting for you get coins to meet them."
        }
    }
    
    var lastPopView: PopProtocol? {
        switch self {
        case let .Pony(model, policy):
            return SendGiftView(hostModel: model, policy: policy)
        default: return nil
        }
    }
    
    var hostAvatar: String? {
        switch self {
        case .CallPre(let model): return model.avatar
        case .CallingPolicy(let model): return model.avatar
        case .Pony(let model, _): return model.avatar
        case .SendMessage(let model): return model.avatar
        case .UnlockVideo(let model, _): return model.avatar
        case .default: return nil
        }
    }
    
    func popup() {
        if !LoaferAppSettings.UserInfo.user.isRecharge && LoaferAppSettings.Gems.isNeedPopup {
            let aView = NewUserGemsGuideView()
            aView.setSourceData(LoaferAppSettings.Gems.avtiveItems!)
            PopUtil.pop(show: aView)
            return
        }
        if let limitData = LoaferAppSettings.Gems.limitOnceItems {
            let aView = NewUserGemsGuideView()
            aView.isMuteCutDown = true
            aView.setSourceData(limitData)
            PopUtil.pop(show: aView)
            return
        }
        PopUtil.pop(show: BeginMatchInsufficientView(self))
    }
    
}

class BeginMatchInsufficientView: UIView {
    
    private let backgroundView = UIImageView(image: "Loafer_BeginMatchInsufficientView_BackImage".toImage)
    private let anchorStackView = UIStackView()
    private let descView = UILabel()
    private let itemsView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let closeBtn = UIButton(type: .custom)
    private var type: InsufficientBalanceType = .default
    private var items: [SessionResponseGemsListModel] = LoaferAppSettings.Gems.data.filter({ $0.isRecommend == true })
    
    init(_ type: InsufficientBalanceType = .default) {
        self.type = type
        StoreKit2Util.rechargeType = type
        super.init(frame: .zero)
        subviews {
            backgroundView.subviews {
                anchorStackView
                descView
                itemsView
            }
            closeBtn
        }
        backgroundView.centerHorizontally().centerVertically(offset: -50.FIT).width(UIDevice.screenWidth).height(UIDevice.screenWidth*(445/375))
        backgroundView.loafer_contentMode(.scaleAspectFill)
        backgroundView.loafer_isUserInteractionEnabled(true)
        backgroundView.layout {
            50.FIT
            anchorStackView.centerHorizontally() ~ 100.FIT
            20.FIT
            |-30.FIT-descView-30.FIT-|
            15.FIT
            |itemsView|
            10.FIT
        }
        descView.height(<=100.FIT)
        closeBtn.centerHorizontally().size(45.FIT)
        closeBtn.Top == backgroundView.Bottom + 30.FIT
        anchorStackView
            .loafer_axis(.horizontal)
            .loafer_spacing(-26.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalCentering)
        descView
            .loafer_font(17, .medium)
            .loafer_text(type.desc)
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
            .loafer_numberOfLines(0)
        closeBtn
            .loafer_image("Loafer_NewUserRechargeView_Close")
            .loafer_target(self, selector: #selector(loaferBeginMatchInsufficientViewCloseBtn))
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20.FIT, bottom: 0, right: 20.FIT)
        layout.itemSize = CGSize(width: UIDevice.screenWidth-70.FIT, height: 80.FIT)
        layout.minimumInteritemSpacing = 10.FIT
        layout.minimumLineSpacing = 10.FIT
        itemsView
            .loafer_layout(layout)
            .loafer_register(GemsItemView.self, GemsItemView.description())
            .loafer_backColor(.clear)
            .loafer_delegate(self)
            .loafer_dataSource(self)
        for i in 0..<2 {
            let avatar = UIImageView()
            avatar.loafer_backColor(.randomColor)
            avatar.layer.zPosition = 1
            avatar.size(100.FIT)
            avatar.loafer_cornerRadius(50.FIT)
            if i == 0 {
                avatar.loadImage(url: LoaferAppSettings.UserInfo.user.avatar)
            }else {
                if let urlString = type.hostAvatar {
                    avatar.loadImage(url: urlString)
                }
            }
            anchorStackView.addArrangedSubview(avatar)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fatalError("init(type:) has not been implemented")
    }
    
    @objc private func loaferBeginMatchInsufficientViewCloseBtn() {
        PopUtil.dismiss(from: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension BeginMatchInsufficientView: UICollectionViewDelegate & UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: GemsItemView.description(), for: indexPath) as? GemsItemView else { return UICollectionViewCell() }
        item.setSourceData(items[indexPath.row])
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task {
            await StoreKit2Util.purchase(items[indexPath.row])
        }
    }
    
}

extension BeginMatchInsufficientView: PopProtocol {
    func popViewSize() -> CGSize { CGSize(width: UIDevice.screenWidth, height: UIDevice.screenHeight) }
    func popViewStyle() -> PopType { .center }
    func popScreenInteraction() -> EKAttributes.UserInteraction { .init() }
    func popScroll() -> EKAttributes.Scroll { .disabled }
}

private class GemsItemView: UICollectionViewCell, SourceProtocol {
    
    func setSourceData(_ data: SessionResponseGemsListModel) {
        priceBtn.loafer_text("$\(data.price)")
        if data.extraCoin > 0 {
            gemsView.loafer_text("\(data.originalCoin) + \(data.extraCoin)")
        }else {
            gemsView.loafer_text("\(data.totalCoin)")
        }
        descView.loafer_contentEdge(0, 8.FIT, 0, 8.FIT, UIFont.setFont(14, .bold), data.words, "FF26C5")
        descView.loafer_isHidden(data.words.isEmpty)
    }
    
    private let coinsView = UIImageView(image: "Loafer_BeginMatchInsufficientView_Gems".toImage)
    private let gemsView = UILabel()
    private let descView = UIButton(type: .custom)
    private let priceBtn = UIButton(type: .custom)
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.loafer_cornerRadius(25.FIT)
        contentView.setGrandient(color: .customColor(colors: ["FFF795".toColor, "FFF365".toColor], direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: UIDevice.screenWidth-70.FIT, height: 80.FIT))
        contentView.subviews {
            coinsView
            priceBtn
            stackView
        }
        |-18.FIT-coinsView.centerVertically().size(40.FIT)-8.FIT-stackView.centerVertically()-8.FIT-priceBtn.centerVertically().width(97.FIT).height(36.FIT)-15.FIT-|
        descView.height(20.FIT)
        stackView.addArrangedSubview(gemsView)
        stackView.addArrangedSubview(descView)
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(0)
            .loafer_alignment(.leading)
            .loafer_distribution(.equalSpacing)
        priceBtn
            .loafer_font(21, .bold)
            .loafer_text("$0.99")
            .loafer_titleColor("FFFFFF")
            .loafer_backColor("FF26C5")
            .loafer_cornerRadius(18.FIT)
            .loafer_isUserInteractionEnabled(false)
        gemsView
            .loafer_font(25, .bold)
            .loafer_textColor("FF26C5")
            .loafer_text("0")
        descView
            .loafer_backColor("FF26C5")
            .loafer_cornerRadius(10.FIT)
            .loafer_isUserInteractionEnabled(false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
