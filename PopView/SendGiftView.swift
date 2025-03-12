
import UIKit

enum GiftViewPolicy {
    case `default`
    case Call
    
    var desc: String {
        switch self {
        case .default:
            "You can interact better with the host by giving gifts to them."
        case .Call:
            "You have accumulated \(LoaferAppSettings.Gems.ponyViewShowString) of phone calls, can you reward her with a gift."
        }
    }
}

class SendGiftView: UIView {
    
    private let descView = UILabel()
    private let giftView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let coinsStackView = UIStackView()
    private let sendBtn = UIButton(type: .custom)
    private let coinsLabel = UILabel()
    private var aHostModel: IMSocketConversationUserInfoItem?
    private var aPolicy: GiftViewPolicy = .default
    private var selectIndex: Int = 0
    
    init(hostModel: IMSocketConversationUserInfoItem, policy: GiftViewPolicy = .default) {
        super.init(frame: .zero)
        aHostModel = hostModel
        aPolicy = policy
        loafer_cornerRadius(20.FIT, [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        loafer_backColor("2F0021")
        subviews {
            descView
            giftView
            coinsStackView
            sendBtn
        }
        layout {
            0
            |descView| ~ 57.FIT
            0
            |giftView|
            20.FIT
            sendBtn.width(70.FIT).height(30.FIT)-15.FIT-|
            30.FIT
        }
        coinsStackView.leading(15.FIT).bottom(30.FIT).height(30.FIT)
        coinsStackView
            .loafer_axis(.horizontal)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalSpacing)
        descView
            .loafer_font(15, .semiBold)
            .loafer_text("Send gifts can increase the chance of reply!")
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
        sendBtn
            .loafer_font(14, .bold)
            .loafer_text("SEND")
            .loafer_cornerRadius(15.FIT)
            .loafer_titleColor("FFFFFF")
            .loafer_target(self, selector: #selector(loaferSendGiftViewSendButton(_:)))
            .setGrandient(color: .themeColor(direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: 70.FIT, height: 30.FIT))
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIDevice.screenWidth-10.FIT)/4, height: 110.FIT)
        layout.minimumLineSpacing = 12.FIT
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5.FIT, bottom: 0, right: 5.FIT)
        giftView
            .loafer_layout(layout)
            .loafer_register(GiftItem.self, GiftItem.description())
            .loafer_backColor(.clear)
            .loafer_showsHorizontalScrollIndicator(false)
            .loafer_delegate(self)
            .loafer_dataSource(self)
        coinsLabel
            .loafer_font(20, .bold)
            .loafer_text("\(LoaferAppSettings.UserInfo.user.coinBalance)")
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
        coinsStackView.addArrangedSubview(UIImageView(image: "Loafer_SendGiftView_Coins".toImage))
        coinsStackView.addArrangedSubview(coinsLabel)
        coinsStackView.addArrangedSubview(UIImageView(image: "Loafer_SendGiftView_Next".toImage))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc private func loaferSendGiftViewSendButton(_ sender: UIButton) {
        guard let aHostModel else { return }
        if LoaferAppSettings.UserInfo.user.coinBalance < LoaferAppSettings.Pony.data[selectIndex].coin {
            InsufficientPolicy.insufficientPop(type: .Pony(hostModel: aHostModel, policy: .default))
        }else {
            var model = IMSocketMessageItem()
            model.content = LoaferAppSettings.Pony.data[selectIndex].kj.JSONString()
            model.messageId = "\(Int64(Date().timeIntervalSince1970 * 1000))" + "\(Int64(arc4random_uniform(99_999_999)))"
            model.sendId = LoaferAppSettings.UserInfo.user.userId
            model.recvId = aHostModel.userId
            model.contentStatus = IMSocketMessageStatusType.UNREAD_UNDELIVERED.rawValue
            model.contentType = IMSocketMessageBodyType.GIFT.rawValue
            model.conversationId = LoaferAppSettings.URLSettings.IMPRE + "\(aHostModel.userId)&" + "\(LoaferAppSettings.UserInfo.user.userId)"
            model.times = Int64(Date().timeIntervalSince1970 * 1000)
            IMChatProvider.sendIMSocket(IMSocketSubType.CHAT.MESSAGE(model: model, user: aHostModel))
            RealmProvider.share.addMessage(model: model)
            ShowFaceAnimationView.showFaceView(from: LoaferAppSettings.Pony.data[selectIndex], aHostModel.nickname)
            PopUtil.dismiss(from: self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SendGiftView: UICollectionViewDelegate & UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LoaferAppSettings.Pony.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: GiftItem.description(), for: indexPath) as? GiftItem else { return UICollectionViewCell() }
        item.setSourceData((LoaferAppSettings.Pony.data[indexPath.row], selectIndex == indexPath.row))
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectIndex == indexPath.row {
            return
        }
        selectIndex = indexPath.row
        collectionView.reloadData()
    }
    
}

private class GiftItem: UICollectionViewCell, SourceProtocol {

    func setSourceData(_ data: (SessionResponsePonyModel, Bool)) {
        giftName.loafer_text(data.0.name)
        giftView.loadImage(url: data.0.image)
        priceLabel.loafer_text("\(data.0.coin) Coins")
        contentView.loafer_border("FF4034", data.1 ? 2 : 0)
    }
    
    private let giftView = UIImageView()
    private let giftName = UILabel()
    private let priceLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.subviews {
            giftView
            priceLabel
            giftName
        }
        contentView.layout {
            0
            |giftView|
            0
            |giftName|
            0
            |priceLabel| ~ 20
            0
        }
        giftView.centerHorizontally().size(70)
        giftView
            .loafer_contentMode(.scaleAspectFit)
        giftName
            .loafer_textColor("FAFAFA")
            .loafer_font(14, .bold)
            .loafer_textAligment(.center)
            .loafer_numberOfLines(0)
            .loafer_text("GiftName")
        priceLabel
            .loafer_font(12, .medium)
            .loafer_textColor("FAFAFA", 0.8)
            .loafer_textAligment(.center)
            .loafer_text("Price")
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension SendGiftView: PopProtocol {
    func popViewSize() -> CGSize { CGSize(width: UIDevice.screenWidth, height: UIDevice.screenWidth*(362/375)) }
    func popViewStyle() -> PopType { .bottom }
    func popScreenInteraction() -> EKAttributes.UserInteraction { .dismiss }
    func popScroll() -> EKAttributes.Scroll { .enabled(swipeable: true, pullbackAnimation: .easeOut) }
}

class VideoCallSendFaceView: UIView, SourceProtocol {
    
    func setSourceData(_ t: (SessionResponsePonyModel, String)) {
        giftView.loadImage(url: t.0.image)
        let finalString = "send to\n"+t.1
        sendLabel.loafer_attributeString(finalString, [NSAttributedString.Key.font : UIFont.setFont(16, .bold)], NSRange(location: finalString.count-t.1.count, length: t.1.count))
    }

    private let giftView = UIImageView()
    
    private lazy var sendLabel: UILabel = {
        $0
            .loafer_font(14, .medium)
            .loafer_textColor("FAFAFA")
            .loafer_text("send to")
            .loafer_numberOfLines(2)
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loafer_cornerRadius(25.FIT)
        loafer_clipsToBounds(true)
        subviews {
            giftView
            sendLabel
        }
        |-10.FIT-sendLabel.centerVertically()-0-giftView.centerVertically().size(40.FIT)-5.FIT-|
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        let gLayer = CAGradientLayer()
        gLayer.frame = CGRect(x: 0, y: 0, width: 158.FIT, height: 50.FIT)
        gLayer.locations = [0, 1]
        gLayer.startPoint = CGPoint(x: 0, y: 0)
        gLayer.endPoint = CGPoint(x: 1, y: 0)
        gLayer.colors = ["FD0682".toColor.cgColor, "FF9565".toColor.cgColor]
        layer.insertSublayer(gLayer, at: 0)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public struct Queue<T> {
    fileprivate var list = [T]()

    private var isEmpty: Bool {
        return list.count == 0
    }

    public mutating func enQueue(_ element: T) {
        list.append(element)
    }

    @discardableResult
    public mutating func deQueue() -> T? {
        if list.isEmpty == false {
            let first = list.first
            list.remove(at: 0)
            return first
        } else {
            return nil
        }
    }

    public func peek() -> T? {
        return list.first
    }
}


class ShowFaceAnimationView: NSObject {
    
    static var isShowingFace: Bool = false
    static var faceQueue = Queue<VideoCallSendFaceView>()
    static var faceModel: SessionResponsePonyModel?
    
    static func showFaceView(from faceModel: SessionResponsePonyModel, _ userName: String) {
        ShowFaceAnimationView.faceModel = faceModel
        let faceView = VideoCallSendFaceView()
        faceView.setSourceData((faceModel, userName))
        ShowFaceAnimationView.faceQueue.enQueue(faceView)
        addFaceView()
    }
    
    static func addFaceView() {
        guard !ShowFaceAnimationView.isShowingFace else { return }
        guard let aFaceView = ShowFaceAnimationView.faceQueue.peek() else { return }
        UIApplication.mainWindow.subviews { aFaceView }
        ShowFaceAnimationView.isShowingFace = true
        aFaceView.leading(UIDevice.screenWidth).top(UIDevice.screenHeight * 0.35).width(158.FIT).height(50.FIT)
        perform(#selector(ShowFaceAnimationView.updateShowPonyView(_:)), with: aFaceView, afterDelay: 0.5)
    }
    
    @objc static func updateShowPonyView(_ view: UIView) {
        view.leadingConstraint?.constant = 15.FIT
        UIView.animate(withDuration: 0.35) {
            UIApplication.mainWindow.layoutIfNeeded()
        } completion: { _ in
            perform(#selector(ShowFaceAnimationView.removeShowPonyView(_:)), with: view, afterDelay: 1.5)
        }
    }

    @objc static func removeShowPonyView(_ view: UIView) {
        view.leadingConstraint?.constant = -158.FIT
        UIView.animate(withDuration: 0.35) {
            UIApplication.mainWindow.layoutIfNeeded()
        } completion: { _ in
            ShowFaceAnimationView.isShowingFace = false
            view.removeFromSuperview()
            ShowFaceAnimationView.faceQueue.deQueue()
            ShowFaceAnimationView.addFaceView()
        }
    }
    
}
