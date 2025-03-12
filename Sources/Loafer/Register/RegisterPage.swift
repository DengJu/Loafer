
import UIKit
import SafariServices
import AuthenticationServices

class RegisterPage: LoaferPage {

    private let backImageView = UIImageView(image: "".toImage)
    private let systemLoginBtn = UIButton(type: .custom)
    private let touristBtn = UIButton(type: .custom)
    private let termsBtn = UIButton(type: .custom)
    private let policyBtn = UIButton(type: .custom)
    private let andLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews {
            backImageView
            andLabel
            termsBtn
            policyBtn
            systemLoginBtn
            touristBtn
        }
        backImageView.fillContainer()
        view.layout {
            >=0
            |-30.FIT-systemLoginBtn.width(50.FIT)-15.FIT-touristBtn-30.FIT-| ~ 50.FIT
            25.FIT
            andLabel.centerHorizontally().size(22.FIT)
            UIDevice.safeBottom + 34.FIT
        }
        termsBtn.Trailing == andLabel.Leading
        termsBtn.CenterY == andLabel.CenterY
        termsBtn.height(22.FIT)
        policyBtn.Leading == andLabel.Trailing
        policyBtn.CenterY == andLabel.CenterY
        policyBtn.height(22.FIT)
        systemLoginBtn
            .loafer_image("Loafer_Register_System")
            .loafer_backColor("FFFFFF")
            .loafer_cornerRadius(25.FIT)
            .loafer_target(self, selector: #selector(loaferActionRegisterSystemLogin))
        touristBtn
            .loafer_image("Loafer_Register_Tourist")
            .loafer_cornerRadius(25.FIT)
            .loafer_font(21, .bold)
            .loafer_text("Get Started")
            .loafer_titleColor("FFFFFF")
            .loafer_target(self, selector: #selector(loaferActionRegisterTouristLogin))
            .setGrandient(color: .themeColor(direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: UIDevice.screenWidth-125.FIT, height: 50.FIT))
        andLabel
            .loafer_text("&")
            .loafer_font(18, .semiBold)
            .loafer_textColor("FE269C")
            .loafer_textAligment(.center)
        termsBtn
            .loafer_font(18, .semiBold)
            .loafer_text("Terms of Use")
            .loafer_titleColor("FFFFFF")
            .loafer_target(self, selector: #selector(loaferActionRegisterTermsBtn))
        policyBtn
            .loafer_font(18, .semiBold)
            .loafer_text("Privacy Policy")
            .loafer_titleColor("FFFFFF")
            .loafer_target(self, selector: #selector(loaferActionRegisterTermsBtn))
    }
    
    @objc private func loaferActionRegisterTermsBtn() {
        if let url = LoaferAppSettings.Config.TERMSOFUSE.toURL {
            let safari = SFSafariViewController(url: url)
            present(safari, animated: true, completion: nil)
        }
    }
    
    @objc private func loaferActionRegisterPolicyBtn() {
        if let url = LoaferAppSettings.Config.PRIVACYPOLICY.toURL {
            let safari = SFSafariViewController(url: url)
            present(safari, animated: true, completion: nil)
        }
    }
    
    @objc private func loaferActionRegisterSystemLogin(_ sender: UIButton) {
        ToastTool.show()
        SignInAppleTool.default.login { user, _ in
            URLSessionProvider.request(.URLInterfaceLogin(model: SessionRequestLoginModel(loginNo: user)), type: SessionResponseUserInfoModel.self)
                .compactMap { $0.data }
                .then { _ in
                    return URLSessionProvider.request(.URLInterfacePonyList, type: [SessionResponsePonyModel].self)
                }
                .then { result in
                    if let data = result.data {
                        LoaferAppSettings.Pony.data = data
                    }
                    return URLSessionProvider.request(.URLInterfaceGemsList, type: [SessionResponseGemsListModel].self)
                }
                .done { result in
                    if let data = result.data {
                        LoaferAppSettings.Gems.data = data
                    }
                    ToastTool.dismiss()
                    UIApplication.mainWindow.rootViewController = LoaferTabBarPage()
                }
                .catch { error in
                    error.handle()
                }
        } failure: { error in
            error.handle()
        }
    }
    
    @objc private func loaferActionRegisterTouristLogin(_ sender: UIButton) {
        var loginModel = SessionRequestLoginModel()
        loginModel.type = "TOURIST"
        loginModel.loginNo = LoaferAppSettings.Config.DEVICEID
        ToastTool.show()
        URLSessionProvider.request(.URLInterfaceLogin(model: loginModel), type: SessionResponseUserInfoModel.self)
            .compactMap{ $0.data }
            .then { _ in
                return URLSessionProvider.request(.URLInterfacePonyList, type: [SessionResponsePonyModel].self)
            }
            .then { result in
                if let data = result.data {
                    LoaferAppSettings.Pony.data = data
                }
                return URLSessionProvider.request(.URLInterfaceGemsList, type: [SessionResponseGemsListModel].self)
            }
            .done { result in
                if let data = result.data {
                    LoaferAppSettings.Gems.data = data
                }
                ToastTool.dismiss()
                UIApplication.mainWindow.rootViewController = LoaferTabBarPage()
            }
            .catch { error in
                error.handle()
            }
    }
    
}

typealias SignInAppleToolSuccessClosures = (_ user: String, _ token: String) -> Void
typealias SignInAppleToolFailureClosures = (_ error: EMError.AppleLoginError) -> Void

class SignInAppleTool: NSObject {
    static let `default` = SignInAppleTool()

    override private init() {}

    override func copy() -> Any {
        return SignInAppleTool.default
    }

    override func mutableCopy() -> Any {
        return SignInAppleTool.default
    }

    private var successCompelecte: SignInAppleToolSuccessClosures?
    private var failureCompelecte: SignInAppleToolFailureClosures?

    public func login(success: SignInAppleToolSuccessClosures? = nil, failure: SignInAppleToolFailureClosures? = nil) {
        successCompelecte = success
        failureCompelecte = failure
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension SignInAppleTool: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.mainWindow
    }
}

extension SignInAppleTool: ASAuthorizationControllerDelegate {
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        var baseError: EMError.AppleLoginError
        switch error._code {
        case ASAuthorizationError.Code.canceled.rawValue:
            baseError = .CancelAuthorization
        case ASAuthorizationError.Code.failed.rawValue:
            baseError = .AuthorizationRequestFailed
        case ASAuthorizationError.Code.invalidResponse.rawValue:
            baseError = .InvalidAuthorizationRequest
        case ASAuthorizationError.Code.notHandled.rawValue:
            baseError = .FailedToProcessAuthorizationRequest
        default:
            baseError = .PrivilegeGrantFailed
        }
        guard let closure = failureCompelecte else { return }
        closure(baseError)
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if authorization.credential is ASAuthorizationAppleIDCredential {
            let credential = authorization.credential as! ASAuthorizationAppleIDCredential
            let user = credential.user
            guard let identityToken = credential.identityToken else {
                guard let closure = failureCompelecte else { return }
                closure(EMError.AppleLoginError.identityTokenIsNULL)
                return
            }
            guard let token = String(data: identityToken, encoding: .utf8) else {
                guard let closure = failureCompelecte else { return }
                closure(EMError.AppleLoginError.identityTokenIsNULL)
                return
            }
            guard let closure = successCompelecte else { return }
            closure(user, token)
        } else if authorization.credential is ASPasswordCredential {
            guard let closure = failureCompelecte else { return }
            closure(EMError.AppleLoginError.PrivilegeGrantFailed)
        } else {
            guard let closure = failureCompelecte else { return }
            closure(EMError.AppleLoginError.PrivilegeGrantFailed)
        }
    }
}
