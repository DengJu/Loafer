
import UIKit
import YDRootNavigationController

class MainNavAppearance: YDAppAppearanceProtocol {
    
    var titleTextAttributes: [NSAttributedString.Key : Any]? {
        [.font: UIFont.setFont(21, .bold), .foregroundColor: #colorLiteral(red: 0.8823529412, green: 0.8235294118, blue: 0.9176470588, alpha: 1)]
    }
    
    var backItemImage: UIImage? {
        "Loafer_NewUserRechargeView_Close".toImage.withRenderingMode(.alwaysOriginal)
    }
    
    var isFullScreenPopGestureEnabled: Bool {
        true
    }
    
//    var backItemImageInsets: UIEdgeInsets? {
//        UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
//    }
    
    var navigationBarBackgroundColor: UIColor? {
        #colorLiteral(red: 0.06274509804, green: 0.07058823529, blue: 0.0862745098, alpha: 0)
    }
    
    var navigationBarShadowColor: UIColor? {
        #colorLiteral(red: 0.06274509804, green: 0.07058823529, blue: 0.0862745098, alpha: 0)
    }
    
    var isHidesBottomBarWhenPushed: Bool {
        true
    }
    
}

class BasicNavigationPage: YDRootNavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

