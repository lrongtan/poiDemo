//
//  CommonSiteSelectionMapViewModel.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/4/27.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteSelectionMapViewModel: NSObject {
    
    public struct Input {
        var centerCoordinate2D: PublishRelay<CLLocationCoordinate2D>
        /// 外部传入位置。第一次需要直接展示该位置
        var needFilterData: Bool
        var siteValue: CommonSiteSelectionCellModel?
        /// cell 点击选中
        var cellSelectedSite: CommonSiteSelectionCellModel?
    }

    public struct Output {
        var centerSite: CommonSiteSelectionCellModel?
        var searchResults: [CommonSiteSelectionCellModel] = []
        var isSearching: PublishRelay<Bool>
        /// poi最近的位置
        var mainSite: CommonSiteSelectionCellModel?
        /// 实际经纬度
        var realSite: CommonSiteSelectionCellModel?
    }
    
    // MARK: -propety
    private var disposeBag: DisposeBag!
    
    private let mapReGeocodeUtil = MapReGeocodeUtil.init()
    
    private var searchApi: AMapSearchAPI?
    
    private var isPoiSearching: PublishRelay<Bool>
    
    private var isReGeoSearching: PublishRelay<Bool>
    
    private var reGeocode: AMapReGeocode?
    private var pois: [AMapPOI] = []
    private var poiAroundSearchRequest: AMapPOIAroundSearchRequest?
    private var isSearchCancel: Bool = false
    
    var input: Input!
    
    var output: Output!

    init(input: Input, disposeBag: DisposeBag) {
        self.input = input
        self.disposeBag = disposeBag
        isPoiSearching = PublishRelay<Bool>()
        isReGeoSearching = PublishRelay<Bool>()
        super.init()
        output = Output.init(
            centerSite: nil,
            searchResults: [],
            isSearching: PublishRelay<Bool>())
        initSearchApi()
        initInput()
        initRxZip()
    }
    
    private func initInput(){
        input.centerCoordinate2D.debounce(RxTimeInterval.milliseconds(650), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] coordinate2D in
            guard let self = self else { return }
            let regeoReq = AMapReGeocodeSearchRequest.init()
            regeoReq.poitype = CommonSiteSelectionConstants.poiTypes
            regeoReq.requireExtension = true
            regeoReq.location = AMapGeoPoint.location(withLatitude: CGFloat(coordinate2D.latitude), longitude: CGFloat(coordinate2D.longitude))
            self.mapReGeocodeUtil.regeocode(regeoReq: regeoReq) { [weak self] (regeo, error) in
                guard let self = self else { return }
                self.reGeocode = regeo
                self.isReGeoSearching.accept(false)
            }
            self.searchPOIAround(coordinate2D: coordinate2D)
        }).disposed(by: disposeBag)
        if let mainSite = input.siteValue {
            output.mainSite = mainSite.copy(with: nil) as? CommonSiteSelectionCellModel
            output.realSite = mainSite.copy(with: nil) as? CommonSiteSelectionCellModel
            if let realCoordinate2D = input.siteValue?.realCoordinate2D {
                output.realSite?.coordinate2D = realCoordinate2D
            }
        }
    }
    
    private func initRxZip(){
        Observable.zip(isReGeoSearching.asObservable(), isPoiSearching.asObservable()).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            guard !self.isSearchCancel else { return }
            
//            // 外部传入数据
//            if self.input.needFilterData {
//                self.input.needFilterData = false
//                self.input.cellSelectedSite = self.input.siteValue
//            }
            
            var cells: [CommonSiteSelectionCellModel] = self.pois.map { (_poi) -> CommonSiteSelectionCellModel in
                return CommonSiteSelectionCellModel.init(poi: _poi)
            }
            
            if let reGeocode = self.reGeocode, let req = self.poiAroundSearchRequest {
                
                let coordinate = CLLocationCoordinate2DMake(req.location.latitude, req.location.longitude)
                let reGeocodeSite = CommonSiteSelectionCellModel.init(reGeocode: reGeocode, coordinate2D: coordinate)
     
                let reGeocodePoiCells: [CommonSiteSelectionCellModel] = reGeocode.pois.map({ _poi in
                    return CommonSiteSelectionCellModel.init(poi: _poi)
                })
//                if let reGeocodePoiFirst = reGeocodePoiCells.first {
//                    cells.removeAll { tmpv in
//                        tmpv.name == reGeocodePoiFirst.name
//                    }
//                    cells.insert(reGeocodePoiFirst, at: 0)
//                }
                
                /// 从逆编码poi结果取出与逆编码结果相同的地址
                if let _reGeocodeSite = reGeocodePoiCells.first(where: { tmpv in
                    tmpv.name == reGeocodeSite.name
                }) {
                    cells.removeAll { tmpv in
                        tmpv.name == _reGeocodeSite.name
                    }
                    cells.insert(_reGeocodeSite, at: 0)
                }
                
                // poi列表有和逆编码结果一致的。选用一致的那个值
                if let _reGeocodeSite = cells.first(where: { tmpv in
                    tmpv.name == reGeocodeSite.name
                }) {
                    cells.removeAll { tmpv in
                        tmpv.name == _reGeocodeSite.name
                    }
                    cells.insert(_reGeocodeSite, at: 0)
                }
            }
            
//            // 点击cell时  防止多个数据距离一样导致选中的cell 无法在最前
//            if let cellSelectedSite = self.input.cellSelectedSite {
//                cells.removeAll { tmpv in
//                    tmpv.name == cellSelectedSite.name
//                }
//                cells.insert(cellSelectedSite, at: 0)
//            }
            
            if let siteV = cells.first, let req = self.poiAroundSearchRequest {
                let coordinate = CLLocationCoordinate2DMake(req.location.latitude, req.location.longitude)
                // 与上次poi结果的第一个值对比
                if siteV.name == self.output.mainSite?.name && siteV.name != "" {
                    // name 未发生改变 更新真实位置的经纬度
                    self.output.realSite?.coordinate2D = coordinate
                } else {
                    // name 发生改变 重新赋值
                    self.output.mainSite = siteV.copy(with: nil) as? CommonSiteSelectionCellModel
                    self.output.realSite = siteV.copy(with: nil) as? CommonSiteSelectionCellModel
                    self.output.realSite?.coordinate2D = coordinate
                }
            }else{
                self.output.mainSite = nil
                self.output.realSite = nil
            }
            self.input.cellSelectedSite = nil
            cells.first?.isAnchorPoint = true
            self.output.centerSite = cells.first
            self.output.searchResults = cells
            self.output.isSearching.accept(false)
            if cells.count == 0 {
                GlobalProgressHUD.showHUDText(title: "抱歉，没有搜索到相关地址")
            }
        }).disposed(by: disposeBag)
    }
    
    private func initSearchApi(){
        searchApi = AMapSearchAPI.init()
        searchApi?.delegate = self
    }
        
    private func searchPOIAround(coordinate2D: CLLocationCoordinate2D){
        searchApi?.cancelAllRequests()
        let req = AMapPOIAroundSearchRequest.init()
        req.location = AMapGeoPoint.location(withLatitude: CGFloat(coordinate2D.latitude), longitude: CGFloat(coordinate2D.longitude))
        req.requireExtension = true
        req.requireSubPOIs = true
        req.radius = 1000
        req.types = CommonSiteSelectionConstants.poiTypes
        searchApi?.aMapPOIAroundSearch(req)
        output.isSearching.accept(true)
    }
    
    func selectedSite() -> CommonSiteSelectionCellModel? {
        guard let mainSite = output.mainSite?.copy(with: nil) as? CommonSiteSelectionCellModel, let realSite = output.realSite else {
            return nil
        }
        mainSite.realCoordinate2D = realSite.coordinate2D
        return mainSite
    }
}


extension CommonSiteSelectionMapViewModel: AMapSearchDelegate {
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        poiAroundSearchRequest = nil
        // poi取消操作除外  code = 1807 取消
        if let error = error as NSError?, error.code != 1807 {
            isSearchCancel = false
            pois = []
            isPoiSearching.accept(false)
        }else {
            isSearchCancel = true
            isPoiSearching.accept(false)
        }
    }
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        response.pois.forEach { poi in
            debugPrint("==========poi\(poi.name)====\(poi.typecode)====\(poi.type)=====\(poi.distance)")
        }
        pois = response.pois
        isSearchCancel = false
        poiAroundSearchRequest = request as? AMapPOIAroundSearchRequest
        isPoiSearching.accept(false)
    }
}
