
import UIKit
import Lottie

class MatchingPage: LoaferPage {
    
    override var prefersNavigationBarHidden: Bool { true }
    
    private let closeButton = UIButton(type: .custom)
    private let stackView = UIStackView()
    private let searchingView = UILabel()
    private let descView = UILabel()
    private let refreshButton = UIButton(type: .custom)
    private let anchorView = UIImageView(image: "Loafer_Empty_Icon".toImage)
    private let userView = UIImageView(image: "Loafer_Empty_Icon".toImage)
    private let leftProgressView = UIImageView(image: "Loafer_MachingPage_LeftProgress".toImage)
    private let rightProgressView = UIImageView(image: "Loafer_MachingPage_RightProgress".toImage)
    private let matchingAnimationView = LottieAnimationView(filePath: "Matching".toAnimationPath)
    private let matchingHeartAnimationView = LottieAnimationView(filePath: "MatchingHeart".toAnimationPath)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        backGroundImageView.loafer_image("Loafer_MachingPage_BackgroundImage")
        LoaferAppSettings.Match.isMatching = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews {
            closeButton
            matchingAnimationView.subviews(stackView)
            searchingView
            descView
            refreshButton
        }
        matchingAnimationView.centerHorizontally().top(150.FIT).size(UIDevice.screenWidth)
        closeButton.leading(15.FIT).top(UIDevice.safeTop).size(45.FIT)
        searchingView.Top == matchingAnimationView.Bottom+40.FIT
        searchingView.leading(0).trailing(0).height(34.FIT)
        descView.Top == searchingView.Bottom+10.FIT
        descView.leading(24.FIT).trailing(24.FIT)
        refreshButton.bottom(UIDevice.safeBottom+30.FIT).height(50.FIT).leading(35.FIT).trailing(35.FIT)
        stackView.centerInContainer()
        userView.size(90.FIT)
        anchorView.size(90.FIT)
        matchingHeartAnimationView.size(70.FIT)
        stackView.addArrangedSubview(userView)
        stackView.addArrangedSubview(leftProgressView)
        stackView.addArrangedSubview(matchingHeartAnimationView)
        stackView.addArrangedSubview(rightProgressView)
        stackView.addArrangedSubview(anchorView)
        userView.loafer_isHidden(true)
        leftProgressView.loafer_isHidden(true)
        anchorView.loafer_isHidden(true)
        rightProgressView.loafer_isHidden(true)
        stackView
            .loafer_axis(.horizontal)
            .loafer_spacing(0)
            .loafer_alignment(.center)
            .loafer_distribution(.equalCentering)
        matchingAnimationView.style { v in
            v.contentMode = .scaleAspectFill
            v.loopMode = .loop
            v.shouldRasterizeWhenIdle = true
            v.backgroundBehavior = .pauseAndRestore
            v.play()
        }
        matchingHeartAnimationView.style { v in
            v.contentMode = .scaleAspectFill
            v.loopMode = .loop
            v.shouldRasterizeWhenIdle = true
            v.backgroundBehavior = .pauseAndRestore
            v.play()
        }
        closeButton
            .loafer_image("Loafer_MachingPage_Close")
            .loafer_target(self, selector: #selector(loaferMatchingPageCloseButton))
        searchingView
            .loafer_font(28, .bold)
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
            .loafer_text("Searching...")
        descView
            .loafer_font(17, .medium)
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
            .loafer_text("Looking for matches for you😈😈")
        userView
            .loafer_cornerRadius(45.FIT)
            .loafer_border("FF26C5", 2.FIT)
            .loadImage(url: LoaferAppSettings.UserInfo.user.avatar)
        anchorView
            .loafer_cornerRadius(45.FIT)
            .loafer_border("FF26C5", 2.FIT)
        refreshButton
            .loafer_font(21, .bold)
            .loafer_backColor("FFFFFF", 0.4)
            .loafer_cornerRadius(25.FIT)
            .loafer_text("Refresh")
            .loafer_titleColor("FFFFFF")
            .loafer_isHidden(true)
            .loafer_target(self, selector: #selector(loaferMatchingPageRefreshButton))
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "MATCH_EMPTY_NOTIFICATION"), object: nil, queue: .main) {[weak self] _ in
            UIView.animate(withDuration: 0.35) {
                self?.userView.loafer_isHidden(true)
                self?.leftProgressView.loafer_isHidden(true)
                self?.anchorView.loafer_isHidden(true)
                self?.rightProgressView.loafer_isHidden(true)
                self?.refreshButton.loafer_isHidden(true)
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "MATCH_SUCCESS"), object: nil, queue: .main) {[weak self] noti in
            guard let `self` = self, let mdoel = noti.object as? IMSocketCallMatchSuccessResponse else { return }
            UIView.animate(withDuration: 0.35) {
                self.userView.loafer_isHidden(false)
                self.leftProgressView.loafer_isHidden(false)
                self.anchorView.loafer_isHidden(false)
                self.rightProgressView.loafer_isHidden(false)
                self.anchorView.loadImage(url: mdoel.avatar)
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "MATCH_AGAIN"), object: nil, queue: .main) {[weak self] _ in
            UIView.animate(withDuration: 0.35) {
                self?.userView.loafer_isHidden(true)
                self?.leftProgressView.loafer_isHidden(true)
                self?.anchorView.loafer_isHidden(true)
                self?.rightProgressView.loafer_isHidden(true)
                self?.refreshButton.loafer_isHidden(true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IMCallProvider.sendIMSocket(.MATCH_CALL_REQUEST(model: IMSocketCallRequestModel()))
    }
    
    @objc private func loaferMatchingPageRefreshButton() {
        IMCallProvider.sendIMSocket(.MATCH_CALL_REQUEST(model: IMSocketCallRequestModel()))
    }
    
    @objc private func loaferMatchingPageCloseButton() {
        LoaferAppSettings.Match.isMatching = false
        dismiss(animated: true)
    }
    
}
