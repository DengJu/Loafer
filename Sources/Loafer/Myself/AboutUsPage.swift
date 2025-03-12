
import UIKit
import SafariServices

class AboutUsPage: LoaferPage {
    
    private let stackView = UIStackView()
    private let termsButton = AboutUsItem()
    private let policyButton = AboutUsItem()
    private var config = UIButton.Configuration.plain()
    private let iconView = UIImageView(image: "".toImage)
    private let nameLabel = UILabel()
    private let versionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews {
            stackView
            termsButton
            policyButton
        }
        view.layout {
            UIDevice.topFullHeight + 30.FIT
            stackView.centerHorizontally().height(156.FIT)
            50.FIT
            |termsButton| ~ 60.FIT
            0
            |policyButton| ~ 60.FIT
        }
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(10.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalSpacing)
        termsButton.setSourceData(("Terms of Use", LoaferAppSettings.Config.TERMSOFUSE))
        policyButton.setSourceData(("Privacy Policy", LoaferAppSettings.Config.PRIVACYPOLICY))
        nameLabel
            .loafer_font(18, .bold)
            .loafer_text(LoaferAppSettings.URLSettings.NAME)
            .loafer_textColor("C7B0CE")
            .loafer_textAligment(.center)
        versionLabel
            .loafer_font(16, .medium)
            .loafer_text(LoaferAppSettings.URLSettings.VERSION)
            .loafer_textColor("5E4081")
            .loafer_textAligment(.center)
        iconView
            .loafer_cornerRadius(23.FIT)
            .loafer_backColor(.randomColor)
        iconView.size(100.FIT)
        nameLabel.height(22.FIT)
        versionLabel.height(20.FIT)
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(versionLabel)
    }
    
}

private class AboutUsItem: UIView, SourceProtocol {
    
    typealias SourceData = (String, String)
    
    private let itemTitle = UILabel()
    private let nextView = UIImageView(image: "Loafer_SettingsPage_Next".toImage)
    private(set) var urlString: String!
    
    func setSourceData(_ data: (String, String)) {
        itemTitle.loafer_text(data.0)
        urlString = data.1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            itemTitle
            nextView
        }
        |-15.FIT-itemTitle.centerVertically()-nextView.centerVertically().width(12.FIT).height(22.FIT)-15.FIT-|
        itemTitle
            .loafer_font(19, .semiBold)
            .loafer_textColor("FFFFFF")
        let tap = UITapGestureRecognizer(target: self, action: #selector(loaferAboutUsItem))
        addGestureRecognizer(tap)
    }
    
    @objc private func loaferAboutUsItem() {
        if let url = urlString.toURL, let page = iq.parentContainerViewController() {
            let safari = SFSafariViewController(url: url)
            page.present(safari, animated: true, completion: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
