//
//  CommonSiteSelectionIndexInputView.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/4/27.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteSelectionIndexInputView: CommonButton {
    
    //MARK: -propety
    
    var title: String? {
        get {
            return mInputLabel.text
        }
        
        set {
            mInputLabel.text = newValue
        }
    }
    
    ///输入框是否能输入
    var canInput: Bool {
        get {
            return mInputField.isUserInteractionEnabled
        }
        
        set {
            mInputField.isUserInteractionEnabled = newValue
            setNeedsLayout()
        }
    }
    
    //MARK: -subviews
    
    lazy var mContentView = UIView.init()
    
    lazy var mInputLabel: UILabel = {
        let view = UILabel.init()
        view.font = .systemFont(ofSize: 14)
        view.textColor = BaseUIConfig.black
        return view
    }()
    
    lazy var mInputField: UITextField = {
        let view = UITextField.init()
        view.clearButtonMode = .whileEditing
        view.textColor = BaseUIConfig.black
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    lazy var mAccessImageView: UIImageView = {
        let view = UIImageView.init(image: UIImage.init(named: "chargev3_manner_arrow_right"))
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var mDivisionView: UIView = {
        let view = UIView.init()
        view.backgroundColor = BaseUIConfig.gray
        return view
    }()
    
    
    init(frame: CGRect, title: String?, canInput: Bool = true, placeholder: String? = nil) {
        super.init(frame: frame)
        self.title = title
        self.canInput = canInput
        mInputField.placeholder = placeholder
        addSubview(mContentView)
        addSubview(mDivisionView)
        
        mContentView.addSubview(mInputLabel)
        mContentView.addSubview(mInputField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if canInput {
            mAccessImageView.removeFromSuperview()
            mContentView.isUserInteractionEnabled = true
        }else{
            mContentView.addSubview(mAccessImageView)
            mContentView.isUserInteractionEnabled = false
        }
        
        mContentView.frame = bounds
        
        mDivisionView.frame = CGRect.init(x: 15, y: height - 1, width: width - 15, height: 1)
        
        mContentView.configureLayout { (layout) in
            layout.isEnabled = true
            layout.flexDirection = .row
            layout.paddingLeft = YGValue(15)
            layout.paddingRight = YGValue(15)
        }
        
        mInputLabel.configureLayout { (layout) in
            layout.isEnabled = true
            layout.width = YGValue(80)
        }
        
        mInputField.configureLayout { (layout) in
            layout.isEnabled = true
            layout.flex = 1
        }
        
        mAccessImageView.configureLayout { (layout) in
            layout.isEnabled = true
            layout.width = YGValue(15)
            layout.height = YGValue(15)
            layout.alignSelf = .center
            layout.marginLeft = YGValue(5)
        }
        
        mContentView.yoga.applyLayout(preservingOrigin: false)
    }
    
}
