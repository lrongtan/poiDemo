//
//  CommonSiteSelectionMapView.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/4/27.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteSelectionMapView: UIView {
    
    typealias CommonSiteSelectionMapViewPoiSearchResultBlock = ((_ cellModels: [CommonSiteSelectionCellModel], _ isSearching: Bool) -> Void)
    
    //MARK: -propety
    
    ///外部出入定位点的值
    var siteValue: CommonSiteSelectionCellModel?
    
    var selectedSite: CommonSiteSelectionCellModel? {
        return vm.selectedSite()
    }
        
    private var isNeedLocation: Bool {
        return (siteValue == nil)
    }

    private var centerAnnotation: MAPointAnnotation!
    
    private var animateKey = "animateKey"
    
    private var poiSearchResultBlock: CommonSiteSelectionMapViewPoiSearchResultBlock?
    
    private var vm: CommonSiteSelectionMapViewModel!
    
    private let disposeBag = DisposeBag()
    
    /// 地图区域变化 是否 用户主动操作
    private var _isMapRegionUserAction: Bool = false
    
    /// 手动点击定位
    private var _userActionLocation: Bool = true
    
    /// 触发mMapView.setCenter
    private var _mapViewSetCenterHandle: Bool = false

    //MARK: -subviews
    
    lazy var mMapView: MAMapView = {
        let view = MAMapView.init()
        view.showsUserLocation = true
        view.zoomLevel = 17
        return view
    }()
    
    lazy var mLocationButton: CommonButton = {
        let view = CommonButton.init()
        view.setImage(UIImage.init(named: "station_map_loction_normal"), for: .normal)
        view.setImage(UIImage.init(named: "station_map_loction_select"), for: .highlighted)
        return view
    }()
    
    lazy var mSelectedButton: CommonButton = {
        let view = CommonButton.initDefaultButton(title: "确定")
        view.layer.cornerRadius = 16
        return view
    }()
    
    var mCenterAnnotationView: MAAnnotationView?
    
    //MARK: - init
    init(frame: CGRect, siteValue: CommonSiteSelectionCellModel? = nil) {
        self.siteValue = siteValue
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
    
    private func initView(){
        addSubview(mMapView)
        mMapView.addSubview(mLocationButton)
        mMapView.addSubview(mSelectedButton)

//        if let path = Bundle.main.path(forResource: "style", ofType: "data"), let data = NSData.init(contentsOf: URL.init(fileURLWithPath: path)){
//            let customStyle = MAMapCustomStyleOptions.init()
//            customStyle.styleData = data as Data
//            if let extraPath = Bundle.main.path(forResource: "style_extra", ofType: "data"), let extraData = NSData.init(contentsOf: URL.init(fileURLWithPath: extraPath)) {
//                customStyle.styleExtraData = extraData as Data
//            }
//            mMapView.setCustomMapStyleOptions(customStyle)
//            mMapView.customMapStyleEnabled = true
//        }
    }
    
    private func layoutView(){
        mMapView.frame = bounds
        mLocationButton.frame = CGRect.init(x: 15, y: mMapView.height - 40 - 24, width: 40, height: 40)
        mSelectedButton.frame = CGRect.init(x: mMapView.width - 15 - 100, y: mMapView.height - 32 - 24, width: 100, height: 32)
        
        centerAnnotation.lockedScreenPoint = CGPoint.init(x: mMapView.width/2, y: mMapView.height/2)
        
        mMapView.removeAnnotation(centerAnnotation)
        mMapView.addAnnotation(centerAnnotation)
    }
    
    private func initAction(){
        
        centerAnnotation = MAPointAnnotation.init()
        centerAnnotation.isLockedToScreen = true
        
        mMapView.delegate = self
        
//        mMapView.showsUserLocation = isNeedLocation
        
        setLocationSite(alwaysLocation: false)
        
        // 已选择位置点
//        if let _siteValue = siteValue, let coordinate2D = _siteValue.coordinate2D {
//            let u = MAUserLocation.init()
//            u.coordinate = coordinate2D
//            u.title = _siteValue.name
//            mMapView.addAnnotation(u)
//        }

        vm = CommonSiteSelectionMapViewModel.init(
            input: CommonSiteSelectionMapViewModel.Input(
                centerCoordinate2D: PublishRelay<CLLocationCoordinate2D>(),
                needFilterData: siteValue != nil,
                siteValue: siteValue),
            disposeBag: disposeBag)
        
        vm.output.isSearching.subscribe(onNext: { [weak self] isSearching in
            guard let self = self else { return }
            var results: [CommonSiteSelectionCellModel] = []
            if !isSearching {
                if let centerSite = self.vm.output.centerSite {
                    self.centerAnnotation.title = centerSite.name
                    self.mMapView.removeAnnotation(self.centerAnnotation)
                    self.mMapView.addAnnotation(self.centerAnnotation)
                    self.mCenterAnnotationView?.canShowCallout = true
                    self.mMapView.selectAnnotation(self.centerAnnotation, animated: true)
//                    results.append(centerSite)
                }
                results.append(contentsOf: self.vm.output.searchResults)
            }
            self.poiSearchResultBlock?(results, isSearching)
        }).disposed(by: disposeBag)
        
        mLocationButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.setLocationSite()
        }).disposed(by: disposeBag)
    }
    
    ///将定位点移到地图中间
    ///外部有传入定位点点使用外部的。否则使用地图定位
    private func setLocationSite(alwaysLocation: Bool = true){
        guard !alwaysLocation else {
            _userActionLocation = true
            mMapView.setUserTrackingMode(.follow, animated: true)
            return
        }
        if isNeedLocation {
            _userActionLocation = true
            mMapView.setUserTrackingMode(.follow, animated: true)
        }else{
            if let site = siteValue {
                if let coordinate2D = site.realCoordinate2D {
                    _mapViewSetCenterHandle = true
                    mMapView.setCenter(coordinate2D, animated: true)
                    return
                }
                if let coordinate2D = site.coordinate2D {
                    _mapViewSetCenterHandle = true
                    mMapView.setCenter(coordinate2D, animated: true)
                    return
                }
            }
        }
    }
    
    func poiSearchResultBlock(block: CommonSiteSelectionMapViewPoiSearchResultBlock?) {
        self.poiSearchResultBlock = block
    }
    
    func selectedCellSite(site: CommonSiteSelectionCellModel){
        vm.input.cellSelectedSite = site
        if let coordinate2D = site.coordinate2D {
            _mapViewSetCenterHandle = true
            mMapView.setCenter(coordinate2D, animated: true)
        }
    }
}

extension CommonSiteSelectionMapView: MAMapViewDelegate {
    
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
//
        if annotation.isKind(of: MAUserLocation.self) {
//            let annotationView = MAAnnotationView.init(annotation: annotation, reuseIdentifier: "MAUserLocation")
//            annotationView?.image = UIImage.init(named: "station_map_navigation_white")
//            return annotationView
            
            return nil
        }
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let annotationView = MAAnnotationView.init(annotation: annotation, reuseIdentifier: "====")
            annotationView?.image = UIImage.init(named: "common_map_mark_center")
            let customCalloutView = CommonSiteSelectionCustomCalloutView.init(frame: CGRect.zero)
            customCalloutView.calloutTitle = annotation.title
            annotationView?.customCalloutView = customCalloutView
            mCenterAnnotationView = annotationView
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, regionWillChangeAnimated animated: Bool, wasUserAction: Bool) {
        // Bugfix: 解决个别机型 mapView.userTrackingMode = .none 之后 regionWillChangeAnimated等方法还是会被调用
        _isMapRegionUserAction = wasUserAction
        if _isMapRegionUserAction || _userActionLocation || _mapViewSetCenterHandle {
            mCenterAnnotationView?.canShowCallout = false
            mMapView.removeAnnotation(centerAnnotation)
            mMapView.addAnnotation(centerAnnotation)
            mMapView.selectAnnotation(nil, animated: true)
        }
        if !_mapViewSetCenterHandle {
            vm.input.cellSelectedSite = nil
        }
    }
    
    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool, wasUserAction: Bool) {
        // Bugfix: 解决个别机型 mapView.userTrackingMode = .none 之后 regionWillChangeAnimated等方法还是会被调用
        _isMapRegionUserAction = wasUserAction
        if _isMapRegionUserAction || _userActionLocation || _mapViewSetCenterHandle {
            vm.input.centerCoordinate2D.accept(mMapView.centerCoordinate)
            if mapView.userLocation.location != nil {
                _userActionLocation = false
            }
            _mapViewSetCenterHandle = false
        }
    }
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if userLocation.location != nil && mapView.userTrackingMode != .none {
            mapView.userTrackingMode = .none
        }
    }
}
