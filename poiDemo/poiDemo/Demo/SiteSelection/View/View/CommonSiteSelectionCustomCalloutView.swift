//
//  CommonSiteSelectionCustomCalloutView.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/9/23.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteSelectionCustomCalloutView: MACustomCalloutView {
    
    var calloutTitle: String? {
        didSet {
            (customView as? CommonSiteSelectionCustomCalloutContentView)?.calloutTitle = calloutTitle
        }
    }
    
    override init(frame: CGRect) {
        super.init(customView: CommonSiteSelectionCustomCalloutContentView.init())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CommonSiteSelectionCustomCalloutContentView: UIView {
    
    var calloutTitle: String? {
        didSet {
            mTitleLabel.text = calloutTitle
            let maxw = UIScreen.main.bounds.width - 20 - 20
            let titleSize = mTitleLabel.sizeThatFits(CGSize.init(width: maxw, height: 30))
            let w = min(maxw + 20, max(titleSize.width + 20, 50))
            self.frame = CGRect.init(x: -w/2, y: -50, width: w, height: 50)
        }
    }
    
    lazy var mContainerView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(red: 77/255.0, green: 83/255.0, blue: 99/255.0, alpha: 1)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var triangleView: UIView = {
        let triangleView = UIView(frame: .zero)
        triangleView.backgroundColor = UIColor.init(red: 77/255.0, green: 83/255.0, blue: 99/255.0, alpha: 1)
        return triangleView
    }()
    
    lazy var mTitleLabel: UILabel = {
        let view = UILabel.init()
        view.font = .systemFont(ofSize: 14)
        view.textAlignment = .center
        view.textColor = .white
        return view
    }()
    
    var clipTriangleLayer: CAShapeLayer = {
        let layer = CAShapeLayer.init()
        return layer
    }()
    
    var pathTriangleLayer: CAShapeLayer = {
        let layer = CAShapeLayer.init()
        layer.lineWidth = 1
        layer.lineJoin = .round
        layer.lineCap = .round
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mContainerView)
        addSubview(triangleView)
        mContainerView.addSubview(mTitleLabel)
        triangleView.layer.addSublayer(pathTriangleLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let triangleSize = CGSize.init(width: 12, height: 7)
        mContainerView.frame = CGRect.init(x: 0, y: 0, width: width, height: height - 6 - 2)
        triangleView.frame = CGRect.init(x: (width - triangleSize.width)/2, y: mContainerView.bottom-1, width: triangleSize.width, height: triangleSize.height)
        mTitleLabel.frame = CGRect.init(x: 10, y: 0, width: mContainerView.width - 20, height: mContainerView.height)
        
        clipTriangleLayer.frame = CGRect.init(x: 0, y: 0, width: triangleSize.width, height: triangleSize.height)
        pathTriangleLayer.frame = clipTriangleLayer.bounds
        let path = UIBezierPath.init()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: triangleSize.width, y: 0))
        path.addLine(to: CGPoint(x: triangleSize.width/2, y: triangleSize.height))
        path.close()
        clipTriangleLayer.path = path.cgPath
        pathTriangleLayer.path = path.cgPath
        triangleView.layer.mask = clipTriangleLayer
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: 200, height: 100)
    }
}
