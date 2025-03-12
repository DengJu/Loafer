
import UIKit

class NewUserGemsGuideView: UIView, SourceProtocol {
    
    func setSourceData(_ data: SessionResponseGemsListModel) {
        source = data
        priceView.loafer_text("$ \(data.originalPrice)")
        gemsView.loafer_text("\(data.totalCoin) Coins")
        descView.loafer_text(data.words)
    }
    
    
    var isMuteCutDown: Bool = false {
        didSet {
            timeView.loafer_isHidden(isMuteCutDown)
            if !isMuteCutDown {
                NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "PASSCUTTIMETOFIRSTGUIDEVIEW"), object: nil, queue: .main) {[weak self] noti in
                    guard let `self` = self, let string = noti.object as? String else { return }
                    self.timeView.loafer_text(string)
                    if !self.isMuteCutDown {
                        self.timeView.isHidden = false
                    }
                }
            }
        }
    }
    
    private var source: SessionResponseGemsListModel?
    private let timeView = UIButton(type: .custom)
    private let closeView = UIButton(type: .custom)
    private let gemsView = UILabel()
    private let priceView = UIButton(type: .custom)
    private let offView = UILabel()
    private let descView = UILabel()
    private let continueBtn = UIButton(type: .custom)
    private let gemsStackView = UIStackView()
    private let descStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loafer_cornerRadius(30.FIT)
        loafer_backColor(.randomColor)
        subviews {
            timeView
            closeView
            gemsStackView
            descStackView
            continueBtn
        }
        layout {
            15.FIT
            |-20.FIT-timeView.width(120.FIT).height(30.FIT)
            >=0
            gemsStackView.centerHorizontally() ~ 43.FIT
            0
            descStackView.centerHorizontally() ~ 25.FIT
            30.FIT
            |-30.FIT-continueBtn-30.FIT-| ~ 50.FIT
            20.FIT
        }
        closeView.trailing(15.FIT).top(15.FIT).size(40.FIT)
        priceView.height(22.FIT).width(>=85.FIT)
        offView.width(<=100.FIT)
        gemsStackView.addArrangedSubview(gemsView)
        gemsStackView.addArrangedSubview(priceView)
        descStackView.addArrangedSubview(offView)
        descStackView.addArrangedSubview(descView)
        timeView
            .loafer_backColor("000000", 0.6)
            .loafer_font(16, .bold)
            .loafer_image("Loafer_NewUserGemsGuideView_Time")
            .loafer_cornerRadius(15.FIT)
            .loafer_titleColor("FE269C")
            .loafer_isUserInteractionEnabled(false)
            .loafer_text(" 00:00:00")
        closeView
            .loafer_image("Loafer_NewUserGemsGuideView_Close")
            .loafer_target(self, selector: #selector(loaferNewUserGemsGuideViewCloseBtn))
        gemsStackView
            .loafer_axis(.horizontal)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalCentering)
        descStackView
            .loafer_axis(.horizontal)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalCentering)
        gemsView
            .loafer_font(35, .extraBoldItalic)
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
            .loafer_text("250 Coins")
        priceView
            .loafer_backImage("Loafer_NewUserGemsGuideView_PriceBack")
            .loafer_font(20, .boldItalic)
            .loafer_titleColor("FFFFFF")
            .loafer_isUserInteractionEnabled(false)
            .loafer_text("$ 1.99")
        offView
            .loafer_font(20, .boldItalic)
            .loafer_textColor("FFDC1A")
            .loafer_textAligment(.center)
            .loafer_text("30% off")
        descView
            .loafer_font(20, .boldItalic)
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
            .loafer_text("Limited Time Offer")
        continueBtn
            .loafer_font(21, .bold)
            .loafer_cornerRadius(25.FIT)
            .loafer_titleColor("FFFFFF")
            .loafer_text("Continue")
            .loafer_target(self, selector: #selector(loaferNewUserGemsGuideViewContinueBtn))
            .setGrandient(color: .themeColor(direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: UIDevice.screenWidth-60.FIT, height: 50.FIT))
    }
    
    @objc private func loaferNewUserGemsGuideViewContinueBtn() {
        guard let source else { return }
        Task {
            await StoreKit2Util.purchase(source)
        }
    }
    
    @objc private func loaferNewUserGemsGuideViewCloseBtn() {
        PopUtil.dismiss(from: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NewUserGemsGuideView: PopProtocol {
    func popViewSize() -> CGSize { CGSize(width: UIDevice.screenWidth-30.FIT, height: (UIDevice.screenWidth-30.FIT)*(550/345)) }
    func popViewStyle() -> PopType { .center }
    func popScreenInteraction() -> EKAttributes.UserInteraction { .init() }
    func popScroll() -> EKAttributes.Scroll { .disabled }
}
