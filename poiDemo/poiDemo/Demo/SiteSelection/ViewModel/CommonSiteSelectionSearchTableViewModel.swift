//
//  CommonSiteSelectionSearchTableViewModel.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/4/28.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteSelectionSearchTableViewModel: NSObject {
    
    public struct Input {
        var inputText: BehaviorRelay<String>
        var district: String = ""
    }

    public struct Output {
        var sections: BehaviorRelay<[SectionModel<Bool, CommonSiteSelectionCellModel>]>
        var isSearching: BehaviorRelay<Bool>
        var isSearchingResult: Bool = false
    }
    
    private var disposeBag: DisposeBag!
    
    private var searchApi: AMapSearchAPI?
        
    var input: Input!
    
    var output: Output!

    init(input: Input, disposeBag: DisposeBag) {
        self.input = input
        self.disposeBag = disposeBag
        super.init()
        
        output = Output.init(
            sections: BehaviorRelay<[SectionModel<Bool, CommonSiteSelectionCellModel>]>(value: [
                SectionModel<Bool, CommonSiteSelectionCellModel>.init(model: true, items: [])
            ]),
            isSearching: BehaviorRelay<Bool>(value: true))
        initSearchApi()
        initInput()
        
    }
    
    private func initSearchApi(){
        searchApi = AMapSearchAPI.init()
        searchApi?.delegate = self
    }
    
    private func initInput(){
        input.inputText.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            self.keywordSearchPoi(keyword: value)
        }).disposed(by: disposeBag)
    }
    
    private func keywordSearchPoi(keyword: String) {
        let val = keyword.replacingOccurrences(of: " ", with: "")
        searchApi?.cancelAllRequests()
        if val.isEmpty {
            // 延迟执行 防止点击cell 无反应
            Observable<Int>.timer(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let historyPois = CommonSiteHistoryDP.dp.getPoiList().prefix(20)
                if historyPois.count > 0 {
                    let cells: [CommonSiteSelectionCellModel] = historyPois.map { (_poi) -> CommonSiteSelectionCellModel in
                        return CommonSiteSelectionCellModel.init(poi: _poi)
                    }
                    self.output.isSearchingResult = false
                    self.output.sections.accept([SectionModel<Bool, CommonSiteSelectionCellModel>.init(model: true, items: cells)])
                } else {
                    self.output.isSearchingResult = false
                    self.output.sections.accept([
                        SectionModel<Bool, CommonSiteSelectionCellModel>.init(model: true, items: [])
                    ])
                }
                self.output.isSearching.accept(false)
            }).disposed(by: disposeBag)
            return
        }
        let keywordRequest = AMapPOIKeywordsSearchRequest.init()
        keywordRequest.city = input.district
        keywordRequest.keywords = val
        keywordRequest.cityLimit = true
        keywordRequest.requireExtension = true
        keywordRequest.requireSubPOIs = true
        keywordRequest.types = CommonSiteSelectionConstants.poiTypes
        output.isSearching.accept(true)
        output.isSearchingResult = true
        output.sections.accept([
            SectionModel<Bool, CommonSiteSelectionCellModel>.init(model: false, items: [])
        ])
        searchApi?.aMapPOIKeywordsSearch(keywordRequest)
    }
    
    func clearHistory() {
        CommonSiteHistoryDP.dp.removePoiList()
        output.isSearchingResult = false
        output.sections.accept([
            SectionModel<Bool, CommonSiteSelectionCellModel>.init(model: true, items: [])
        ])
    }
}

extension CommonSiteSelectionSearchTableViewModel: AMapSearchDelegate {
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        if let error = error as NSError?, error.code != 1807 {
//            GlobalProgressHUD.showHUDText(title: "抱歉，没有搜索到相关地址")
            output.isSearching.accept(false)
            output.isSearchingResult = true
            output.sections.accept([SectionModel<Bool, CommonSiteSelectionCellModel>.init(model: false, items: [])])
        }
    }
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        let cells: [CommonSiteSelectionCellModel] = response.pois.map { (_poi) -> CommonSiteSelectionCellModel in
            return CommonSiteSelectionCellModel.init(poi: _poi)
        }
        output.isSearchingResult = true
        output.isSearching.accept(false)
        output.sections.accept([SectionModel<Bool, CommonSiteSelectionCellModel>.init(model: false, items: cells)])
        if cells.count == 0 {
//            GlobalProgressHUD.showHUDText(title: "抱歉，没有搜索到相关地址")
        }
    }
}
