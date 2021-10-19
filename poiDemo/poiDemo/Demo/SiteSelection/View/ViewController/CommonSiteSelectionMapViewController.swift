//
//  SiteSelectionMapViewController.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/4/27.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteSelectionMapViewController: UIViewController {
    
    typealias CommonSiteSelectionDidFinishBlock = ((_ value: CommonSiteSelectionCellModel) -> Void)

    //MARK: -propety
    
    private let _baseDisposeBag = DisposeBag()
    
    ///外部出入定位点的值
    var siteValue: CommonSiteSelectionCellModel?
    
    var siteSelectionMapDidFinishBlock: CommonSiteSelectionDidFinishBlock?
    
    //MARK: -subviews
    
    lazy var mNavigationView = CommonSiteSelectionMapNavigationView.init()
    
    lazy var mMapView: CommonSiteSelectionMapView = {
        let view = CommonSiteSelectionMapView.init(frame: CGRect.zero, siteValue: siteValue)
        return view
    }()
    
    lazy var mTableView = CommonSiteSelectionTableView.init()
    
    lazy var mInputBgView: UIView = {
        let view = UIView.init()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.isHidden = true
        return view
    }()
    
    lazy var mSearchTableView = CommonSiteSelectionSearchTableView.init()
    
    //MARK: -init
    
    init(siteValue: CommonSiteSelectionCellModel? = nil, block: CommonSiteSelectionDidFinishBlock? = nil) {
        self.siteValue = siteValue
        self.siteSelectionMapDidFinishBlock = block
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initAction()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutView()
    }
    
    //MARK: -private
    
    private func initView(){
        view.addSubview(mMapView)
        view.addSubview(mNavigationView)
        view.addSubview(mTableView)
        view.addSubview(mInputBgView)
        view.addSubview(mSearchTableView)
        view.backgroundColor = .white
    }
    
    private func layoutView(){
        mNavigationView.frame = CGRect.init(x: 0, y: 0, width: view.width, height: view.safeAreaInsets.top + 45)
        let mapHeight = (view.height - mNavigationView.bottom)/2
        
        mMapView.frame = CGRect.init(x: 0, y: mNavigationView.bottom, width: view.width, height: mapHeight)
        
        mTableView.frame = CGRect.init(x: 0, y: mMapView.bottom, width: view.width, height: view.height - mMapView.bottom)
        
        mSearchTableView.frame = CGRect.init(x: 0, y: mNavigationView.bottom, width: view.width, height: view.height - mNavigationView.bottom)
        mInputBgView.frame = mSearchTableView.frame
        
    }
    
    private func initAction(){
        
        mMapView.poiSearchResultBlock { [weak self](dataSources, isSearching) in
            guard let self = self else { return }
            self.mTableView.updateDataSources(values: dataSources, isSearching: isSearching)
        }
        mNavigationView.mInputField.rx.controlEvent(UIControl.Event.editingChanged).debounce(RxTimeInterval.milliseconds(800), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if self.mNavigationView.mInputField.markedTextRange == nil {
                self.mSearchTableView.inputTextValueChange(value: self.mNavigationView.mInputField.text ?? "")
            }
        }).disposed(by: _baseDisposeBag)

        mNavigationView.mInputField.rx.text.orEmpty.subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            if self.mNavigationView.mInputField.markedTextRange == nil && text.count == 0 {
                self.mSearchTableView.inputTextValueChange(value: self.mNavigationView.mInputField.text ?? "")
            }
        }).disposed(by: _baseDisposeBag)
        
        mNavigationView.mInputField.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if self.mNavigationView.mInputField.isEditing && self.mSearchTableView.isHidden {
                self.mSearchTableView.show()
            }
//            self.mInputBgView.isHidden = !self.mNavigationView.mInputField.isEditing
        }).disposed(by: _baseDisposeBag)
        
        mNavigationView.mInputField.rx.controlEvent(.editingDidBegin).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if self.mNavigationView.mInputField.isEditing && self.mSearchTableView.isHidden {
                self.mSearchTableView.show()
            }
//            self.mInputBgView.isHidden = !self.mNavigationView.mInputField.isEditing
        }).disposed(by: _baseDisposeBag)
        
        mNavigationView.districtValueBlock { [weak self] (district) in
            guard let self = self else { return }
            self.mSearchTableView.districtValueChange(value: district)
        }
        
        mNavigationView.mCancelButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.mNavigationView.clearTextField()
            self.mSearchTableView.inputTextValueChange(value: "", alwaysHidden: true)
            self.mSearchTableView.hidden()
        }).disposed(by: _baseDisposeBag)
        
        mNavigationView.mBackButton.rx.tap.subscribe(onNext: { [weak self](_) in
            guard let self = self else { return }
            guard self.mSearchTableView.isHidden else {
                self.mNavigationView.clearTextField()
                self.mSearchTableView.inputTextValueChange(value: "", alwaysHidden: true)
                self.mSearchTableView.hidden()
                return
            }
            if self.navigationController?.viewControllers.count ?? 0 <= 1{
                self.dismiss(animated: true, completion: nil)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: _baseDisposeBag)
        
        mSearchTableView.districtValueChange(value: mNavigationView.districtValue)
        
        mTableView.mTableView.rx.modelSelected(CommonSiteSelectionCellModel.self).subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            self.mMapView.selectedCellSite(site: value)
//            self.siteSelectionMapDidFinishBlock?(value)
        }).disposed(by: _baseDisposeBag)
        
        mSearchTableView.mTableView.rx.modelSelected(CommonSiteSelectionCellModel.self).subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            self.mMapView.selectedCellSite(site: value)
            self.mNavigationView.clearTextField()
            self.mSearchTableView.inputTextValueChange(value: "", alwaysHidden: true)
            self.mSearchTableView.hidden()
        }).disposed(by: _baseDisposeBag)
        
        mMapView.mSelectedButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            guard let selectedSite = self.mMapView.selectedSite else {
                GlobalProgressHUD.showHUDText(title: "获取位置信息失败")
                return
            }
            self.dismiss()
            self.siteSelectionMapDidFinishBlock?(selectedSite)
        }).disposed(by: _baseDisposeBag)
    }
    
    private func dismiss(){
        if navigationController?.viewControllers.count ?? 0 <= 1{
            dismiss(animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
}
