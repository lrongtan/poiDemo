//
//  CommonSiteHistoryDP.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/10/11.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteHistoryDP {
    
    static let CommonSiteHistoryDPKey = "CommonSiteHistoryDPKey"
    
    static var dp = CommonSiteHistoryDP.init()
    
    /// -poi历史列表
    private var _poiList: [AMapPOI] = []
    
    private init() {
        let userDefaults = UserDefaults.standard
        if let val = userDefaults.value(forKey: CommonSiteHistoryDP.CommonSiteHistoryDPKey) as? Data {
            let va = NSKeyedUnarchiver.unarchiveObject(with: val) as? [AMapPOI] ?? []
            _poiList = va
        }
    }
    
    /// -poilist
    func getPoiList() -> [AMapPOI] {
        return _poiList
    }
    
    /// -poilist
    func setPoiList(value: [AMapPOI]){
        let userDefaults = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        userDefaults.setValue(data, forKey: CommonSiteHistoryDP.CommonSiteHistoryDPKey)
        userDefaults.synchronize()
        _poiList = value
    }
    /// 添加单个poi 并且去重
    func addPoiItem(poi: AMapPOI) {
//        var tmpPois: [AMapPOI] = _poiList
        var tmpPois: [AMapPOI] = _poiList.filter { tmpPoi in
            tmpPoi.address != poi.address || tmpPoi.name != poi.name || tmpPoi.province != poi.province || tmpPoi.city != poi.city || tmpPoi.district != poi.district
        }
        tmpPois.insert(poi, at: 0)
        
        let userDefaults = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: tmpPois)
        userDefaults.setValue(data, forKey: CommonSiteHistoryDP.CommonSiteHistoryDPKey)
        userDefaults.synchronize()
        _poiList = tmpPois
    }
    
    /// 清除数据
    func removePoiList() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: CommonSiteHistoryDP.CommonSiteHistoryDPKey)
        _poiList = []
    }

}
