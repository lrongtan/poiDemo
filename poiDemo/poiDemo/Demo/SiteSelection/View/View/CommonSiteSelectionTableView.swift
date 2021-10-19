//
//  CommonSiteSelectionTableView.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/4/27.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteSelectionTableView: UIView {
    
    //MARK: -propety
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String,CommonSiteSelectionCellModel>>!
    
    private let _disposeBag = DisposeBag()
    
    private let cellIdentifier = "cellIdentifier"
    
    private var sections = BehaviorRelay<[SectionModel<String,CommonSiteSelectionCellModel>]>.init(value: [])
    
    //MARK: -subview
        
    lazy var mIconImage: UIButton = {
        let view = UIButton.init()
        view.setImage(UIImage.init(named: "station_map_level"), for: .normal)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var mTableView: UITableView = {
        let view = UITableView.init(frame: CGRect.zero, style: .plain)
        view.backgroundColor = .white
        view.separatorInset = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        view.separatorColor = BaseUIConfig.gray_bg
        view.rowHeight = 53
        view.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 1, height: 1))
        return view
    }()
    
    lazy var mIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView.init(style: .gray)
        view.hidesWhenStopped = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mIconImage)
        addSubview(mTableView)
        addSubview(mIndicatorView)

        initAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mIconImage.frame = CGRect.init(x: 0, y: 4, width: width, height: 20)
        
        mTableView.frame = CGRect.init(x: 0, y: mIconImage.bottom, width: width, height: height - mIconImage.bottom)
        mIndicatorView.frame = CGRect.init(origin: mTableView.center, size: CGSize.init(width: 40, height: 40))
        mIndicatorView.center = mTableView.center
    }
    
    private func initAction() {
        mTableView.register(CommonSiteSelectionTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,CommonSiteSelectionCellModel>>.init(configureCell: { [weak self](_, tableView, indexPath, element) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: self!.cellIdentifier, for: indexPath) as! CommonSiteSelectionTableViewCell
            cell.setCellModel(value: element)
            if element.isAnchorPoint {
                cell.mIconImage.image = UIImage.init(named: "common_map_mark_center")
            }else{
                cell.mIconImage.image = UIImage.init(named: "common_site_selection_poi")
            }
            return cell
        })
        
        sections.bind(to: mTableView.rx.items(dataSource: dataSource)).disposed(by: _disposeBag)
        
        mTableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let self = self else { return }
            let cell = self.mTableView.cellForRow(at: indexPath)
            cell?.setSelected(false, animated: true)
        }).disposed(by: _disposeBag)
    }
    
    func updateDataSources(values: [CommonSiteSelectionCellModel], isSearching: Bool){
        
        if !isSearching {
            sections.accept([SectionModel<String, CommonSiteSelectionCellModel>.init(model: "", items: values)])
            mIndicatorView.stopAnimating()
        }else{
            mIndicatorView.startAnimating()
        }
    }
}
