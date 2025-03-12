
import UIKit
import AVFoundation
import Stevia
import Lottie

class RandomChatPage: LoaferPage {
    
    private let captureView = LoaferCaptureView()
    private let coinsView = UIButton(type: .custom)
    private let tipsView = UILabel()
    private let onlinePersonLabel = UILabel()
    private let beginChatView = LottieAnimationView(filePath: "BeginRandomChat".toAnimationPath)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews {
            captureView.subviews {
                coinsView
                beginChatView.subviews {
                    tipsView
                    onlinePersonLabel
                }
            }
        }
        beginChatView.centerVertically(offset: -15.FIT).centerHorizontally().size(UIDevice.screenWidth-50.FIT)
        captureView.leading(10.FIT).top(UIDevice.topFullHeight + 5.FIT).bottom(UIDevice.bottomFullHeight + 5.FIT).trailing(10.FIT)
        captureView.loafer_cornerRadius(30.FIT)
        coinsView.bottom(30.FIT).centerHorizontally().height(30.FIT).width(>=0)
        tipsView.centerHorizontally().centerVertically(offset: -8.FIT)
        onlinePersonLabel.centerHorizontally()
        onlinePersonLabel.Top == tipsView.Bottom + 5.FIT
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: "Loafer_RandomChatPage_TitleView".toImage))
        coinsView
            .loafer_backColor("000000", 0.4)
            .loafer_cornerRadius(15.FIT)
            .loafer_image("Loafer_RandomChatPage_Coins")
            .loafer_isUserInteractionEnabled(false)
            .loafer_imagePadding(5.FIT, UIFont.setFont(17, .bold), "\(LoaferAppSettings.Match.price)/Match", "FFFFFF")
        tipsView
            .loafer_font(30, .bold)
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
            .loafer_text("Tap To Start")
        onlinePersonLabel
            .loafer_font(19, .medium)
            .loafer_textColor("FFFFFF", 0.8)
            .loafer_textAligment(.center)
            .loafer_text("100 Online")
        beginChatView.style { v in
            v.contentMode = .scaleAspectFill
            v.loopMode = .loop
            v.shouldRasterizeWhenIdle = true
            v.backgroundBehavior = .pauseAndRestore
            v.play()
        }
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .authorized {
            captureView.beginRunning()
        } else {
            if authStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            self.captureView.beginRunning()
                        }
                    } else {
                        self.dismiss(animated: true) {
                            debugPrint("没有权限")
//                            let alertController = EndelPermissionTipManager.alertAuthorizationStatus(type: .Video)
//                            self.present(alertController, animated: true)
                        }
                    }
                }
            } else {
                debugPrint("没有权限")
//                let alertController = EndelPermissionTipManager.alertAuthorizationStatus(type: .Video)
//                present(alertController, animated: true)
            }
        }
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        captureView.stopRunning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        present(MatchingPage(), animated: true)
    }
    
}
