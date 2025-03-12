
import UIKit
import Lottie

class MatchSuccessPage: UIView, SourceProtocol {
    
    func setSourceData(_ data: IMSocketCallMatchSuccessResponse) {
        matchModel = data
        mainView.loadImage(url: data.avatar)
        nameView.loafer_text(data.nickname)
        var countryStr = LoaferAppSettings.queryCountryInfo("\(data.country)")?.0 ?? ""
        if let age = data.birthday.ageFromBirthday() {
            countryStr += " \(age)"
        }
        countryBtn.configuration = UIButton.Configuration.plain()
        countryBtn.configurationUpdateHandler = { button in
            button.configuration?.imagePadding = 5.FIT
            button.configuration?.attributedTitle = AttributedString(countryStr, attributes: AttributeContainer([
            NSAttributedString.Key.font : UIFont.setFont(14, .bold), NSAttributedString.Key.foregroundColor: "FFFFFF".toColor]))
        }
    }
    
    private var matchModel: IMSocketCallMatchSuccessResponse?
    private let mainView = UIImageView()
    private let matchView = UIImageView(image: "Loafer_MatchSuccessPage_ItIsMatch".toImage)
    private let closeBtn = UIButton(type: .custom)
    private let matchingAnimationView = LottieAnimationView(filePath: "Matching".toAnimationPath)
    private let matchingHeartAnimationView = LottieAnimationView(filePath: "MatchingHeart".toAnimationPath)
    private let countryBtn = UIButton(type: .custom)
    private let reportBtn = UIButton(type: .custom)
    private let nameView = UILabel()
    private let genderView = UIImageView(image: "Loafer_MatchSuccessPage_Female".toImage)
    private let acceptButton = UIButton(type: .custom)
    private let waitButton = UIButton(type: .custom)
    private let nameStackView = UIStackView()
    private let countryStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            mainView.subviews {
                closeBtn
                nameStackView
                countryStackView
            }
            matchView
            matchingAnimationView
            matchingHeartAnimationView
            waitButton
            acceptButton
        }
        mainView.centerHorizontally().centerVertically(offset: -5.FIT).width(UIDevice.screenWidth-40.FIT).height((UIDevice.screenWidth-40.FIT)*(480/335))
        mainView.layout {
            10.FIT
            closeBtn.size(45.FIT)-10.FIT-|
            >=0
            |-15.FIT-nameStackView.height(26.FIT)
            5.FIT
            |-15.FIT-countryStackView.height(30.FIT)
            15.FIT
        }
        matchView.Bottom == mainView.Top - 28.FIT
        matchView.centerHorizontally()
        matchingHeartAnimationView.Bottom == mainView.Top
        matchingHeartAnimationView.centerHorizontally().size(115.FIT)
        acceptButton.Top == mainView.Bottom + 30.FIT
        acceptButton.leading(20.FIT).trailing(20.FIT).height(50.FIT)
        matchingAnimationView.leading(0).trailing(0).top(0).height(313.FIT)
        genderView.size(20.FIT)
        reportBtn.size(25.FIT)
        countryBtn.width(78.FIT).height(30.FIT)
        waitButton.followEdges(acceptButton)
        nameStackView.addArrangedSubview(nameView)
        nameStackView.addArrangedSubview(genderView)
        countryStackView.addArrangedSubview(countryBtn)
        countryStackView.addArrangedSubview(reportBtn)
        mainView
            .loafer_backColor(.randomColor)
            .loafer_cornerRadius(30.FIT)
            .loafer_contentMode(.scaleAspectFill)
            .loafer_isUserInteractionEnabled(true)
        nameStackView
            .loafer_axis(.horizontal)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalCentering)
        countryStackView
            .loafer_axis(.horizontal)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalCentering)
        matchingAnimationView.style { v in
            v.contentMode = .scaleAspectFill
            v.loopMode = .loop
            v.shouldRasterizeWhenIdle = true
            v.backgroundBehavior = .pauseAndRestore
            v.play()
            v.isHidden = true
            v.isUserInteractionEnabled = false
        }
        matchingHeartAnimationView.style { v in
            v.contentMode = .scaleAspectFill
            v.loopMode = .loop
            v.shouldRasterizeWhenIdle = true
            v.backgroundBehavior = .pauseAndRestore
            v.play()
            v.isUserInteractionEnabled = false
        }
        nameView
            .loafer_font(21, .bold)
            .loafer_text("Name")
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
        reportBtn
            .loafer_image("Loafer_MatchSuccessPage_Report")
            .loafer_target(self, selector: #selector(loaferMatchSuccessPageReportBtn))
        countryBtn
            .loafer_cornerRadius(15.FIT)
            .loafer_isUserInteractionEnabled(false)
            .loafer_backColor("000000", 0.15)
        closeBtn
            .loafer_image("Loafer_MatchSuccessPage_Close")
            .loafer_target(self, selector: #selector(loaferMatchSuccessPageCloseBtn))
        waitButton
            .loafer_text("Waiting...")
            .loafer_font(21, .bold)
            .loafer_cornerRadius(25.FIT)
            .loafer_isHidden(true)
            .loafer_titleColor("FFFFFF")
            .loafer_isUserInteractionEnabled(false)
            .setGrandient(color: .customColor(colors: ["F800FF".toColor.withAlphaComponent(0.24), "CB1FFF".toColor.withAlphaComponent(0.24)], direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: UIDevice.screenWidth-40.FIT, height: 50.FIT))
        acceptButton
            .loafer_image("Loafer_MatchSuccessPage_Call")
            .loafer_cornerRadius(25.FIT)
            .loafer_target(self, selector: #selector(loaferMatchSuccessPageCallBtn))
            .setGrandient(color: .themeColor(direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: UIDevice.screenWidth-40.FIT, height: 50.FIT))
        
        acceptButton.configuration = UIButton.Configuration.plain()
        acceptButton.configurationUpdateHandler = { button in
            button.configuration?.imagePadding = 5.FIT
            button.configuration?.attributedTitle = AttributedString("Accept for 20 coins", attributes: AttributeContainer([
            NSAttributedString.Key.font : UIFont.setFont(21, .bold), NSAttributedString.Key.foregroundColor: "FFFFFF".toColor]))
        }
    }
    
    @objc private func loaferMatchSuccessPageReportBtn() {
        guard let matchModel else { return }
        PopUtil.pop(show: ReportView(userId: matchModel.userId))
    }
    
    @objc private func loaferMatchSuccessPageCloseBtn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            IMCallProvider.sendIMSocket(.MATCH_CALL_REQUEST(model: IMSocketCallRequestModel()))
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MATCH_AGAIN"), object: nil)
        PopUtil.dismiss(from: self)
    }
    
    @objc private func loaferMatchSuccessPageCallBtn() {
        guard let matchModel else { return }
        IMCallProvider.sendIMSocket(.CALL_REQUEST(model: IMSocketCallRequestModel(recvId: matchModel.userId, callNo: matchModel.callNo)))
        matchingAnimationView.loafer_isHidden(false)
        matchingHeartAnimationView.loafer_isHidden(true)
        waitButton.loafer_isHidden(false)
        acceptButton.loafer_isHidden(true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MatchSuccessPage: PopProtocol {
    func popViewSize() -> CGSize { CGSize(width: UIDevice.screenWidth, height: UIDevice.screenHeight) }
    func popViewStyle() -> PopType { .center }
    func popScreenInteraction() -> EKAttributes.UserInteraction { .init() }
    func popScroll() -> EKAttributes.Scroll { .disabled }
}
