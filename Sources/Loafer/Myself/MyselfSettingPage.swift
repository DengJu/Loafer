
import UIKit

class MyselfSettingPage: LoaferPage {
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let signOutButton = UIButton(type: .custom)
    private let source: [String] = ["About us", "Rate us", "Delete account", "Clear cache"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        view.subviews {
            collectionView
            signOutButton
        }
        let listHeight = CGFloat(source.count) * 70.FIT
        view.layout {
            UIDevice.topFullHeight
            |collectionView| ~ listHeight
            95.FIT
            |-35.FIT-signOutButton-35.FIT-| ~ 50.FIT
        }
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIDevice.screenWidth, height: 70.FIT)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView
            .loafer_layout(layout)
            .loafer_register(SettingItem.self, SettingItem.description())
            .loafer_backColor(.clear)
            .loafer_delegate(self)
            .loafer_dataSource(self)
        signOutButton
            .loafer_font(20, .bold)
            .loafer_text("Log out")
            .loafer_titleColor("FFFFFF", 0.6)
            .loafer_cornerRadius(25.FIT)
            .loafer_backColor("5E4081", 0.6)
            .loafer_target(self, selector: #selector(loaferMyselfSettingPageSignOutButton))
    }
    
    @objc private func loaferMyselfSettingPageSignOutButton() {
        
    }
    
}

extension MyselfSettingPage: UICollectionViewDelegate & UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: SettingItem.description(), for: indexPath) as? SettingItem else { return UICollectionViewCell() }
        item.setSourceData(source[indexPath.row])
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            navigationController?.pushViewController(AboutUsPage(), animated: true)
        }else if indexPath.row == 1 {
            
        }else if indexPath.row == 2 {
            PopUtil.pop(show: DeleteAccountView())
        }else if indexPath.row == 3 {
            
        }
    }
    
}

class SettingItem: UICollectionViewCell, SourceProtocol {
    
    typealias SourceData = String
    
    private let itemTitle = UILabel()
    private let nextView = UIImageView(image: "Loafer_SettingsPage_Next".toImage)
    
    func setSourceData(_ data: String) {
        itemTitle.loafer_text(data)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.subviews {
            itemTitle
            nextView
        }
        |-15.FIT-itemTitle.centerVertically()-nextView.centerVertically().width(12.FIT).height(22.FIT)-15.FIT-|
        itemTitle
            .loafer_font(19, .semiBold)
            .loafer_textColor("FFFFFF")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
