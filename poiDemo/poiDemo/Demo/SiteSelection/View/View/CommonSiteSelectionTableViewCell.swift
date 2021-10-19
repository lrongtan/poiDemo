//
//  CommonSiteSelectionTableViewCell.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/4/27.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteSelectionTableViewCell: UITableViewCell {
    
    //MARK: -subviews
    
    lazy var mContentView = UIView()
    
    lazy var mIconImage = UIImageView.init()
    
//    lazy var mIconImage: UIButton = {
//        let view = UIButton.init()
//        view.setImage(UIImage.init(named: "common_site_selection_poi"), for: .normal)
//        view.setImage(UIImage.init(named: "common_site_selection_location"), for: .selected)
//        view.isUserInteractionEnabled = false
//        return view
//    }()
    
    lazy var mrView = UIView()
    
    lazy var mLabel1: UILabel = {
        let view = UILabel.init()
        view.font = .systemFont(ofSize: 14)
        view.textColor = BaseUIConfig.black
        return view
    }()
    
    lazy var mLabel2: UILabel = {
        let view = UILabel.init()
        view.font = .systemFont(ofSize: 12)
        view.textColor = BaseUIConfig.black_light
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mContentView)
        mIconImage.image = UIImage.init(named: "common_site_selection_poi")
        mIconImage.contentMode = .scaleAspectFit
        mContentView.addSubview(mIconImage)
        mContentView.addSubview(mrView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mContentView.frame = contentView.bounds
        
        mContentView.configureLayout { (layout) in
            layout.isEnabled = true
            layout.flexDirection = .row
            layout.paddingLeft = YGValue(15)
            layout.paddingRight = YGValue(15)
        }
        
        mIconImage.configureLayout { (layout) in
            layout.isEnabled = true
            layout.width = YGValue(12)
            layout.height = YGValue(22)
            layout.alignSelf = .center
        }
        
        mrView.configureLayout { (layout) in
            layout.isEnabled = true
            layout.justifyContent = .center
            layout.marginLeft = YGValue(15)
            layout.flex = 1
        }
        
        mLabel1.configureLayout { (layout) in
            layout.isEnabled = true
            layout.height = YGValue(20)
        }
        
        mLabel2.configureLayout { (layout) in
            layout.isEnabled = true
            layout.height = YGValue(18)
        }
        
        mContentView.yoga.applyLayout(preservingOrigin: false)
    }
    
    
    func setCellModel(value: CommonSiteSelectionCellModel){
        mLabel1.text = value.name
        
        mLabel2.text = value.address
        
        mrView.removeAllSubviews()
        
        if mLabel1.text != nil && mLabel1.text != "" {
            mrView.addSubview(mLabel1)
        }
        
        if mLabel2.text != nil && mLabel2.text != "" {
            mrView.addSubview(mLabel2)
        }
        setNeedsLayout()
    }
    
}
