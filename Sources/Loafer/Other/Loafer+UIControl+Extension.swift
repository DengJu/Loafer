
import UIKit
import Nuke

public extension UIStackView {
    @discardableResult
    func loafer_axis(_ a: NSLayoutConstraint.Axis) -> Self {
        axis = a
        return self
    }
    
    @discardableResult
    func loafer_alignment(_ a: UIStackView.Alignment) -> Self {
        alignment = a
        return self
    }
    
    @discardableResult
    func loafer_spacing(_ a: CGFloat) -> Self {
        spacing = a
        return self
    }
    
    @discardableResult
    func loafer_distribution(_ a: UIStackView.Distribution) -> Self {
        distribution = a
        return self
    }
}

public extension UITableView {
    @discardableResult
    func loafer_separatorStyle(_ s: UITableViewCell.SeparatorStyle) -> Self {
        separatorStyle = s
        return self
    }
    
    @discardableResult
    func loafer_rowHeight(_ r: CGFloat) -> Self {
        rowHeight = r
        return self
    }
    
    @discardableResult
    func loafer_register(_ cellClass: AnyClass, _ identifier: String) -> Self {
        register(cellClass.self, forCellReuseIdentifier: identifier)
        return self
    }
    
    @discardableResult
    func loafer_delegate(_ d: UITableViewDelegate) -> Self {
        delegate = d
        return self
    }
    
    @discardableResult
    func loafer_dataSource(_ d: UITableViewDataSource) -> Self {
        dataSource = d
        return self
    }
}

public extension UIScrollView {
    @discardableResult
    func loafer_contentInsetAdjustmentBehavior(_ l: UIScrollView.ContentInsetAdjustmentBehavior) -> Self {
        contentInsetAdjustmentBehavior = l
        return self
    }
    
    @discardableResult
    func loafer_bounces(_ l: Bool) -> Self {
        bounces = l
        return self
    }
    
    @discardableResult
    func loafer_isScrollEnabled(_ l: Bool) -> Self {
        isScrollEnabled = l
        return self
    }
    
    @discardableResult
    func loafer_showsHorizontalScrollIndicator(_ l: Bool) -> Self {
        showsHorizontalScrollIndicator = l
        return self
    }
    
    @discardableResult
    func loafer_showsVerticalScrollIndicator(_ l: Bool) -> Self {
        showsVerticalScrollIndicator = l
        return self
    }
    
    @discardableResult
    func loafer_isPageble(_ l: Bool) -> Self {
        isPagingEnabled = l
        return self
    }
}

public extension UICollectionView {
    @discardableResult
    func loafer_layout(_ l: UICollectionViewLayout) -> Self {
        collectionViewLayout = l
        return self
    }
    
    @discardableResult
    func loafer_register(_ cellClass: AnyClass, _ identifier: String) -> Self {
        register(cellClass.self, forCellWithReuseIdentifier: identifier)
        return self
    }
    
    @discardableResult
    func loafer_delegate(_ d: UICollectionViewDelegate) -> Self {
        delegate = d
        return self
    }
    
    @discardableResult
    func loafer_dataSource(_ d: UICollectionViewDataSource) -> Self {
        dataSource = d
        return self
    }
}

// MARK: - UIView

public extension UIView {
    @discardableResult
    func loafer_alpha(_ s: CGFloat) -> Self {
        alpha = s
        return self
    }
    
    @discardableResult
    func loafer_contentMode(_ m: UIView.ContentMode) -> Self {
        contentMode = m
        return self
    }
    
    @discardableResult
    func loafer_isUserInteractionEnabled(_ s: Bool) -> Self {
        isUserInteractionEnabled = s
        return self
    }
    
    @discardableResult
    func loafer_tag(_ t: Int) -> Self {
        tag = t
        return self
    }
    
    @discardableResult
    func loafer_isHidden(_ h: Bool) -> Self {
        isHidden = h
        return self
    }
    
    @discardableResult
    func loafer_backColor(_ c: String) -> Self {
        backgroundColor = c.toColor
        return self
    }
    
    @discardableResult
    func loafer_backColor(_ r: UIColor) -> Self {
        backgroundColor = r
        return self
    }
    
    @discardableResult
    func loafer_backColor(_ c: String, _ alpha: CGFloat) -> Self {
        backgroundColor = c.toColor.withAlphaComponent(alpha)
        return self
    }
    
    @discardableResult
    func loafer_clipsToBounds(_ c: Bool) -> Self {
        clipsToBounds = c
        return self
    }
    
    @discardableResult
    func loafer_cornerRadius(_ r: CGFloat) -> Self {
        if self is UIImageView || self is UILabel {
            layer.cornerRadius = r
            layer.masksToBounds = true
        } else {
            layer.cornerRadius = r
            layer.maskedCorners = .AllCorner
        }
        return self
    }
    
    @discardableResult
    func loafer_cornerRadius(_ r: CGFloat, _ m: CACornerMask) -> Self {
        if self is UIImageView || self is UILabel {
            layer.cornerRadius = r
            layer.masksToBounds = true
        } else {
            layer.cornerRadius = r
            layer.maskedCorners = m
        }
        return self
    }
    
    @discardableResult
    func loafer_border(_ c: String, _ w: CGFloat) -> Self {
        layer.borderColor = c.toColor.cgColor
        layer.borderWidth = w
        return self
    }
    
    @discardableResult
    func loafer_border(_ c: String, _ a: CGFloat = 1.0, _ w: CGFloat) -> Self {
        layer.borderColor = c.toColor.withAlphaComponent(a).cgColor
        layer.borderWidth = w
        return self
    }
    
    @discardableResult
    func loafer_tapGesure(_ target: Any?, selector: Selector) -> Self {
        let tapGesture = UITapGestureRecognizer(target: target, action: selector)
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)
        return self
    }
}

// MARK: - UITextView

public extension UITextView {
    @discardableResult
    func loafer_textColor(_ c: String) -> Self {
        textColor = c.toColor
        return self
    }
    
    @discardableResult
    func loafer_text(_ c: String) -> Self {
        text = NSLocalizedString(c, comment: "")
        return self
    }
    
    @discardableResult
    func loafer_textColor(_ c: String, _ alpha: CGFloat) -> Self {
        textColor = c.toColor.withAlphaComponent(alpha)
        return self
    }
    
    @discardableResult
    func loafer_tintColor(_ c: String) -> Self {
        tintColor = c.toColor
        return self
    }
    
    @discardableResult
    func loafer_keyboardType(_ t: UIKeyboardType) -> Self {
        keyboardType = t
        return self
    }
    
    @discardableResult
    func loafer_returnKeyType(_ t: UIReturnKeyType) -> Self {
        returnKeyType = t
        return self
    }
    
    @discardableResult
    func loafer_tintColor(_ c: String, _ alpha: CGFloat) -> Self {
        tintColor = c.toColor.withAlphaComponent(alpha)
        return self
    }
    
    @discardableResult
    func loafer_font(_ s: CGFloat) -> Self {
        font = .setFont(s)
        return self
    }
    
    @discardableResult
    func loafer_font(_ s: CGFloat, _ t: UIFont.FontType) -> Self {
        font = .setFont(s, t)
        return self
    }
    
    @discardableResult
    func loafer_textAligment(_ a: NSTextAlignment) -> Self {
        textAlignment = a
        return self
    }
    
    @discardableResult
    func loafer_textContainerInset(_ t: CGFloat, _ l: CGFloat, _ b: CGFloat, _ r: CGFloat) -> Self {
        textContainerInset = UIEdgeInsets(top: t, left: l, bottom: b, right: r)
        return self
    }
}

// MARK: - UITextField

public extension UITextField {
    @discardableResult
    func loafer_placeholder(_ t: String) -> Self {
        placeholder = NSLocalizedString(t, comment: "")
        return self
    }
    
    @discardableResult
    func loafer_textColor(_ c: String) -> Self {
        textColor = c.toColor
        return self
    }
    
    @discardableResult
    func loafer_text(_ c: String) -> Self {
        text = NSLocalizedString(c, comment: "")
        return self
    }
    
    @discardableResult
    func loafer_textColor(_ c: String, _ alpha: CGFloat) -> Self {
        textColor = c.toColor.withAlphaComponent(alpha)
        return self
    }
    
    @discardableResult
    func loafer_tintColor(_ c: String) -> Self {
        tintColor = c.toColor
        return self
    }
    
    @discardableResult
    func loafer_keyboardType(_ t: UIKeyboardType) -> Self {
        keyboardType = t
        return self
    }
    
    @discardableResult
    func loafer_returnKeyType(_ t: UIReturnKeyType) -> Self {
        returnKeyType = t
        return self
    }
    
    @discardableResult
    func loafer_tintColor(_ c: String, _ alpha: CGFloat) -> Self {
        tintColor = c.toColor.withAlphaComponent(alpha)
        return self
    }
    
    @discardableResult
    func loafer_target(_ target: Any?, selector: Selector, event: UIControl.Event = .editingChanged) -> Self {
        addTarget(target, action: selector, for: event)
        return self
    }
    
    @discardableResult
    func loafer_font(_ s: CGFloat) -> Self {
        font = .setFont(s)
        return self
    }
    
    @discardableResult
    func loafer_font(_ s: CGFloat, _ t: UIFont.FontType) -> Self {
        font = .setFont(s, t)
        return self
    }
    
    @discardableResult
    func loafer_placeholderColor(_ c: String) -> Self {
        guard let p = placeholder else { return self }
        let attributeString = NSMutableAttributedString(string: NSLocalizedString(p, comment: ""))
        attributeString.addAttribute(.foregroundColor, value: c.toColor, range: NSRange(location: 0, length: p.count))
        attributedPlaceholder = attributeString
        return self
    }
    
    @discardableResult
    func loafer_textAligment(_ a: NSTextAlignment) -> Self {
        textAlignment = a
        return self
    }
    
    @discardableResult
    func loafer_placeholderColor(_ c: String, _ alpha: CGFloat) -> Self {
        guard let p = placeholder else { return self }
        let attributeString = NSMutableAttributedString(string: NSLocalizedString(p, comment: ""))
        attributeString.addAttribute(.foregroundColor, value: c.toColor.withAlphaComponent(alpha), range: NSRange(location: 0, length: p.count))
        attributedPlaceholder = attributeString
        return self
    }
    
    @discardableResult
    func loafer_placeholderFont(_ s: CGFloat) -> Self {
        guard let p = placeholder else { return self }
        let attributeString = NSMutableAttributedString(string: p)
        attributeString.addAttribute(.font, value: UIFont.setFont(s), range: NSRange(location: 0, length: p.count))
        attributedPlaceholder = attributeString
        return self
    }
    
    @discardableResult
    func loafer_placeholderFont(_ s: CGFloat, _ t: UIFont.FontType) -> Self {
        guard let p = placeholder else { return self }
        let attributeString = NSMutableAttributedString(string: p)
        attributeString.addAttribute(.font, value: UIFont.setFont(s, t), range: NSRange(location: 0, length: p.count))
        attributedPlaceholder = attributeString
        return self
    }
}

// MARK: - UILabel

public extension UILabel {
    @discardableResult
    func loafer_text(_ t: String) -> Self {
        text = NSLocalizedString(t, comment: "")
        return self
    }
    
    @discardableResult
    func loafer_textKey(_ t: String) -> Self {
        text = NSLocalizedString(t, comment: "")
        return self
    }
    
    @discardableResult
    func loafer_attributeString(_ s: String, _ f: [NSAttributedString.Key: Any], _ r: NSRange) -> Self {
        let attributeString = NSMutableAttributedString(string: NSLocalizedString(s, comment: ""))
        attributeString.addAttributes(f, range: r)
        attributedText = attributeString
        return self
    }
    
    @discardableResult
    func loafer_textColor(_ c: String) -> Self {
        textColor = c.toColor
        return self
    }
    
    @discardableResult
    func loafer_textColor(_ c: String, _ alpha: CGFloat) -> Self {
        textColor = c.toColor.withAlphaComponent(alpha)
        return self
    }
    
    @discardableResult
    func loafer_textAligment(_ a: NSTextAlignment) -> Self {
        textAlignment = a
        return self
    }
    
    @discardableResult
    func loafer_font(_ s: CGFloat) -> Self {
        font = .setFont(s)
        return self
    }
    
    @discardableResult
    func loafer_font(_ s: CGFloat, _ t: UIFont.FontType) -> Self {
        font = .setFont(s, t)
        return self
    }
    
    @discardableResult
    func loafer_numberOfLines(_ n: Int) -> Self {
        numberOfLines = n
        return self
    }
    
    @discardableResult
    func loafer_lineBreakMode(_ n: NSLineBreakMode) -> Self {
        lineBreakMode = n
        return self
    }
    
}
// MARK: - UIButton

extension UIButton {
    @discardableResult
    func loafer_text(_ t: String) -> Self {
        setTitle(t, for: .normal)
        return self
    }
    
    @discardableResult
    func loafer_numberOfLines(_ t: Int) -> Self {
        titleLabel?.numberOfLines = t
        titleLabel?.textAlignment = .center
        return self
    }
    
    @discardableResult
    func loafer_attributeString(_ s: String, _ f: [NSAttributedString.Key: Any], _ r: NSRange) -> Self {
        let attributeString = NSMutableAttributedString(string: s)
        attributeString.addAttributes(f, range: r)
        setAttributedTitle(attributeString, for: .normal)
        return self
    }
    
    @discardableResult
    func loafer_text(_ t: String, _ s: UIControl.State) -> Self {
        setTitle(NSLocalizedString(t, comment: ""), for: s)
        return self
    }
    
    @discardableResult
    func loafer_titleColor(_ c: String) -> Self {
        setTitleColor(c.toColor, for: .normal)
        return self
    }
    
    @discardableResult
    func loafer_titleColor(_ c: String, _ alpha: CGFloat) -> Self {
        setTitleColor(c.toColor.withAlphaComponent(alpha), for: .normal)
        return self
    }
    
    @discardableResult
    func loafer_titleColor(_ c: String, _ s: UIControl.State) -> Self {
        setTitleColor(c.toColor, for: s)
        return self
    }
    
    @discardableResult
    func loafer_titleColor(_ c: String, _ alpha: CGFloat, _ s: UIControl.State) -> Self {
        setTitleColor(c.toColor.withAlphaComponent(alpha), for: s)
        return self
    }
    
    @discardableResult
    func loafer_textKey(_ t: String) -> Self {
        setTitle(NSLocalizedString(t, comment: ""), for: .normal)
        return self
    }
    
    @discardableResult
    func loafer_image(_ s: String) -> Self {
        setImage(s.toImage, for: .normal)
        return self
    }
    
    @discardableResult
    func loafer_image(_ s: String, _ state: UIControl.State) -> Self {
        setImage(s.toImage, for: state)
        return self
    }
    
    @discardableResult
    func loafer_backImage(_ s: String) -> Self {
        setBackgroundImage(s.toImage, for: .normal)
        return self
    }
    
    @discardableResult
    func loafer_backImage(_ s: String, _ state: UIControl.State) -> Self {
        setBackgroundImage(s.toImage, for: state)
        return self
    }
    
    @discardableResult
    func loafer_contentHAlignment(_ h: UIControl.ContentHorizontalAlignment) -> Self {
        contentHorizontalAlignment = h
        return self
    }
    
    @discardableResult
    func loafer_contentVAlignment(_ v: UIControl.ContentVerticalAlignment) -> Self {
        contentVerticalAlignment = v
        return self
    }
    
    @discardableResult
    func loafer_font(_ s: CGFloat) -> Self {
        titleLabel?.font = .setFont(s)
        return self
    }
    
    @discardableResult
    func loafer_font(_ s: CGFloat, _ t: UIFont.FontType) -> Self {
        titleLabel?.font = .setFont(s, t)
        return self
    }
    
    @discardableResult
    func loafer_contentEdge(_ t: CGFloat, _ l: CGFloat, _ b: CGFloat, _ r: CGFloat, _ font: UIFont, _ text: String, _ textColor: String) -> Self {
        var configuration = Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: t, leading: l, bottom: b, trailing: r)
        configuration.attributedTitle = AttributedString(text, attributes: AttributeContainer([
        NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: textColor.toColor]))
        self.configuration = configuration
        return self
    }
    
    @discardableResult
    func loafer_contentEdge(_ t: CGFloat, _ l: CGFloat, _ b: CGFloat, _ r: CGFloat) -> Self {
        var configuration = Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: t, leading: l, bottom: b, trailing: r)
        self.configuration = configuration
        return self
    }
    
    @discardableResult
    func loafer_imagePadding(_ padding: CGFloat, _ font: UIFont, _ text: String, _ textColor: String) -> Self {
        configuration = Configuration.plain()
        configurationUpdateHandler = { btn in
            btn.configuration?.imagePadding = padding
            btn.configuration?.attributedTitle = AttributedString(text, attributes: AttributeContainer([
            NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: textColor.toColor]))
        }
        return self
    }
    
    @discardableResult
    func loafer_isSelect(_ s: Bool) -> Self {
        isSelected = s
        return self
    }
    
    @discardableResult
    func loafer_target(_ target: Any?, selector: Selector, event: UIControl.Event = .touchUpInside) -> Self {
        addTarget(target, action: selector, for: event)
        return self
    }
    
    override open var isHighlighted: Bool {
        set {}
        get {
            return false
        }
    }
    
    func loadImage(url: String, placeholder: String = "Loafer_Basic_Empty", blur: CGFloat = 0.0, radius: CGFloat = 0.0, size: CGSize = UIScreen.main.bounds.size) {
        loafer_contentMode(.scaleAspectFill)
        
        let activityView = UIActivityIndicatorView(style: .medium)
        activityView.color = "FFFFFF".toColor
        activityView.hidesWhenStopped = true
        activityView.tag = 10089
        subviews { activityView }
        activityView.centerInContainer()
        activityView.startAnimating()
        
        let placeholderImage = placeholder
        
        var options = ImageLoadingOptions(placeholder: placeholderImage.toImage, transition: .fadeIn(duration: 0.5))
        options.pipeline = ImagePipeline.shared
        var processors: [ImageProcessing] = []
        if radius > 0 {
            processors.append(ImageProcessors.Resize(size: size, crop: true))
            processors.append(ImageProcessors.RoundedCorners(radius: radius))
        }else {
            processors.append(ImageProcessors.Resize(size: size))
        }
        let request = ImageRequest(
            url: URL(string: url),
            processors: processors
        )
        
        Nuke.loadImage(with: request, options: options, into: self.imageView ?? UIImageView()) {[unowned self] result in
            activityView.stopAnimating()
            self.subviews.forEach {
                if $0.tag == 10089 {
                    $0.removeFromSuperview()
                }
            }
            switch result {
            case .success(let res):
                self.setImage(blur > 0 ? res.image.blurred(withRadius: blur) : res.image, for: .normal)
            case .failure(let error):
                debugPrint(error.localizedDescription)
                self.setImage(placeholderImage.toImage, for: .normal)
            }
        }
    }
}

public extension UIImageView {
    @discardableResult
    func loafer_image(_ t: String) -> Self {
        image = t.toImage
        return self
    }
    
    func loadImage(url: String, placeholder: String = "Loafer_Basic_Empty", blur: CGFloat = 0.0, radius: CGFloat = 0.0, size: CGSize = UIScreen.main.bounds.size) {
        loafer_contentMode(.scaleAspectFill)
        
        let activityView = UIActivityIndicatorView(style: .medium)
        activityView.color = "FAFAFA".toColor
        activityView.hidesWhenStopped = true
        activityView.tag = 10089
        subviews { activityView }
        activityView.centerInContainer()
        activityView.startAnimating()
        
        var options = ImageLoadingOptions(placeholder: placeholder.toImage, transition: .fadeIn(duration: 0.5))
        options.pipeline = ImagePipeline.shared
        var processors: [ImageProcessing] = []
        if radius > 0 {
            processors.append(ImageProcessors.Resize(size: size, crop: true))
            processors.append(ImageProcessors.RoundedCorners(radius: radius))
        }else {
            processors.append(ImageProcessors.Resize(size: size))
        }
        let request = ImageRequest(
            url: URL(string: url),
            processors: processors
        )
        
        Nuke.loadImage(with: request, options: options, into: self) {[unowned self] result in
            activityView.stopAnimating()
            self.subviews.forEach {
                if $0.tag == 10089 {
                    $0.removeFromSuperview()
                }
            }
            switch result {
            case .success(let res):
                self.image = blur > 0 ? res.image.blurred(withRadius: blur) : res.image
            case .failure(let error):
                debugPrint(error.localizedDescription)
                self.image = placeholder.toImage
            }
        }
    }
}
