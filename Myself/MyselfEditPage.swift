
import UIKit
import KakaJSON

private var editInfoModel: SessionRequestEditInfoModel = SessionRequestEditInfoModel()
private var finalAvatar: UIImage?
private var isModify: Bool = false

class MyselfEditPage: LoaferPage {

    private let stackView = UIStackView()
    private let scrollView = UIScrollView()
    private let avatarView = EditAvatarView()
    private let nameView = EditTextFieldView()
    private let genderView = EditTextFieldView()
    private let birthView = EditTextFieldView()
    private let signatureView = EditSignatureView()
    private let saveButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Modify info"
        view.subviews {
            scrollView.subviews {
                stackView
            }
        }
        scrollView.followEdges(view, top: UIDevice.topFullHeight)
        scrollView.layout {
            0
            |stackView|
            0
        }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIDevice.safeBottom, right: 0)
        stackView.width(UIDevice.screenWidth)
        scrollView.loafer_contentInsetAdjustmentBehavior(.never)
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(20.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalSpacing)
        avatarView.width(UIDevice.screenWidth).height(80.FIT)
        stackView.addArrangedSubview(avatarView)
        nameView.width(UIDevice.screenWidth).height(60.FIT)
        genderView.width(UIDevice.screenWidth).height(60.FIT)
        birthView.width(UIDevice.screenWidth).height(60.FIT)
        stackView.addArrangedSubview(nameView)
        stackView.addArrangedSubview(genderView)
        stackView.addArrangedSubview(birthView)
        signatureView.width(UIDevice.screenWidth).height(180.FIT)
        stackView.addArrangedSubview(signatureView)
        saveButton.width(UIDevice.screenWidth-70.FIT).height(50.FIT)
        stackView.addArrangedSubview(saveButton)
        nameView.setSourceData(("Nickname", ""))
        genderView.setSourceData(("Gender", "Please upload your real gender"))
        birthView.setSourceData(("Birthdate", "Must be 18 years or older"))
        saveButton
            .loafer_font(20, .bold)
            .loafer_text("Save")
            .loafer_backColor("5E4081")
            .loafer_cornerRadius(25.FIT)
            .loafer_titleColor("FFFFFF", 0.6)
            .loafer_target(self, selector: #selector(loaferMyselfEditPageSavebutton(_:)))
    }
    
    @objc private func loaferMyselfEditPageSavebutton(_ sender: UIButton) {
        guard isModify else { return }
        if let avatar = finalAvatar, let data = avatar.jpegData(compressionQuality: 0.5) {
            ToastTool.show()
            sender.isUserInteractionEnabled = false
            URLSessionProvider.uploadFile(.URLInterfaceUploadFile(model: SessionRequestUploadFileModel(fileName: "EditPhoto.png", contentLength: Int64(data.count))), mediaType: .imageFile(data: data))
                .compactMap { $0.data }
                .then { result in
                    editInfoModel.avatar = result.url
                    return URLSessionProvider.request(.URLInterfaceEditInfo(model: editInfoModel), type: SessionResponseUserInfoModel.self)
                }
                .done {[weak self] result in
                    self?.navigationController?.popViewController(animated: true)
                    ToastTool.show(.success, "Modified successfully!")
                }
                .ensure {
                    sender.isUserInteractionEnabled = true
                }
                .catch { error in
                    error.handle()
                }
        }else {
            URLSessionProvider.request(.URLInterfaceEditInfo(model: editInfoModel), type: SessionResponseUserInfoModel.self)
                .compactMap{ $0.data }
                .done {[weak self] result in
                    self?.navigationController?.popViewController(animated: true)
                    ToastTool.show(.success, "Modified successfully!")
                }
                .ensure {
                    sender.isUserInteractionEnabled = true
                }
                .catch { error in
                    error.handle()
                }
        }
    }
    
}

class EditAvatarView: UIView {
    
    private let stackView = UIStackView()
    private let titleView = UILabel()
    private let tipView = UILabel()
    private let iconView = UIImageView(image: "Loafer_Basic_EmptyIcon".toImage)
    private let cameraView = UIImageView(image: "Loafer_MyselfEditPage_Camera".toImage)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            stackView
            iconView
            cameraView
        }
        |-15.FIT-stackView.centerVertically()-iconView.centerVertically().size(76.FIT)-15.FIT-|
        cameraView.Leading == iconView.Leading - 10.FIT
        cameraView.CenterY == iconView.CenterY
        cameraView.size(35.FIT)
        titleView
            .loafer_font(19, .semiBold)
            .loafer_textColor("FFFFFF")
            .loafer_text("Modify avatar")
            .height(24.FIT)
        tipView
            .loafer_font(12, .medium)
            .loafer_textColor("FE269C")
            .loafer_text("Please upload your real avatar")
            .loafer_numberOfLines(0)
            .height(15.FIT)
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.leading)
            .loafer_distribution(.equalSpacing)
        iconView
            .loafer_contentMode(.scaleAspectFill)
            .loafer_cornerRadius(38.FIT)
            .loafer_isUserInteractionEnabled(true)
        stackView.addArrangedSubview(titleView)
        stackView.addArrangedSubview(tipView)
        iconView.loadImage(url: LoaferAppSettings.UserInfo.user.avatar)
        let tap = UITapGestureRecognizer(target: self, action: #selector(loaferEditAvatarViewChooseImage))
        iconView.addGestureRecognizer(tap)
    }
    
    @objc private func loaferEditAvatarViewChooseImage() {
        guard let page = iq.parentContainerViewController() else { return }
        let more = LoaferActionSheetView(items: [.Album, .Camera])
        more.didSelectItems = {[weak self] item in
            guard let `self` = self else { return }
            if item == .Album {
                AssetsSession.session.filterPictureFromAlbum(from: page) {[weak self] assets in
                    if let image = assets.first?.image {
                        finalAvatar = image
                        self?.iconView.image = image
                        isModify = true
                    }
                }
            }else if item == .Camera {
                AssetsSession.session.filterPictureFromCamera(from: page) {[weak self] assets in
                    if let image = assets.first?.image {
                        finalAvatar = image
                        self?.iconView.image = image
                        isModify = true
                    }
                }
            }
        }
        PopUtil.pop(show: more)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EditTextFieldView: UIView, SourceProtocol, UITextFieldDelegate {
    
    typealias SourceData = (String, String)
    
    func setSourceData(_ data: (String, String)) {
        titleView.loafer_text(data.0)
        tipView.loafer_text(data.1)
        tipView.loafer_isHidden(data.1.isEmpty)
        if data.0 == "Nickname" {
            textfiled.loafer_placeholder(LoaferAppSettings.UserInfo.user.nickname.isEmpty ? "nickname" : LoaferAppSettings.UserInfo.user.nickname)
        }else if data.0 == "Gender" {
            if LoaferAppSettings.UserInfo.user.gender == 0 {
                textfiled.loafer_placeholder("Male")
            }else if LoaferAppSettings.UserInfo.user.gender == 1 {
                textfiled.loafer_placeholder("Female")
            }else if LoaferAppSettings.UserInfo.user.gender == 2 {
                textfiled.loafer_placeholder("Unknown")
            }
        }else {
            textfiled.loafer_placeholder(LoaferAppSettings.UserInfo.user.birthday.isEmpty ? "birthdate" : LoaferAppSettings.UserInfo.user.birthday)
        }
    }
    
    private let stackView = UIStackView()
    private let titleView = UILabel()
    private let tipView = UILabel()
    private let textfiled = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            stackView
            textfiled
        }
        |-15.FIT-stackView.centerVertically()-textfiled.centerVertically().width(<=120.FIT).height(60.FIT)-15.FIT-|
        titleView
            .loafer_font(19, .semiBold)
            .loafer_textColor("FFFFFF")
            .loafer_text("Gender")
            .height(24.FIT)
        tipView
            .loafer_font(12, .medium)
            .loafer_textColor("FE269C")
            .loafer_text("Please upload your real avatar")
            .loafer_numberOfLines(0)
            .height(15.FIT)
        textfiled
            .loafer_font(16, .semiBold)
            .loafer_textColor("C7B0CE")
            .loafer_tintColor("C7B0CE")
            .loafer_placeholder("Nickname")
            .loafer_placeholderFont(16, .semiBold)
            .loafer_placeholderColor("C7B0CE")
            .loafer_textAligment(.right)
            .loafer_target(self, selector: #selector(loaferEditTextFieldViewDidChanged(_:)), event: .editingChanged)
            .delegate = self
        stackView.addArrangedSubview(titleView)
        stackView.addArrangedSubview(tipView)
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.leading)
            .loafer_distribution(.equalSpacing)
    }
    
    @objc private func loaferEditTextFieldViewDidChanged(_ sender: UITextField) {
        editInfoModel.nickname = sender.text
        if let name = sender.text, name != LoaferAppSettings.UserInfo.user.nickname {
            isModify = true
        }else {
            isModify = false
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if titleView.text == "Nickname" {
            return true
        }
        return false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EditSignatureView: UIView, UITextViewDelegate {
    
    private let titleView = UILabel()
    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            titleView
            textView
            placeholderLabel
        }
        layout {
            0
            |-15.FIT-titleView-15.FIT-| ~ 60.FIT
            0
            |-15.FIT-textView-15.FIT-|
            0
        }
        placeholderLabel.Top == textView.Top + 15.FIT
        placeholderLabel.leading(23.FIT).trailing(23.FIT)
        titleView
            .loafer_font(19, .semiBold)
            .loafer_textColor("FFFFFF")
            .loafer_text("Signature")
        textView
            .loafer_font(16, .semiBold)
            .loafer_tintColor("FFFFFF")
            .loafer_textColor("FFFFFF")
            .loafer_cornerRadius(18.FIT)
            .loafer_backColor("FFFFFF", 0.1)
            .loafer_textContainerInset(15.FIT, 5.FIT, 5.FIT, 5.FIT)
            .loafer_text(LoaferAppSettings.UserInfo.user.signature)
            .delegate = self
        placeholderLabel
            .loafer_font(16, .semiBold)
            .loafer_textColor("FFFFFF", 0.6)
            .loafer_text("If everything is fun, it must be fun!")
            .loafer_isHidden(!LoaferAppSettings.UserInfo.user.signature.isEmpty)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.loafer_isHidden(!textView.text.isEmpty)
        editInfoModel.signature = textView.text
        isModify = !textView.text.isEmpty
    }
    
}
