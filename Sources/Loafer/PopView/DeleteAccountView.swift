
import UIKit

class DeleteAccountView: UIView {
    
    private let iconView = UIImageView(image: "Loafer_DeleteAccountView_Icon".toImage)
    private let descView = UILabel()
    private let deleteBtn = UIButton(type: .custom)
    private let cancelBtn = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loafer_cornerRadius(27.FIT)
        loafer_backColor("46133E")
        subviews {
            iconView
            descView
            deleteBtn
            cancelBtn
        }
        layout {
            24.FIT
            iconView.centerHorizontally().size(30.FIT)
            15.FIT
            |-20.FIT-descView-20.FIT-|
            15.FIT
            |-20.FIT-deleteBtn-15.FIT-cancelBtn-20.FIT-| ~ 50.FIT
            20.FIT
        }
        equal(widths: [deleteBtn, cancelBtn])
        descView
            .loafer_font(17, .semiBold)
            .loafer_textColor("C7B0CE")
            .loafer_numberOfLines(0)
            .loafer_textAligment(.center)
            .loafer_text("After deleting your account, your personal information and assets will be cleared. Are you sure to delete it?")
        deleteBtn
            .loafer_font(22, .bold)
            .loafer_text("Delete")
            .loafer_cornerRadius(25.FIT)
            .loafer_titleColor("FE269C")
            .loafer_border("FE269C", 2.FIT)
            .loafer_target(self, selector: #selector(loaferDeleteAccountViewDeleteBtn))
        cancelBtn
            .loafer_font(22, .bold)
            .loafer_text("Cancel")
            .loafer_cornerRadius(25.FIT)
            .loafer_titleColor("FFFFFF")
            .loafer_target(self, selector: #selector(loaferDeleteAccountViewCancelBtn))
            .setGrandient(color: .themeColor(direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: (UIDevice.screenWidth-85.FIT)/2, height: 50.FIT))
    }
    
    @objc private func loaferDeleteAccountViewDeleteBtn() {
        URLSessionProvider.request(.URLInterfaceDeleteAccount(model: SessionRequestDeleteAccountModel(reason: 2)))
            .compactMap{ $0.data }
            .done { _ in
                IMSocket.share.disConnect()
                LoaferAppSettings.Config.removeToken()
                RealmProvider.share.deleteAll()
                PopUtil.dismiss(from: self)
                UIApplication.mainWindow.rootViewController = BasicNavigationPage(rootViewController: RegisterPage())
            }
            .catch { error in
                error.handle()
            }
    }
    
    @objc private func loaferDeleteAccountViewCancelBtn() {
        PopUtil.dismiss(from: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension DeleteAccountView: PopProtocol {
    func popViewSize() -> CGSize { CGSize(width: UIDevice.screenWidth-30.FIT, height: UIDevice.screenWidth*(255/345)) }
    func popViewStyle() -> PopType { .center }
    func popScreenInteraction() -> EKAttributes.UserInteraction { .init() }
    func popScroll() -> EKAttributes.Scroll { .disabled }
}
