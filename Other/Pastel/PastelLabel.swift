//
//  PastelLabel.swift
//  Pastel
//
//  Created by Cruz on 21/05/2017.
//
//

import UIKit

protocol PastelLabelable {
    var text: String? { get set }
    var font: UIFont? { get set }
    var textAlignment: NSTextAlignment { get set }
    var attributedText: NSAttributedString? { get set }
}

class PastelLabel: PastelView, PastelLabelable {
    private let label = UILabel()
    
    //MARK: - PastelLabelable

    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    var font: UIFont? {
        didSet {
            label.font = font
        }
    }
    
    var attributedText: NSAttributedString? {
        didSet {
            label.attributedText = attributedText
        }
    }
    
    var textAlignment: NSTextAlignment = .center {
        didSet {
            label.textAlignment = textAlignment
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        textAlignment = .center
        mask = label
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
}
