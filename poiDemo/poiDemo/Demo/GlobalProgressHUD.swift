//
//  GlobalProgressHUD.swift
//  newenergy-ios
//
//  Created by cgf on 2020/1/14.
//  Copyright © 2020 cgf. All rights reserved.
//

import Foundation
import MBProgressHUD

class GlobalProgressHUD {
    
    static let HUDduration: Double = 1.5
    
    static let shareInstance = GlobalProgressHUD()
    
    private var progressHUD: MBProgressHUD?
    
    private func getProgressHUD() -> MBProgressHUD? {
        if let window = UIApplication.shared.keyWindow {
            UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self]).color = .white
            progressHUD = MBProgressHUD.forView(window)
            if !(progressHUD != nil) {
                progressHUD = MBProgressHUD.showAdded(to: window, animated: true)
                progressHUD?.margin = 25
                progressHUD?.bezelView.style = .solidColor
                progressHUD?.bezelView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
                progressHUD?.label.textColor = .white
                progressHUD?.animationType = .fade
                progressHUD?.detailsLabel.textColor = .white
                progressHUD?.isUserInteractionEnabled = false
                progressHUD?.detailsLabel.font = progressHUD?.label.font
            }
            return progressHUD!
        }
        return nil
    }
    
    func showHUDAtWindow(title: String) {
        self.getProgressHUD()?.label.text = NSLocalizedString(title, comment: "")
    }
    
    func showHUDAtWindow(title: String, detail: String) {
        self.getProgressHUD()?.label.text = NSLocalizedString(title, comment: "")
        self.getProgressHUD()?.detailsLabel.text = NSLocalizedString(detail, comment: "")
    }
    
    func hideHUDAtWindow() {
        self.getProgressHUD()?.hide(animated: true)
    }
    
    func hudStyle1() {
        getProgressHUD()?.label.textColor = .white
        getProgressHUD()?.detailsLabel.textColor = .white
        getProgressHUD()?.contentColor = .white
        getProgressHUD()?.backgroundColor = .clear
        getProgressHUD()?.tintColor = .white
        getProgressHUD()?.margin = 20
    }
    
    static func showHUDIndicator(title: String, detail: String="", isUserInteractionEnabled: Bool = true){
        let hud = shareInstance.getProgressHUD()
        shareInstance.hudStyle1()
        hud?.mode = .indeterminate
        hud?.label.text = NSLocalizedString(title, comment: "")
        hud?.detailsLabel.text = NSLocalizedString(detail, comment: "")
        hud?.isUserInteractionEnabled = isUserInteractionEnabled
        hud?.show(animated: true)
    }
    
    static func showHUDText(title: String, detail: String="", duration: TimeInterval = HUDduration){
        let hud = shareInstance.getProgressHUD()
        shareInstance.hudStyle1()
        hud?.mode = .text
        if title != "" && detail == "" {
            hud?.label.text = ""
            hud?.detailsLabel.text = NSLocalizedString(title, comment: "")
        }else{
            hud?.label.text = NSLocalizedString(title, comment: "")
            hud?.detailsLabel.text = NSLocalizedString(detail, comment: "")
        }
        hud?.detailsLabel.font = hud?.label.font
        hud?.isUserInteractionEnabled = false
        hud?.show(animated: true)
        hud?.hide(animated: true, afterDelay: duration)
    }
    
    static func showHUDSuccess(title: String, detail: String="", duration: TimeInterval = HUDduration){
        let hud = shareInstance.getProgressHUD()
        shareInstance.hudStyle1()
        hud?.mode = .customView
        let successImageView = UIImageView.init(image: UIImage.init(named: "Add-Success"))
        hud?.customView = successImageView
        hud?.label.text = NSLocalizedString(title, comment: "")
        hud?.detailsLabel.text = NSLocalizedString(detail, comment: "")
        hud?.isUserInteractionEnabled = false
        hud?.show(animated: true)
        hud?.hide(animated: true, afterDelay: duration)
    }
    
    static func showHUDFail(title: String, detail: String="", duration: TimeInterval = HUDduration){
        let hud = shareInstance.getProgressHUD()
        shareInstance.hudStyle1()
        hud?.mode = .customView
        let failImageView = UIImageView.init(image: UIImage.init(named: "Add-fail"))
        hud?.customView = failImageView
        hud?.label.text = NSLocalizedString(title, comment: "")
        hud?.detailsLabel.text = NSLocalizedString(detail, comment: "")
        hud?.isUserInteractionEnabled = false
        hud?.show(animated: true)
        hud?.hide(animated: true, afterDelay: duration)
    }
    
    static func showHUDProgress(progress: Float, title: String, detail: String="", duration: TimeInterval = HUDduration){
        let hud = shareInstance.getProgressHUD()
        shareInstance.hudStyle1()
        hud?.mode = .annularDeterminate
        hud?.progress = progress
        hud?.label.text = NSLocalizedString(title, comment: "")
        hud?.detailsLabel.text = NSLocalizedString(detail, comment: "")
        hud?.isUserInteractionEnabled = false
        hud?.show(animated: true)
//        hud?.hide(animated: true, afterDelay: duration)
    }
    
    /// hud 自定义view
    static func showCustomView(view: UIView, isUserInteractionEnabled: Bool = true) {
        let hud = shareInstance.getProgressHUD()
        hud?.mode = .customView
        hud?.customView = view
        hud?.margin = 0
        hud?.backgroundColor = .black.withAlphaComponent(0.5)
        hud?.isUserInteractionEnabled = isUserInteractionEnabled
        hud?.show(animated: true)
    }
        
    static func hidden(animated: Bool = true){
        let hud = shareInstance.getProgressHUD()
        
        hud?.hide(animated: animated)
    }
    
    static func hidden(duration: TimeInterval = HUDduration, animated: Bool = true){
        let hud = shareInstance.getProgressHUD()
        hud?.hide(animated: animated, afterDelay: duration)
    }
}


class BaseNavigationBarView: UIView {

    //MARK: -propety
    
    let disposeBag = DisposeBag()
    
    var alwaysBackButton = false

    //MARK: -subview
    
    lazy var mContentView = UIView()
    
    lazy var mBackButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.init(named: "back"), for: .normal)
        return view
    }()
    
    lazy var mTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "导航栏"
        view.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        view.textColor = .black
        view.textAlignment = .center
        return view
    }()
    
    lazy var mLineView: UIView = {
        let view = UIView()
        return view
    }()
    
    //MARK: -life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        initAction()
    }
    
    convenience init(naviTitle: String?){
        self.init(frame: CGRect.zero)
        self.setNaviTitle(title: naviTitle ?? "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutView()
    }
    
    
    //MARK: -private func
    private func initView(){
        backgroundColor = .white
        addSubview(mContentView)
        mContentView.addSubview(mBackButton)
        mContentView.addSubview(mTitleLabel)
        mContentView.addSubview(mLineView)
    }
    
    private func layoutView(){
        if alwaysBackButton {
            mBackButton.isHidden = false
        }else{
            if (viewController?.navigationController?.children.count) == nil || (viewController?.navigationController?.children.count)! <= 1 {
                mBackButton.isHidden = true
            }else {
                mBackButton.isHidden = false
            }
        }
        mContentView.frame = CGRect.init(x: 0, y: height - 45, width: width, height: 45)
        mBackButton.frame = CGRect.init(x: 0, y: 0, width: 45, height: 45)
        mTitleLabel.frame = CGRect.init(x: mBackButton.right, y: 0, width: mContentView.width - mBackButton.right * 2, height: mContentView.height)
        mLineView.frame = CGRect.init(x: 0, y: mContentView.height - 1, width: width, height: 1)
    }
    
    private func initAction(){
        mBackButton.rx.tap.subscribe(onNext: { [weak self](_) in
            if self?.viewController?.navigationController?.viewControllers.count ?? 0 <= 1{
                self?.viewController?.dismiss(animated: true, completion: nil)
            }else{
                self?.viewController?.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: disposeBag)
    }
    
    //MARK: -public func
    
    public func setNaviTitle(title: String){
        mTitleLabel.text = NSLocalizedString(title, comment: "")
    }
}

class CommonButton: UIButton {
    
    //MARK: -propety
    
        
    private let fadeKey = "fadeKey"
    
    ///是否开启高亮功能
    var canHighlighted = true
    
    open override var isHighlighted: Bool {
        didSet {
            if canHighlighted {
                isHighlighted ? fade(0.5) : fade(1.0)
            }
        }
    }
    

    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: -private func
    private func fade(_ value: Float, duration: CFTimeInterval = 0.08) {
        layer.removeAnimation(forKey: fadeKey)
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = duration
        animation.fromValue = layer.presentation()?.opacity
        layer.opacity = value
        animation.fillMode = CAMediaTimingFillMode.forwards
        layer.add(animation, forKey: fadeKey)
    }
    
}


extension CommonButton {
    static func initDefaultButton(title: String?) -> CommonButton {
        let view = CommonButton.init()
        view.setTitle(title, for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.backgroundColor = UIColor.init(red: 241/255.0, green: 208/255.0, blue: 88/255.0, alpha: 1)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }
}

class BaseUIConfig {
    ///背景灰
    static let gray_bg = UIColor.init(red: 245/255.0, green: 246/255.0, blue: 247/255.0, alpha: 1)
    
    ///灰
    static let gray = UIColor.init(red: 231/255.0, green: 235/255.0, blue: 239/255.0, alpha: 1)
    
    ///黑
    static let black = UIColor.init(red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1)
    
    ///黑 轻
    static let black_light = UIColor.init(red: 145/255.0, green: 147/255.0, blue: 153/255.0, alpha: 1)
}


