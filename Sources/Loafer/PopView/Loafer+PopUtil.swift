
import UIKit
import SwiftEntryKit

enum PopType {
    case center, bottom
}

protocol PopProtocol: NSObjectProtocol {
    
    func popViewSize() -> CGSize
    
    func popViewStyle() -> PopType
    
    func popScreenInteraction() -> EKAttributes.UserInteraction
    
    func popScroll() -> EKAttributes.Scroll
    
    func animate(customAttributes attributes: EKAttributes) -> EKAttributes
}

extension PopProtocol {
   
    func popViewSize() -> CGSize {
        return .zero
    }
    
    func popViewStyle() -> PopType {
        .center
    }
    
    func popScreenInteraction() -> EKAttributes.UserInteraction {
        .dismiss
    }
    
    func popScroll() -> EKAttributes.Scroll {
        .disabled
    }
    
    func animate(customAttributes attributes: EKAttributes) -> EKAttributes {
        return attributes
    }
    
}

struct PopUtil {
    
    static let isViewDisplaying: Bool = SwiftEntryKit.isCurrentlyDisplaying
    
    static func pop(show delegate: PopProtocol?, isFloating: Bool = false) {
        UIApplication.mainWindow.endEditing(true)
        var entryName = ""
        var containerSize = delegate?.popViewSize() ?? .zero
        if let containerView = delegate as? UIView {
            if containerSize.isZero { containerSize = containerView.frame.size }
            entryName = NSStringFromClass(containerView.classForCoder)
        }
        if let controller = delegate as? UIViewController {
            if containerSize.isZero { containerSize = controller.view.frame.size }
            entryName = NSStringFromClass(controller.classForCoder)
        }
        var attributes: EKAttributes = creatPopup(delegate, viewSize: containerSize, isFloating: isFloating)
        attributes.name = entryName
        
        if let containerView = delegate as? UIView { SwiftEntryKit.display(entry: containerView, using: attributes) }
        if let controller = delegate as? UIViewController { SwiftEntryKit.display(entry: controller, using: attributes) }
    }
    
    static func dismiss(from delegate: PopProtocol?, completion: (() -> Void)? = nil) {
        var entryName = ""
        if let containerView = delegate as? UIView { entryName = NSStringFromClass(containerView.classForCoder) }
        if let controller = delegate as? UIViewController { entryName = NSStringFromClass(controller.classForCoder) }
        SwiftEntryKit.dismiss(entryName.isEmpty ? .all : .specific(entryName: entryName), with: completion)
    }
    
    private static func creatPopup(_ delegate: PopProtocol?, viewSize: CGSize, isFloating: Bool) -> EKAttributes {
        if isFloating {
            var attributes = EKAttributes.bottomFloat
            attributes.hapticFeedbackType = .success
            attributes.displayDuration = .infinity
            attributes.entryBackground = .color(color: .clear)
            attributes.screenBackground = .color(color: .black.with(alpha: 0.8))
            attributes.shadow = .active(
                with: .init(
                    color: .black,
                    opacity: 0.3,
                    radius: 8
                )
            )
            attributes.screenInteraction = .dismiss
            attributes.entryInteraction = .absorbTouches
            attributes.scroll = .enabled(
                swipeable: true,
                pullbackAnimation: .jolt
            )
            attributes.roundCorners = .all(radius: 25)
            attributes.entranceAnimation = .init(
                translate: .init(
                    duration: 0.7,
                    spring: .init(damping: 1, initialVelocity: 0)
                ),
                scale: .init(
                    from: 1.05,
                    to: 1,
                    duration: 0.4,
                    spring: .init(damping: 1, initialVelocity: 0)
                )
            )
            attributes.exitAnimation = .init(
                translate: .init(duration: 0.2)
            )
            attributes.popBehavior = .animated(
                animation: .init(
                    translate: .init(duration: 0.2)
                )
            )
            attributes.positionConstraints.verticalOffset = 10
            attributes.positionConstraints.size = .init(
                width: .fill,
                height: .intrinsic
            )
            attributes.positionConstraints.maxSize = .init(
                width: .constant(value: viewSize.width),
                height: .constant(value: viewSize.height)
            )
            attributes.statusBar = .dark
            return attributes
        } else {
            var attributes: EKAttributes = EKAttributes.default
            let viewStyle = delegate?.popViewStyle() ?? .center
            if viewStyle == .center {
                attributes = EKAttributes.centerFloat
                attributes.screenInteraction = .init()
                attributes.scroll = .disabled
            } else if viewStyle == .bottom {
                attributes = EKAttributes.bottomFloat
                attributes.screenInteraction = .dismiss
                attributes.scroll = .disabled
                attributes.positionConstraints.safeArea = .overridden
                attributes.positionConstraints.verticalOffset = 0
            }
            attributes.screenInteraction = delegate?.popScreenInteraction() ?? .dismiss
            attributes.scroll = delegate?.popScroll() ?? .disabled
            
            attributes.displayDuration = .infinity
            attributes.screenBackground = .color(color: .black.with(alpha: 0.6))
            attributes.shadow = .active(
                with: .init(
                    color: .black,
                    opacity: 0.3,
                    radius: 8
                )
            )
            attributes.entranceAnimation = .init(
                translate: .init(
                    duration: 0.7,
                    spring: .init(damping: 0.7, initialVelocity: 0)
                ),
                scale: .init(
                    from: 0.7,
                    to: 1,
                    duration: 0.4,
                    spring: .init(damping: 1, initialVelocity: 0)
                )
            )
            attributes.entryInteraction = .absorbTouches
            attributes.exitAnimation = .init(translate: .init(duration: 0.2))
            attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.35)))
            attributes.positionConstraints.size = .init(
                width: .constant(value: viewSize.width),
                height: .constant(value: viewSize.height)
            )
            attributes = delegate?.animate(customAttributes: attributes) ?? attributes
            attributes.hapticFeedbackType = .success
            return attributes
        }
    }
    
    static func dismissAll() {
        SwiftEntryKit.dismiss()
    }
    
}

// MARK: - CGSize

extension CGSize {
    var isZero: Bool {
        width.isZero || height.isZero
    }
}
