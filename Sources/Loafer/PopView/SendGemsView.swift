
import UIKit

class SendGemsView: UIView {
    
    private let backGroundView = UIImageView(image: "Loafer_SendGemsView_BackgroundImage".toImage)
    private let gemsView = UIImageView(image: "Loafer_SendGemsView_Gems".toImage)
    private let descView = UILabel()
    private let okBtn = UIButton(type: .custom)
    private let sendGemsLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            backGroundView.subviews {
                gemsView
                descView
                sendGemsLabel
                okBtn
            }
        }
        backGroundView.fillContainer()
        backGroundView.loafer_isUserInteractionEnabled(true)
        backGroundView.layout {
            gemsView.centerHorizontally().size(60.FIT)
            15.FIT
            |sendGemsLabel| ~ 36.FIT
            15.FIT
            |-30.FIT-descView-30.FIT-|
            15.FIT
            |-40.FIT-okBtn-40.FIT-| ~ 50.FIT
            20.FIT
        }
        sendGemsLabel
            .loafer_font(29, .black)
            .loafer_text("+0 Coins")
            .loafer_textColor("F5FF00")
            .loafer_textAligment(.center)
        descView
            .loafer_font(17, .medium)
            .loafer_text("Welcome to join us, we have prepared some free coins for you")
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
            .loafer_numberOfLines(0)
        okBtn
            .loafer_font(21, .bold)
            .loafer_cornerRadius(25.FIT)
            .loafer_titleColor("FF26C5")
            .loafer_text("Continue")
            .loafer_target(self, selector: #selector(loaferSendGemsViewOkBtn))
            .setGrandient(color: .customColor(colors: ["FFF8B1".toColor, "FFFFFF".toColor], direction: .top2Bottom), bounds: CGRect(x: 0, y: 0, width: UIDevice.screenWidth-80.FIT, height: 50.FIT))
    }
    
    @objc private func loaferSendGemsViewOkBtn() {
        PopUtil.dismiss(from: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SendGemsView: PopProtocol {
    func popViewSize() -> CGSize { CGSize(width: UIDevice.screenWidth, height: UIDevice.screenWidth*(410/375)) }
    func popViewStyle() -> PopType { .center }
    func popScreenInteraction() -> EKAttributes.UserInteraction { .init() }
    func popScroll() -> EKAttributes.Scroll { .disabled }
}
