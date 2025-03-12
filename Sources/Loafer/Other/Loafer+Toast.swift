
import GSMessages
import UIKit
import Lottie
import SwiftEntryKit

enum ToastType {
    case activity
    case success
    case failure
}

// MARK: - ToastLoadingView

class ToastLoadingProvider: UIView {
    private let showView = LottieAnimationView(name: "LoadingView")
    private let loadLabel = UILabel()
    
    init(content: String? = nil) {
        super.init(frame: .zero)
        backgroundColor = "000000".toColor.withAlphaComponent(0.4)
        subviews {
            showView
            loadLabel
        }
        showView.centerInContainer().size(80.FIT)
        loadLabel.Top == showView.Bottom + 10.FIT
        loadLabel.leading(0).trailing(0).height(15.FIT)
        showView.style { v in
            v.contentMode = .scaleAspectFill
            v.loopMode = .loop
            v.animationSpeed = 1
            v.shouldRasterizeWhenIdle = true
            v.backgroundBehavior = .pauseAndRestore
            v.play()
        }
        loadLabel.style{ v in
            v.font = .setFont(16, .bold)
            v.textColor = "FFFFFF".toColor
            v.textAlignment = .center
            v.text = content
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct ToastTool {
    
    static func show(_ type: ToastType = .activity, _ content: String? = nil) {
        if type == .activity {
            var attributes: EKAttributes
            attributes = .centerFloat
            attributes.name = "ToastTool"
            attributes.displayDuration = .infinity
            attributes.screenBackground = .color(color: .black.with(alpha: 0.4))
            attributes.entryInteraction = .absorbTouches
            attributes.scroll = .disabled
            attributes.entranceAnimation = .init(fade: .init(from: 0, to: 1, duration: 0.3))
            attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.3))
            attributes.popBehavior = .animated(animation: .init(fade: .init(from: 1, to: 0, duration: 0.3)))
            attributes.positionConstraints.size = .screen
            DispatchQueue.main.async {
                SwiftEntryKit.display(entry: ToastLoadingProvider(content: content), using: attributes)
            }
        }else {
            dismiss()
            DispatchQueue.main.async {
                GSMessage.font = .setFont(14)
                GSMessage.successBackgroundColor = "333333".toColor
                GSMessage.errorBackgroundColor   = "333333".toColor
                UIApplication.mainWindow.showMessage(content ?? "", type: type == .success ? .success : .error, options: [
                    .margin(.init(top: 15.FIT, left: 40.FIT, bottom: 15.FIT, right: 40.FIT)),
                    .textNumberOfLines(0),
                    .cornerRadius(20)
                ])
            }
        }
    }
    
    static func dismiss() {
        SwiftEntryKit.dismiss(.specific(entryName: "ToastTool"), with: nil)
    }
    
}
