
import UIKit

class BlockTipView: UIView {
    
    private let iconView = UIImageView(image: "Loafer_Basic_EmptyIcon".toImage)
    private let backView = UIView()
    private let blockImageView = UIImageView(image: "Loafer_BlockTipView_TipIcon".toImage)
    private let descView = UILabel()
    private let blockBtn = UIButton(type: .custom)
    private let cancelBtn = UIButton(type: .custom)
    private(set) var userId: Int64 = 0
    
    init(avatar: String, userId: Int64) {
        super.init(frame: .zero)
        self.userId = userId
        subviews {
            backView.subviews {
                descView
                blockBtn
                cancelBtn
            }
            iconView.subviews(blockImageView)
        }
        iconView.centerHorizontally().top(0).size(80.FIT)
        backView.top(40.FIT).leading(0).trailing(0).bottom(0)
        blockImageView.centerInContainer()
        backView.layout {
            50.FIT
            |-20.FIT-descView-20.FIT-|
            20.FIT
            |-20.FIT-blockBtn-20.FIT-cancelBtn-20.FIT-| ~ 50.FIT
            20.FIT
        }
        equal(widths: [blockBtn, cancelBtn])
        backView
            .loafer_backColor("46133E")
            .loafer_cornerRadius(27.FIT)
        iconView
            .loafer_cornerRadius(40.FIT)
            .loafer_border("46133E", 3.FIT)
            .loadImage(url: avatar)
        descView
            .loafer_font(17, .semiBold)
            .loafer_textColor("C7B0CE")
            .loafer_text("After blocking a user, you will not be able to view any of their information.Do you want to block them?")
            .loafer_textAligment(.center)
            .loafer_numberOfLines(0)
        blockBtn
            .loafer_font(21, .bold)
            .loafer_text("Block")
            .loafer_cornerRadius(25.FIT)
            .loafer_border("FE269C", 2.FIT)
            .loafer_titleColor("FE269C")
            .loafer_target(self, selector: #selector(loaferReportViewBlockBtn))
        cancelBtn
            .loafer_font(21, .bold)
            .loafer_text("Cancel")
            .loafer_cornerRadius(25.FIT)
            .loafer_titleColor("FFFFFF")
            .loafer_target(self, selector: #selector(loaferReportViewCancelBtn))
            .setGrandient(color: .themeColor(direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: (UIDevice.screenWidth-85.FIT)/2, height: 50.FIT))
    }
    
    @objc private func loaferReportViewBlockBtn() {
        ToastTool.show()
        URLSessionProvider.request(.URLInterfaceBlock(model: SessionRequestBlockStatusModel(blackUserId: userId, black: true)))
            .compactMap{$0.data}
            .done { _ in
                ToastTool.show(.success, "Block Successfully!")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BLOCK-USER-NOTIFICATION"), object: self.userId)
                DispatchQueue.main.async {
                    if let conv = RealmProvider.share.queryConversation(from: LoaferAppSettings.URLSettings.IMPRE + "\(self.userId)&" + "\(LoaferAppSettings.UserInfo.user.userId)") {
                        RealmProvider.share.openTransaction { realm in
                            conv.isBlock = true
                        }
                    }
                }
            }
            .catch { error in
                error.handle()
            }
    }
    
    @objc private func loaferReportViewCancelBtn() {
        PopUtil.dismiss(from: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fatalError("init(avatar:userId:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension BlockTipView: PopProtocol {
    func popViewSize() -> CGSize { CGSize(width: UIDevice.screenWidth-30.FIT, height: (UIDevice.screenWidth-30.FIT)*(266/345)) }
    func popViewStyle() -> PopType { .center }
    func popScreenInteraction() -> EKAttributes.UserInteraction { .init() }
    func popScroll() -> EKAttributes.Scroll { .disabled }
}
