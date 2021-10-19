//
//  SiteSelectionIndexViewController.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/4/27.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteSelectionIndexViewController: UIViewController {
    
    typealias CommonSiteSelectionDidFinishBlock = ((_ value: CommonSiteSelectionCellModel) -> Void)
    
    typealias CommonSiteSelectionCancelBlock = (() -> Void)

    //MARK: -propety
    
    private let _baseDisposeBag = DisposeBag()
    
    var siteValue: CommonSiteSelectionCellModel?
    
    var siteSelectionDidFinishBlock: CommonSiteSelectionDidFinishBlock?
    
    var siteSelectionCancelBlock: CommonSiteSelectionCancelBlock?
    /// -返回上一页是否取消
    private var isCancel = true
    
    /// 暗黑UI
    private var isDarkStyle = false
    
    //MARK: -subviews
    
    lazy var mNavigationView = BaseNavigationBarView.init(naviTitle: "")
    
    lazy var mBGScrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    lazy var mContentView = UIView.init()
    
    lazy var mDivisionView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(red: 245/255.0, green: 246/255.0, blue: 247/255.0, alpha: 1)
        return view
    }()
    
    lazy var mSelectionView = CommonSiteSelectionIndexInputView.init(frame: CGRect.zero, title: "选择地址", canInput: false, placeholder: "请选择地址")
    
    lazy var mDetailView = CommonSiteSelectionIndexInputView.init(frame: CGRect.zero, title: "详细地址", canInput: true, placeholder: "例：4号楼1801")

    lazy var mActionButton: CommonButton = {
        let view = CommonButton.initDefaultButton(title: "确定")
        return view
    }()
    
    //MARK: -init
    
    init(navigationTitle: String?, siteValue: CommonSiteSelectionCellModel? = nil, isDarkStyle: Bool = false, block: CommonSiteSelectionDidFinishBlock? = nil, cancelBlock: CommonSiteSelectionCancelBlock? = nil) {
        self.siteSelectionDidFinishBlock = block
        self.siteSelectionCancelBlock = cancelBlock
        self.siteValue = siteValue
        self.isDarkStyle = isDarkStyle
        super.init(nibName: nil, bundle: nil)
        mNavigationView.setNaviTitle(title: navigationTitle ?? "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initAction()
        

    }
    
    deinit {
        if isCancel {
            siteSelectionCancelBlock?()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutView()
    }
    //MARK: -private
    
    private func initView(){
        view.addSubview(mNavigationView)
        view.addSubview(mBGScrollView)
        
        mBGScrollView.addSubview(mContentView)
        
        mContentView.addSubview(mDivisionView)
        mContentView.addSubview(mSelectionView)
        mContentView.addSubview(mDetailView)
        mContentView.addSubview(mActionButton)

    }
        
    private func layoutView(){
        mNavigationView.frame = CGRect.init(x: 0, y: 0, width: view.width, height: view.safeAreaInsets.top + 45)
        mBGScrollView.frame = CGRect.init(x: 0, y: mNavigationView.bottom, width: view.width, height: view.height - mNavigationView.bottom)
        
        mContentView.frame = mBGScrollView.bounds
        
        mContentView.configureLayout { (layout) in
            layout.isEnabled = true
        }
        
        mDivisionView.configureLayout { (layout) in
            layout.isEnabled = true
            layout.height = YGValue(8)
        }
        
        mSelectionView.configureLayout { (layout) in
            layout.isEnabled = true
            layout.height = YGValue(52)
        }
        
        mDetailView.configureLayout { (layout) in
            layout.isEnabled = true
            layout.height = YGValue(52)
        }
        
        mActionButton.configureLayout { (layout) in
            layout.isEnabled = true
            layout.height = YGValue(40)
            layout.marginTop = YGValue(24)
            layout.marginLeft = YGValue(15)
            layout.marginRight = YGValue(15)
        }
        
        mContentView.yoga.applyLayout(preservingOrigin: true)
    }
    
    private func initAction(){
        
//        let interactivePopGestureRecognizer = UIPanGestureRecognizer.init(target: navigationController?.interactivePopGestureRecognizer?.delegate, action: nil)
//        view.addGestureRecognizer(interactivePopGestureRecognizer)
        mSelectionView.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.selectionViewTap()
        }).disposed(by: _baseDisposeBag)
        
        mSelectionView.mInputField.text = siteValue?.name
        mDetailView.mInputField.text = siteValue?.detailAddress
        
        mActionButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.actionButtonTap()
        }).disposed(by: _baseDisposeBag)
        
        mNavigationView.mBackButton.rx.tap.subscribe(onNext: {
            
        }).disposed(by: _baseDisposeBag)
    }
    
    ///选择地址点击
    private func selectionViewTap(){
        let vc = CommonSiteSelectionMapViewController.init(siteValue: siteValue) { [weak self] (siteValue) in
            guard let self = self else { return }
            self.siteValue = siteValue
            self.mSelectionView.mInputField.text = siteValue.name
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func actionButtonTap(){
        guard let _siteValue = siteValue, let detailAddress = mDetailView.mInputField.text, detailAddress.count > 0 else {
            GlobalProgressHUD.showHUDText(title: "请填写地址")
            return
        }
        guard detailAddress.count <= 50 else {
            GlobalProgressHUD.showHUDText(title: "地址长度不能大于50")
            return
        }
        isCancel = false
        dismiss()
        _siteValue.detailAddress = detailAddress
        siteSelectionDidFinishBlock?(_siteValue)
    }
    
    private func dismiss(){
        if navigationController?.viewControllers.count ?? 0 <= 1{
            dismiss(animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
}
