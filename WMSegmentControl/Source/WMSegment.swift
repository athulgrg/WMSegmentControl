//
//  WMSegment.swift
//  WMSegmentControl
//
//  Created by Wasim Malek on 27/05/19.
//  Copyright © 2019 Wasim Malek. All rights reserved.
//

import UIKit

open class WMSegment: UIControl {
    public var onValueChanged: ((_ index: Int)->())?
    private var buttons = [UIButton]()
    private var selectors = [UIView]()
    private var selectedSegmentIndex: Int = 0

    public var buttonTitles: [String] = [String]() {
        didSet {
            updateView()
        }
    }
    public var textColor: UIColor = .darkGray {
        didSet {
            updateView()
        }
    }
    public var selectorTextColor: UIColor = .black {
        didSet {
            updateView()
        }
    }
    public var selectorColor: UIColor = .orange {
        didSet {
            updateView()
        }
    }
    public var bracketTextColor: UIColor = .lightGray {
        didSet {
            updateView()
        }
    }
    public var bottomBarHeight : CGFloat = 5.0 {
        didSet {
            updateView()
        }
    }
    public var bottomBarOffsetRatio : CGFloat = 0.0 {
        didSet {
            updateView()
        }
    }
    public var normalFont : UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            updateView()
        }
    }
    public var selectedFont : UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            updateView()
        }
    }
    public var minimunScaleFactor : CGFloat = 1.0 {
        didSet {
            updateView()
        }
    }
    public var segmentDistributionType : UIStackView.Distribution = .fillEqually {
        didSet {
            updateView()
        }
    }

    private var isFrameAreSet = false
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        updateView()
    }
    
    open func updateView() {
        self.clipsToBounds = true
        buttons.removeAll()
        selectors.removeAll()
        subviews.forEach({$0.removeFromSuperview()})
        NotificationCenter.default.removeObserver("DeviceRotated")
        NotificationCenter.default.addObserver(self, selector: #selector(setViewLayout), name: NSNotification.Name(rawValue: "DeviceRotated"), object: nil)
        buttons = getButtonsForNormalSegment()

        let sv = UIStackView(arrangedSubviews: buttons)
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = segmentDistributionType
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        sv.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        sv.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        sv.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        setupSelectors()
    }
    
    func setupSelectors() {
        _ = buttons.map({ btn in

            var width = width(string: (btn.attributedTitle(for: .normal))?.string ?? "")
            width = width + (width * bottomBarOffsetRatio)

            let selector = UIView()
            btn.addSubview(selector)
            btn.clipsToBounds = true

            selector.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(item: selector, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: btn, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: selector, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: btn, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: selector, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: width)
            let heightConstraint = NSLayoutConstraint(item: selector, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: bottomBarHeight)
            addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])

            selectors.append(selector)
            selector.backgroundColor = selectorColor
        })
    }
    
    //MARK : Get Button as per segment type
    func getButtonsForNormalSegment() -> [UIButton] {
        var btn = [UIButton]()
        let titles = buttonTitles
        for (index, buttonTitle) in titles.enumerated() {
            let button = UIButton(type: .system)
            let title = getAttributedTitle(string: buttonTitle, isSelected: false)
            button.setAttributedTitle(title, for: .normal)
            button.titleLabel?.minimumScaleFactor = minimunScaleFactor
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.tag = index
            button.titleLabel?.textAlignment = .center
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            btn.append(button)
        }
        return btn
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if isFrameAreSet == false {
            setViewLayout()
        }
    }
    
    @objc open func setViewLayout() {
        layoutIfNeeded()
        updateView()
        setSelectedIndex(self.selectedSegmentIndex)
        isFrameAreSet = true
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        setSelectedIndex(sender.tag)
        onValueChanged?(selectedSegmentIndex)
        sendActions(for: .valueChanged)
    }

    //MARK: set Selected Index
    open func setSelectedIndex(_ index: Int) {
        selectedSegmentIndex = index

        for (buttonIndex, btn) in buttons.enumerated() {
            if btn.tag == index {
                let title = getAttributedTitle(string: buttonTitles[buttonIndex], isSelected: true)
                UIView.performWithoutAnimation {
                    btn.setAttributedTitle(title, for: .normal)
                    btn.layoutIfNeeded()
                }
                selectors[buttonIndex].backgroundColor = selectorColor
            } else {
                let title = getAttributedTitle(string: buttonTitles[buttonIndex], isSelected: false)
                UIView.performWithoutAnimation {
                    btn.setAttributedTitle(title, for: .normal)
                    btn.layoutIfNeeded()
                }
                selectors[buttonIndex].backgroundColor = UIColor.clear
            }
        }
    }

    private func getAttributedTitle(string: String, isSelected: Bool) -> NSAttributedString? {
        var font = normalFont
        var color = textColor

        if isSelected {
            font = selectedFont
            color = selectorTextColor
        }

        guard let regex = try? NSRegularExpression(pattern: "\\((.*?)\\)") else {
            return nil
        }
        let matches = regex.matches(in: string,
                                 range: NSRange(string.startIndex..., in: string))
        guard let first = matches.first, let range = Range(first.range, in: string) else {
            let attr = NSMutableAttributedString(string: string)
            attr.addAttributes([NSAttributedString.Key.font: font,
                                NSAttributedString.Key.foregroundColor: color],
                               range: NSRange(attr.string.startIndex..., in: attr.string))
            return attr
        }
        let result = String(string[range])

        let attr = NSMutableAttributedString(string: string.replacingCharacters(in: range, with: ""))
        attr.addAttributes([NSAttributedString.Key.font: font,
                            NSAttributedString.Key.foregroundColor: color],
                           range: NSRange(attr.string.startIndex..., in: attr.string))

        let attr1 = NSMutableAttributedString(string:result)
        attr1.addAttributes([NSAttributedString.Key.font: font,
                            NSAttributedString.Key.foregroundColor: bracketTextColor],
                           range: NSRange(result.startIndex..., in: result))
        attr.append(attr1)
        return attr

    }

    func width(string: String) -> CGFloat {
        let rect = string.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: frame.height),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.width)
    }
}
