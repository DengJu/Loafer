
import UIKit

class VideoCallExitView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            backView.subviews {
                descView
                cancelBtn
                hangupBtn
            }
        }
        backView.followEdges(self, bottom: -(UIDevice.safeBottom+10.FIT))
        backView.layout {
            0
            |-20.FIT-descView-20.FIT-|
            0
            |-20.FIT-hangupBtn-15.FIT-cancelBtn-20.FIT-| ~ 50.FIT
            20.FIT
        }
        equal(widths: [hangupBtn, cancelBtn])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var exitClosure: (() -> Void)?
    
    private lazy var descView: UILabel = {
        $0
            .loafer_font(17, .semiBold)
            .loafer_textColor("020202")
            .loafer_textAligment(.center)
            .loafer_text("Are you sure you want to hang up the call?")
            .loafer_numberOfLines(0)
    }(UILabel())
    
    private lazy var cancelBtn: UIButton = {
        $0
            .loafer_font(20, .bold)
            .loafer_titleColor("FAFAFA")
            .loafer_text("Cancel")
            .loafer_cornerRadius(25.FIT)
            .loafer_backColor("FF0A42")
            .loafer_target(self, selector: #selector(videoCallExitViewCancelBtn))
    }(UIButton(type: .custom))
    
    private lazy var hangupBtn: UIButton = {
        $0
            .loafer_font(20, .bold)
            .loafer_titleColor("FF0A42")
            .loafer_text("Hang up")
            .loafer_cornerRadius(25.FIT)
            .loafer_border("FF0A42", 2)
            .loafer_target(self, selector: #selector(videoCallExitViewHangupBtn))
    }(UIButton(type: .custom))
    
    private lazy var backView: UIView = {
        $0
            .loafer_cornerRadius(25.FIT)
            .loafer_backColor("FAFAFA")
    }(UIView())
    
}

extension VideoCallExitView {
    
    @objc private func videoCallExitViewCancelBtn() {
        PopUtil.dismiss(from: self)
    }
    
    @objc private func videoCallExitViewHangupBtn() {
        if let closure = exitClosure {
            closure()
        }
    }
    
}

extension VideoCallExitView: PopProtocol {
    func popViewSize() -> CGSize { CGSize(width: UIDevice.screenWidth-30.FIT, height: UIDevice.screenWidth*(166/345) + UIDevice.safeBottom + 10.FIT) }
    func popViewStyle() -> PopType { .bottom }
    func popScreenInteraction() -> EKAttributes.UserInteraction { .dismiss }
    func popScroll() -> EKAttributes.Scroll { .edgeCrossingDisabled(swipeable: true) }
}
