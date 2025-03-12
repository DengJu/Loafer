
import Foundation
import UIKit

public protocol StatusModel {
    var isLoading: Bool { get }
    var title: String? { get }
    var description: String? { get }
    var actionTitle: String? { get }
    var image: UIImage? { get }
    var action: (() -> Void)? { get }
}

public extension StatusModel {
    var isLoading: Bool {
        return false
    }

    var title: String? {
        return nil
    }

    var description: String? {
        return nil
    }

    var actionTitle: String? {
        return nil
    }

    var image: UIImage? {
        return nil
    }

    var action: (() -> Void)? {
        return nil
    }
}

public struct Status: StatusModel {
    public let isLoading: Bool
    public let title: String?
    public let description: String?
    public let actionTitle: String?
    public let image: UIImage?
    public let action: (() -> Void)?

    public init(isLoading: Bool = false, title: String? = nil, description: String? = nil, actionTitle: String? = nil, image: UIImage? = nil, action: (() -> Void)? = nil) {
        self.isLoading = isLoading
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.image = image
        self.action = action
    }

    public static var simpleLoading: Status {
        return Status(isLoading: true)
    }
}

public protocol StatusView: NSObject {
    var status: StatusModel? { set get }
    var view: UIView { get }
}

public protocol StatusController {
    var onView: StatusViewContainer { get }
    var statusView: StatusView? { get }

    func show(status: StatusModel)
    func hideStatus()
}

public extension StatusController {
    var statusView: StatusView? {
        return DefaultStatusView()
    }

    func hideStatus() {
        onView.statusContainerView = nil
    }

    fileprivate func _show(status: StatusModel) {
        guard let sv = statusView else { return }
        sv.status = status
        onView.statusContainerView = sv.view
    }
}

public extension StatusController where Self: UIView {
    var onView: StatusViewContainer {
        return self
    }

    func show(status: StatusModel) {
        _show(status: status)
    }
}

public extension StatusController where Self: UIViewController {
    var onView: StatusViewContainer {
        return view
    }

    func show(status: StatusModel) {
        _show(status: status)

        #if os(tvOS)
            setNeedsFocusUpdate()
            updateFocusIfNeeded()
        #endif
    }
}

public extension StatusController where Self: UITableViewController {
    var onView: StatusViewContainer {
        if let backgroundView = tableView.backgroundView {
            return backgroundView
        }
        return view
    }

    func show(status: StatusModel) {
        _show(status: status)

        #if os(tvOS)
            setNeedsFocusUpdate()
            updateFocusIfNeeded()
        #endif
    }
}

public protocol StatusViewContainer: NSObject {
    var statusContainerView: UIView? { get set }
}

extension UIView: StatusViewContainer {
    public static let StatusViewTag = 666

    public var statusContainerView: UIView? {
        get {
            return viewWithTag(UIView.StatusViewTag)
        }
        set {
            viewWithTag(UIView.StatusViewTag)?.removeFromSuperview()

            guard let view = newValue else { return }

            view.tag = UIView.StatusViewTag
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: centerXAnchor),
                view.centerYAnchor.constraint(equalTo: centerYAnchor),
                view.leadingAnchor.constraint(greaterThanOrEqualTo: readableContentGuide.leadingAnchor),
                view.trailingAnchor.constraint(lessThanOrEqualTo: readableContentGuide.trailingAnchor),
                view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            ])
        }
    }
}


open class DefaultStatusView: UIView, StatusView {
    public var view: UIView {
        return self
    }

    public var status: StatusModel? {
        didSet {
            guard let status = status else { return }

            imageView.image = status.image
            titleLabel.text = status.title
            descriptionLabel.text = status.description
            #if swift(>=4.2)
                actionButton.setTitle(status.actionTitle, for: UIControl.State())
            #else
                actionButton.setTitle(status.actionTitle, for: UIControlState())
            #endif

            if status.isLoading {
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.stopAnimating()
            }
            activityIndicatorView.color = "FFFFFF".toColor
            imageView.isHidden = imageView.image == nil
            titleLabel.isHidden = titleLabel.text == nil
            descriptionLabel.isHidden = descriptionLabel.text == nil
            actionButton.isHidden = status.action == nil

            verticalStackView.isHidden = imageView.isHidden && descriptionLabel.isHidden && actionButton.isHidden
        }
    }

    public let titleLabel: UILabel = {
        $0.font = .setFont(21, .bold)
        $0.textColor = "C7B0CE".toColor
        $0.textAlignment = .center

        return $0
    }(UILabel())

    public let descriptionLabel: UILabel = {
        $0.font = .setFont(17, .medium)
        $0.textColor = "C7B0CE".toColor
        $0.textAlignment = .center
        $0.numberOfLines = 0

        return $0
    }(UILabel())

    #if swift(>=4.2)
        public let activityIndicatorView: UIActivityIndicatorView = {
            $0.isHidden = true
            $0.hidesWhenStopped = true
            #if os(tvOS)
                $0.style = .whiteLarge
            #endif
            #if os(iOS)
                $0.style = .medium
            #endif
            return $0
        }(UIActivityIndicatorView(style: .large))
    #else
        public let activityIndicatorView: UIActivityIndicatorView = {
            $0.isHidden = true
            $0.hidesWhenStopped = true
            #if os(tvOS)
                $0.activityIndicatorViewStyle = .whiteLarge
            #endif

            #if os(iOS)
                $0.activityIndicatorViewStyle = .gray
            #endif
            return $0
        }(UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge))
    #endif

    public let imageView: UIImageView = {
        $0.contentMode = .center

        return $0
    }(UIImageView())

    public let actionButton: UIButton = {
        $0.titleLabel?.font = UIFont.setFont(24, .bold)
        $0.setTitleColor("FF26C5".toColor, for: .normal)
        return $0
    }(UIButton(type: .system))

    public let verticalStackView: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .center

        return $0
    }(UIStackView())

    public let horizontalStackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center

        return $0
    }(UIStackView())

    override public init(frame: CGRect) {
        super.init(frame: frame)

        actionButton.addTarget(self, action: #selector(DefaultStatusView.actionButtonAction), for: .touchUpInside)

        addSubview(horizontalStackView)

        horizontalStackView.addArrangedSubview(activityIndicatorView)
        horizontalStackView.addArrangedSubview(verticalStackView)

        verticalStackView.addArrangedSubview(imageView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(descriptionLabel)
        actionButton.width(225.FIT).height(50.FIT)
        verticalStackView.addArrangedSubview(actionButton)

        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            horizontalStackView.topAnchor.constraint(equalTo: topAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    #if os(tvOS)
        override open var preferredFocusEnvironments: [UIFocusEnvironment] {
            return [actionButton]
        }
    #endif

    @objc func actionButtonAction() {
        status?.action?()
    }

    override open var tintColor: UIColor! {
        didSet {
            titleLabel.textColor = tintColor
            descriptionLabel.textColor = tintColor
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
