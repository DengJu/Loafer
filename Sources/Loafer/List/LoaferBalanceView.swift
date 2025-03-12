
import UIKit

class BalanceView: UIView {
    
    private let stackView = UIStackView()
    private let balanceLabel = UILabel()
    private let iconView = UIImageView(image: "Loafer_Basic_BalanceCoins".toImage)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loafer_cornerRadius(15.FIT)
        loafer_backColor("FFFFFF", 0.1)
        height(30.FIT)
        subviews {
            stackView
        }
        stackView.followEdges(self, leading: 10.FIT, trailing: -10.FIT)
        stackView.addArrangedSubview(balanceLabel)
        stackView.addArrangedSubview(iconView)
        iconView.size(21.FIT)
        stackView
            .loafer_axis(.horizontal)
            .loafer_spacing(6.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.fill)
        balanceLabel
            .loafer_font(18, .bold)
            .loafer_textColor("FF26C5")
            .loafer_textAligment(.center)
            .loafer_text("\(LoaferAppSettings.UserInfo.user.coinBalance)")
        let tap = UITapGestureRecognizer(target: self, action: #selector(loaferCallRechargeGemsView))
        addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "REFRESH-USER-BALANCE"), object: nil, queue: .main) {[weak self] _ in
            self?.balanceLabel.loafer_text("\(LoaferAppSettings.UserInfo.user.coinBalance)")
        }
    }
    
    @objc private func loaferCallRechargeGemsView() {
        PopUtil.pop(show: RechargeGemsView())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
