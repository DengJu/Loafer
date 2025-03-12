
import UIKit

class ActivityTitleView: UIView {
    
    private let stackView = UIStackView()
    private let timeView = UILabel()
    private let iconView = UIImageView(image: "Loafer_ConversationPage_Cutdown".toImage)
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loafer_cornerRadius(15.FIT)
        loafer_backColor("FFFFFF", 0.1)
        height(30.FIT)
        subviews {
            stackView
        }
        stackView.followEdges(self, leading: 10.FIT, trailing: -10.FIT)
        stackView.addArrangedSubview(timeView)
        stackView.addArrangedSubview(iconView)
        iconView.size(21.FIT)
        stackView
            .loafer_axis(.horizontal)
            .loafer_spacing(6.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.fill)
        timeView
            .loafer_font(18, .bold)
            .loafer_textColor("FF269C")
            .loafer_textAligment(.center)
        let tap = UITapGestureRecognizer(target: self, action: #selector(loaferActivityViewCall))
        addGestureRecognizer(tap)
        if LoaferAppSettings.Gems.remainingTime > 0 {
            if timer == nil {
                var cutTime = LoaferAppSettings.Gems.remainingTime
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {[weak self] t in
                    let hours = cutTime / 3600
                    let minutes = (cutTime / 60) % 60
                    let seconds = cutTime % 60
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PASSCUTTIMETOFIRSTGUIDEVIEW"), object: String(format: "%02d:%02d:%02d", hours, minutes, seconds))
                    self?.timeView.loafer_text(String(format: "%02d:%02d:%02d", hours, minutes, seconds))
                    cutTime -= 1
                    if cutTime < 0 {
                        t.invalidate()
                        LoaferAppSettings.Gems.avtiveItems = nil
                        self?.timer?.invalidate()
                        self?.timer = nil
                        self?.removeFromSuperview()
                    }
                })
            }
        }
    }
    
    @objc func loaferActivityViewCall() {
        if LoaferAppSettings.Gems.isNeedPopup {
            let aView = NewUserGemsGuideView()
            aView.isMuteCutDown = false
            aView.setSourceData(LoaferAppSettings.Gems.avtiveItems!)
            PopUtil.pop(show: aView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
