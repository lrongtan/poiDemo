//
//  MapReGeocodeUtil.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/1/22.
//  Copyright © 2021 cgf. All rights reserved.
//

import UIKit

class MapReGeocodeUtil: NSObject {
    typealias MapReGeocodeDidFinishBlock = ((_ reGeocode: AMapReGeocode?, _ error: Error?) -> Void)
    
    private var searchApi: AMapSearchAPI?
    
    private var regeocodeDidFinishBlock: MapReGeocodeDidFinishBlock?
    
    override init() {
        super.init()
        searchApi = AMapSearchAPI.init()
        searchApi?.delegate = self
    }
    
    public func regeocode(regeoReq: AMapReGeocodeSearchRequest, block: @escaping MapReGeocodeDidFinishBlock){
        searchApi?.cancelAllRequests()
        regeocodeDidFinishBlock = block
        searchApi?.aMapReGoecodeSearch(regeoReq)
    }
}

extension MapReGeocodeUtil: AMapSearchDelegate {
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        regeocodeDidFinishBlock?(response.regeocode,nil)
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        regeocodeDidFinishBlock?(nil,error)
    }
}
