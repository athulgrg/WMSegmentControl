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
    var buttons = [UIButton]()
    var selector: UIView!
    public var selectedSegmentIndex: Int = 0

    public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    public var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
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
    public var isRounded: Bool = false {
        didSet {
            if self.isRounded == true {
                layer.cornerRadius = frame.height/2
            }
            updateView()
        }
    }
    public var bottomBarHeight : CGFloat = 5.0 {
        didSet {
            updateView()
        }
    }
    public var bottomBarPadding : CGFloat = 0.0 {
        didSet {
            updateView()
        }
    }
    public var normalFont : UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            updateView()
        }
    }
    public var SelectedFont : UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            updateView()
        }
    }
    
    public var animate: Bool = true
    
    private var isFrameAreSet = false
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        updateView()
    }
    
    open func updateView() {
        self.clipsToBounds = true
        buttons.removeAll()
        subviews.forEach({$0.removeFromSuperview()})
        NotificationCenter.default.removeObserver("DeviceRotated")
        NotificationCenter.default.addObserver(self, selector: #selector(setViewLayout), name: NSNotification.Name(rawValue: "DeviceRotated"), object: nil)
        buttons = getButtonsForNormalSegment()

        setupSelector()
        addSubview(selector)
        let sv = UIStackView(arrangedSubviews: buttons)
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillEqually//.fillProportionally
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        sv.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        sv.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        sv.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    func setupSelector() {
        let titles = buttonTitles
        let selectorWidth = frame.width / CGFloat(titles.count)
        selector = UIView(frame: CGRect(x: 0 + bottomBarPadding, y: frame.height - bottomBarHeight, width: selectorWidth - (bottomBarPadding * 2), height: bottomBarHeight))
            selector.layer.cornerRadius = 0
        selector.backgroundColor = selectorColor
    }
    
    //MARK : Get Button as per segment type
    func getButtonsForNormalSegment() -> [UIButton] {
        var btn = [UIButton]()
        let titles = buttonTitles
        for (index, buttonTitle) in titles.enumerated() {
            let button = UIButton(type: .system)
            let title = getAttributedTitle(string: buttonTitle, isSelected: false)
            button.setAttributedTitle(title, for: .normal)
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
        let _animated = self.animate
        self.animate = false
        setSelectedIndex(self.selectedSegmentIndex)
        self.animate = _animated
        isFrameAreSet = true
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        setSelectedIndex(sender.tag)
        onValueChanged?(selectedSegmentIndex)
        sendActions(for: .valueChanged)
    }
    //MARK: set Selected Index
    open func setSelectedIndex(_ index: Int) {
        for (buttonIndex, btn) in buttons.enumerated() {
            if btn.tag == index {
                let title = getAttributedTitle(string: buttonTitles[buttonIndex], isSelected: true)
                UIView.performWithoutAnimation {
                    btn.setAttributedTitle(title, for: .normal)
                    btn.layoutIfNeeded()
                }
                selectedSegmentIndex = buttonIndex
                var startPosition = frame.width/CGFloat(buttons.count) * CGFloat(buttonIndex)
                startPosition = startPosition + bottomBarPadding
                if self.animate {
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                        self.selector.frame.origin.x = startPosition
                    }, completion: nil)
                }else{
                    self.selector.frame.origin.x = startPosition
                }
            } else {
                let title = getAttributedTitle(string: buttonTitles[buttonIndex], isSelected: false)
                UIView.performWithoutAnimation {
                    btn.setAttributedTitle(title, for: .normal)
                    btn.layoutIfNeeded()
                }
            }
        }
    }
    
    //MARK: chage Selector Color
    open func changeSelectedColor(_ color: UIColor) {
        self.selector.backgroundColor = color
    }

    private func getAttributedTitle(string: String, isSelected: Bool) -> NSAttributedString? {
        var font = normalFont
        var color = textColor

        if isSelected {
            font = SelectedFont
            color = selectorTextColor
        }

        guard let regex = try? NSRegularExpression(pattern: "\\((.*?)\\)") else {
            return nil
        }
        let matches = regex.matches(in: string,
                                 range: NSRange(string.startIndex..., in: string))
        guard let first = matches.first, let range = Range(first.range, in: string) else {
            return nil
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
}
