
import Foundation

class OnlyonceView: UIView {
    
    private let stackView = UIStackView()
    private let contentLabel = UILabel()
    private let iconView = UIImageView(image: "Loafer_ConversationPage_Cutdown".toImage)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loafer_cornerRadius(15.FIT)
        loafer_backColor("FFFFFF", 0.1)
        height(30.FIT)
        subviews {
            stackView
        }
        stackView.followEdges(self, leading: 10.FIT, trailing: -10.FIT)
        stackView.addArrangedSubview(contentLabel)
        stackView.addArrangedSubview(iconView)
        iconView.size(21.FIT)
        stackView
            .loafer_axis(.horizontal)
            .loafer_spacing(6.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.fill)
        contentLabel
            .loafer_font(18, .bold)
            .loafer_textColor("FF269C")
            .loafer_textAligment(.center)
            .loafer_text("Only Once")
        let tap = UITapGestureRecognizer(target: self, action: #selector(loaferActivityViewCall))
        addGestureRecognizer(tap)
    }
    
    @objc func loaferActivityViewCall() {
        if let limitData = LoaferAppSettings.Gems.limitOnceItems {
            let aView = NewUserGemsGuideView()
            aView.isMuteCutDown = true
            aView.setSourceData(limitData)
            PopUtil.pop(show: aView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
