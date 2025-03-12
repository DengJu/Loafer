
import UIKit

class NewUserRechargeView: UIView {
    
    private let topView = UIImageView(image: "Loafer_NewUserRechargeView_TopView".toImage)
    private let timeBackView = UIImageView(image: "Loafer_NewUserRechargeView_TimeBack".toImage)
    private let mainView = UIImageView(image: "Loafer_NewUserRechargeView_MainView".toImage)
    private let gemsView = UIImageView(image: "Loafer_NewUserRechargeView_Gems".toImage)
    private let gemsLabel = UILabel()
    private let descView = UILabel()
    private let priceButton = UIButton(type: .custom)
    private let closeBtn = UIButton(type: .custom)
    private let timeView = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            topView
            mainView.subviews {
                gemsView
                gemsLabel
                descView
                priceButton
            }
            timeBackView.subviews {
                timeView
            }
            closeBtn
        }
        timeView.fillContainer()
        topView.leading(0).trailing(0).top(66.FIT).height(224.FIT*(224/375))
        timeBackView.Top == topView.Top + 130.FIT
        timeBackView.centerHorizontally()
        mainView.Top == timeBackView.Top + 9.FIT
        mainView.leading(15.FIT).trailing(15.FIT).height(379.FIT*(379/345))
        closeBtn.centerHorizontally().size(45.FIT)
        closeBtn.Top == mainView.Bottom + 30.FIT
        mainView.layout {
            gemsView.centerHorizontally()
            0
            |gemsLabel| ~ 36.FIT
            15.FIT
            |-15.FIT-descView-15.FIT-|
            15.FIT
            |-25.FIT-priceButton-25.FIT-| ~ 50.FIT
            20.FIT
        }
        topView.loafer_contentMode(.scaleAspectFill)
        mainView.loafer_isUserInteractionEnabled(true)
        timeView
            .loafer_font(23, .black)
            .loafer_text("Congr: 00:29:32")
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
            .setShadowText("FF00C4".toColor, offsetX: 0, offsetY: 2.5)
        gemsLabel
            .loafer_font(29, .black)
            .loafer_text("0 Coins")
            .loafer_textColor("F5FF00")
            .loafer_textAligment(.center)
        descView
            .loafer_font(17, .medium)
            .loafer_text("Congratulations, you have obtained a limited-time recharge discount, please complete the recharge within the specified time.")
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
            .loafer_numberOfLines(0)
        closeBtn
            .loafer_image("Loafer_NewUserRechargeView_Close")
            .loafer_target(self, selector: #selector(loaferNewUserRechargeViewCloseBtn))
        priceButton
            .loafer_font(21, .extraBoldItalic)
            .loafer_cornerRadius(25.FIT)
            .loafer_titleColor("FF26C5")
            .loafer_text("$ 1.99")
            .loafer_target(self, selector: #selector(loaferNewUserRechargeViewPriceBtn))
            .setGrandient(color: .customColor(colors: ["FFF8B1".toColor, "FFFFFF".toColor], direction: .top2Bottom), bounds: CGRect(x: 0, y: 0, width: UIDevice.screenWidth-80.FIT, height: 50.FIT))
    }
    
    @objc private func loaferNewUserRechargeViewCloseBtn() {
        PopUtil.dismiss(from: self)
    }
    
    @objc private func loaferNewUserRechargeViewPriceBtn() {
        PopUtil.dismiss(from: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NewUserRechargeView: PopProtocol {
    func popViewSize() -> CGSize { CGSize(width: UIDevice.screenWidth, height: UIDevice.screenHeight) }
    func popViewStyle() -> PopType { .center }
    func popScreenInteraction() -> EKAttributes.UserInteraction { .init() }
    func popScroll() -> EKAttributes.Scroll { .disabled }
}
