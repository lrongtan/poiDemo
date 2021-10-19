//
//  CommonSiteSelectionMapNavigationView.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/4/27.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteSelectionMapNavigationView: UIView {
    
    typealias CommonSiteSelectionMapNavigationDistrictValueBlock = ((_ district: String) -> Void)

    //MARK: -propety
    
    private let disposeBag = DisposeBag()
    
    ///城市地址变化回调
    private var districtValueBlock: CommonSiteSelectionMapNavigationDistrictValueBlock?
    
    ///城市
    var districtValue: String = ""
    
    //MARK: -subviews
    
    lazy var mContentView = UIView.init()
    
    lazy var mBackButton: CommonButton = {
        let view = CommonButton()
        view.setImage(UIImage.init(named: "back"), for: .normal)
        return view
    }()
    
    lazy var mTitleView: UIView = {
        let view = UIView.init()
        view.backgroundColor = BaseUIConfig.gray_bg
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var mDistrictButton: CommonButton = {
        let view = CommonButton()
        view.setTitleColor(.black, for: .normal)
        view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        view.setImage(UIImage(named: "station_map_arrow_down"), for: .normal)
        return view
    }()
    
    lazy var mDivisionView: UIView = {
        let view = UIView.init()
        view.backgroundColor = BaseUIConfig.gray
        return view
    }()
    
    lazy var mIconImage = UIImageView.init(image: UIImage.init(named: "index_v3_search"))
    
    lazy var mInputField: UITextField = {
        let view = UITextField()
        view.borderStyle = .none
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = BaseUIConfig.black
        view.clearButtonMode = .whileEditing
        view.placeholder = "小区/学校/写字楼等"
        return view
    }()
    
    lazy var mCancelButton: CommonButton = {
        let view = CommonButton.init()
        view.setTitle("取消", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 14)
        view.setTitleColor(BaseUIConfig.black_light, for: .normal)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        initAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutView()
    }
    
    //MARK: -private
    
    private func initView() {
        addSubview(mContentView)
        
        mContentView.addSubview(mBackButton)
        
        mContentView.addSubview(mTitleView)
        
        mContentView.addSubview(mCancelButton)
        
        mTitleView.addSubview(mDistrictButton)
        
        mTitleView.addSubview(mDivisionView)
        
        mTitleView.addSubview(mIconImage)
        
        mTitleView.addSubview(mInputField)
    }
    
    private func layoutView() {
        
        mContentView.frame = CGRect.init(x: 0, y: height - 45, width: width, height: 45)
        
        mBackButton.frame = CGRect.init(x: 0, y: 0, width: 45, height: 45)
        
        if mInputField.isEditing {
            mCancelButton.frame = CGRect.init(x: mContentView.width - 60, y: 0, width: 60, height: mContentView.height)
            mTitleView.frame = CGRect.init(x: mBackButton.right, y: 6, width: mCancelButton.left - mBackButton.right, height: 32)
        }else{
            mCancelButton.frame = CGRect.init(x: mContentView.width, y: 0, width: 60, height: mContentView.height)
            mTitleView.frame = CGRect.init(x: mBackButton.right, y: 6, width: mContentView.width - mBackButton.right - 15, height: 32)
        }
        
        mTitleView.configureLayout { (layout) in
            layout.isEnabled = true
            layout.flexDirection = .row
        }
        
        let mDistrictSize =  mDistrictButton.sizeThatFits(CGSize.init(width: 90, height: 30))
        mDistrictButton.configureLayout { (layout) in
            layout.isEnabled = true
            layout.marginLeft = YGValue(15)
            layout.marginRight = YGValue(15)
            layout.minWidth = YGValue(30)
            layout.maxWidth = YGValue(90)
            layout.width = YGValue(mDistrictSize.width)
        }
        mDivisionView.configureLayout { (layout) in
            layout.isEnabled = true
            layout.height = YGValue(16)
            layout.width = YGValue(1)
            layout.alignSelf = .center
        }
        
        mIconImage.configureLayout { (layout) in
            layout.isEnabled = true
            layout.marginLeft = YGValue(8)
            layout.marginRight = YGValue(8)
            layout.width = YGValue(20)
            layout.height = YGValue(20)
            layout.alignSelf = .center
        }
        
        mInputField.configureLayout { (layout) in
            layout.isEnabled = true
            layout.flex = 1
            layout.marginRight = YGValue(5)
        }
        mTitleView.yoga.applyLayout(preservingOrigin: true)

    }
    
    private func initAction() {

        districtValue = "福州"
        
        mDistrictButton.setTitle(districtValue, for: .normal)
        mInputField.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.setNeedsLayout()
        }).disposed(by: disposeBag)
        
        mInputField.rx.controlEvent(.editingDidBegin).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.setNeedsLayout()
        }).disposed(by: disposeBag)
        
        mInputField.rx.text.orEmpty.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.mInputField.markedTextRange == nil {
                let text = self.mInputField.text ?? ""
                if text.count > 30 {
                    let idx = text.index(text.startIndex, offsetBy: 30)
                    let st = String(text[text.startIndex..<idx])
                    print(st)
                    self.mInputField.text = st
                }
            }
        }).disposed(by: disposeBag)
        
        mDistrictButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.districtButtonTap()
        }).disposed(by: disposeBag)
        mInputField.delegate = self
    }
    
    ///城市按钮点击
    private func districtButtonTap(){
//        let vc = IndexCityViewController.init { [weak self](mapDistrict) in
//            guard let self = self else { return }
//            self.districtValue = mapDistrict.name ?? ""
//            self.mDistrictButton.setTitle(self.districtValue, for: .normal)
//            self.setNeedsLayout()
//            self.districtValueBlock?(self.districtValue)
//            self.mInputField.text = ""
//            self.viewController?.view.endEditing(true)
//        }
//        vc.modalPresentationStyle = .fullScreen
//        viewController?.present(vc, animated: true, completion: nil)
    }
    
    ///城市切换回调
    func districtValueBlock(block: CommonSiteSelectionMapNavigationDistrictValueBlock?){
        self.districtValueBlock = block
    }
    
    func clearTextField(){
        viewController?.view.endEditing(true)
        mInputField.text = ""
    }
}

extension CommonSiteSelectionMapNavigationView: UITextFieldDelegate {
//    ///仅限于汉字、字母、数字
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard textField.markedTextRange == nil else { return true }
//        let newString = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
//        return RegularExpUtil.isCEN(value: newString)
//    }
}
