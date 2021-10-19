//
//  CommonSiteSelectionSearchTableView.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/4/27.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteSelectionSearchTableView: UIView {
    
    //MARK: -propety
    
    private var vm: CommonSiteSelectionSearchTableViewModel!
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Bool,CommonSiteSelectionCellModel>>!
    
    private let _disposeBag = DisposeBag()
    
    private let cellIdentifier = "cellIdentifier"
    
    //MARK: -subviews
    
    lazy var mTableView: UITableView = {
        let view = UITableView.init(frame: CGRect.zero, style: .grouped)
        view.backgroundColor = .white
        view.separatorInset = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        view.separatorColor = BaseUIConfig.gray_bg
        view.rowHeight = 53
        view.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 1, height: 1))
        view.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 1, height: 1))
        if #available(iOS 15.0, *) {
            view.sectionHeaderTopPadding = 0
        }
        return view
    }()
    
    lazy var mIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView.init(style: .gray)
        view.hidesWhenStopped = true
        return view
    }()
    
    lazy var mSectionHeaderView = UIView.init()
    
    lazy var mSectionLabel: UILabel = {
        let view = UILabel.init()
        view.text = "历史记录"
        view.textColor = BaseUIConfig.black
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    lazy var mSectionClearButton: CommonButton = {
        let view = CommonButton()
        view.setImage(UIImage.init(named: "index_v3_search_delete"), for: .normal)
        view.setImage(UIImage.init(named: "index_v3_search_delete"), for: .highlighted)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mTableView)
        
        addSubview(mIndicatorView)
        mSectionHeaderView.backgroundColor = .white
        mSectionHeaderView.addSubview(mSectionLabel)
        
        mSectionHeaderView.addSubview(mSectionClearButton)
        mSectionLabel.frame = CGRect.init(x: 15, y: 0, width: 200, height: 40)

        initAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mTableView.frame = bounds
        var c = mTableView.center
        c.y = mTableView.height/3
        mIndicatorView.frame = CGRect.init(origin: c, size: CGSize.init(width: 40, height: 40))
        mIndicatorView.center = c
    }
    
    //MARK: -private
    
    private func initAction(){
        mTableView.register(CommonSiteSelectionTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        vm = CommonSiteSelectionSearchTableViewModel.init(input: CommonSiteSelectionSearchTableViewModel.Input(inputText: BehaviorRelay<String>(value: "")), disposeBag: _disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Bool,CommonSiteSelectionCellModel>>.init(configureCell: { [weak self](_dataSource, tableView, indexPath, element) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: self!.cellIdentifier, for: indexPath) as! CommonSiteSelectionTableViewCell
            cell.setCellModel(value: element)
            if _dataSource[indexPath.section].model {
                cell.mIconImage.image = UIImage.init(named: "common_site_selection_history")
            }else{
                cell.mIconImage.image = UIImage.init(named: "common_site_selection_location")
            }
            return cell
        })
        
        vm.output.sections.bind(to: mTableView.rx.items(dataSource: dataSource)).disposed(by: _disposeBag)
        
        vm.output.isSearching.subscribe(onNext: { [weak self] isSearching in
            guard let self = self else { return }
            if isSearching {
                self.mIndicatorView.startAnimating()
            }else{
                self.mIndicatorView.stopAnimating()
            }
        }).disposed(by: _disposeBag)
        
        mTableView.rx.didScroll.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.viewController?.view.endEditing(true)
        }).disposed(by: _disposeBag)
        
        mTableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let self = self else { return }
            let cell = self.mTableView.cellForRow(at: indexPath)
            cell?.setSelected(false, animated: true)
        }).disposed(by: _disposeBag)
        
        mTableView.rx.modelSelected(CommonSiteSelectionCellModel.self).subscribe(onNext: { siteVal in
            guard let poi = siteVal.poiValue else { return }
            CommonSiteHistoryDP.dp.addPoiItem(poi: poi)
        }).disposed(by: _disposeBag)
        
        mTableView.rx.setDelegate(self).disposed(by: _disposeBag)
        
        mSectionClearButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.vm.clearHistory()
        }).disposed(by: _disposeBag)
    }
    
    ///关键字值变化
    func inputTextValueChange(value: String, alwaysHidden: Bool = false){
        let val = value.replacingOccurrences(of: " ", with: "")
        vm.input.inputText.accept(val)
//        let historyPois = CommonSiteHistoryDP.dp.getPoiList()
//        if alwaysHidden {
//            isHidden = true
//        } else {
//            if val.isEmpty {
//                isHidden = historyPois.count > 0 ? false : true
//            } else {
//                isHidden = false
//            }
//        }
    }
    
    ///城市切换
    func districtValueChange(value: String){
        vm.input.district = value
        vm.input.inputText.accept("")
        isHidden = true
    }
    
    func show() {
        isHidden = false
    }
    
    func hidden() {
        isHidden = true
    }
}

extension CommonSiteSelectionSearchTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let _sectionM = dataSource[section]
        if _sectionM.model {
            return 40
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let _sectionM = dataSource[section]
        if _sectionM.model {
            return mSectionHeaderView
        }
        return nil
    }
}
