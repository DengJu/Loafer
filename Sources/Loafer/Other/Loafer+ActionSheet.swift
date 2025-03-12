
import UIKit

enum LoaferActionSheetItem: String {
    case Report
    case Block
    case Follow
    case Unfollow
    case Consult
    case Album
    case Camera
    
    var color: String { "C7B0CE" }
    
    var title: String {
        switch self {
        case .Consult: return "Consult Now"
        default: return rawValue
        }
    }
    
}

class LoaferActionSheetView: UIView {
    
    private let stackView = UIStackView()
    private let cancelBtn = UIButton(type: .custom)
    
    var didSelectItems: ((_ item: LoaferActionSheetItem) -> Void)?
    
    private(set) var funcItems: [LoaferActionSheetItem] = []
    
    init(items: [LoaferActionSheetItem]) {
        super.init(frame: .zero)
        funcItems = items
        if items.isEmpty { fatalError("items can not NULL!") }
        subviews {
            cancelBtn
            stackView
        }
        let stackHeight = CGFloat(funcItems.count) * 50.FIT
        layout {
            |-20.FIT-stackView-20.FIT-| ~ stackHeight
            10.FIT
            |-20.FIT-cancelBtn-20.FIT-| ~ 50.FIT
            UIDevice.safeBottom
        }
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(0)
            .loafer_alignment(.fill)
            .loafer_distribution(.fill)
            .loafer_backColor("46123E")
            .loafer_cornerRadius(20.FIT)
        for i in 0..<items.count {
            let item = UIButton(type: .custom)
            item
                .loafer_font(18, .bold)
                .loafer_text(items[i].title)
                .loafer_titleColor(items[i].color)
                .loafer_tag(i+1001)
                .loafer_target(self, selector: #selector(completionDidSelectItems(_:)))
            item.height(50.FIT).width(UIDevice.screenWidth-40.FIT)
            stackView.addArrangedSubview(item)
        }
        cancelBtn
            .loafer_font(18, .bold)
            .loafer_titleColor("FE269C")
            .loafer_text("Cancel")
            .loafer_backColor("46123E")
            .loafer_cornerRadius(20.FIT)
            .loafer_target(self, selector: #selector(completionDidFunctionItemCancel))
    }
    
    @objc private func completionDidFunctionItemCancel() {
        PopUtil.dismiss(from: self)
    }
    
    @objc private func completionDidSelectItems(_ sender: UIButton) {
        guard let closure = didSelectItems else { return }
        closure(funcItems[sender.tag - 1001])
        PopUtil.dismiss(from: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fatalError("init(items:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension LoaferActionSheetView: PopProtocol {
    func popViewSize() -> CGSize { CGSize(width: UIDevice.screenWidth, height: UIDevice.screenHeight) }
    func popViewStyle() -> PopType { .bottom }
    func popScreenInteraction() -> EKAttributes.UserInteraction { .dismiss }
    func popScroll() -> EKAttributes.Scroll { .enabled(swipeable: true, pullbackAnimation: .easeOut) }
}
