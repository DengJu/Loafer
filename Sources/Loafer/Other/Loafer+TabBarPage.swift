
import UIKit
import TransitionableTab

class LoaferTabBarPage: UITabBarController {

    let finalTabBar = LoaferTabBar()
    private let finalTitles: [String] = ["RandomChat", "List", "Conversation", "Myself"]
    private let finalPages: [LoaferPage] = [RandomChatPage(), ListDataPage(), ConversationPage(), MyselfPage()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.loafer_backColor("000000")
        delegate = self
        setValue(finalTabBar, forKey: "tabBar")
        for i in 0..<finalPages.count {
            configuration(viewController: finalPages[i], title: finalTitles[i])
        }
    }
    
    func configuration(viewController: UIViewController, title: String) {
        viewController.tabBarItem.image = ("LoaferTabBar_" + title).toImage.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.selectedImage = ("LoaferTabBar_" + title + "_SEL").toImage.withRenderingMode(.alwaysOriginal)
        let nav = BasicNavigationPage(rootViewController: viewController)
        addChild(nav)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func refreshUnreadCount() {
        let unreadCount = RealmProvider.share.queryAllUnreadMessageCount()
        for page in finalPages {
            if page is ConversationPage {
                page.tabBarItem.badgeValue = unreadCount > 0 ? (unreadCount > 99 ? "99+" : "\(unreadCount)") : nil
                page.tabBarItem.badgeColor = "FF0000".toColor
            }
        }
    }

}

extension LoaferTabBarPage: TransitionableTab {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        return animateTransition(tabBarController, shouldSelect: viewController)
    }
    
    func fromTransitionAnimation(layer: CALayer?, direction: Direction) -> CAAnimation {
        return DefineAnimation.scale(.from, min: 0.9)
    }
    
    func toTransitionAnimation(layer: CALayer?, direction: Direction) -> CAAnimation {
        return DefineAnimation.scale(.to, min: 0.9)
    }
    
}

class LoaferTabBar: UITabBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let appearance = UITabBarAppearance()
        appearance.backgroundImage = nil
        appearance.backgroundColor = "101216".toColor
        appearance.shadowColor = nil
        appearance.backgroundEffect = nil
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
