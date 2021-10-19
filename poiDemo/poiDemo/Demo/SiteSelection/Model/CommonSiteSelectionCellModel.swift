//
//  CommonSiteSelectionCellModel.swift
//  newenergy-ios
//
//  Created by 李荣潭 on 2021/4/27.
//  Copyright © 2021 Nebula. All rights reserved.
//

import UIKit

class CommonSiteSelectionCellModel: NSObject, NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = CommonSiteSelectionCellModel.init()
        copyObj.name = self.name
        copyObj.address = self.address
        copyObj.detailAddress = self.detailAddress
        copyObj.isAnchorPoint = self.isAnchorPoint
        copyObj.province = self.province
        copyObj.pcode = self.pcode
        copyObj.city = self.city
        copyObj.citycode = self.citycode
        copyObj.district = self.district
        copyObj.adcode = self.adcode
        copyObj.coordinate2D = self.coordinate2D
        return copyObj
    }
    
    ///地址名称
    var name: String = ""
    
    ///地址
    var address: String = ""
    
    ///详细地址
    var detailAddress: String = ""

    var isAnchorPoint: Bool = false
    
    ///省
    var province: String?
    
    ///省编码
    var pcode: String?

    ///城市名称
    var city: String?

    ///城市编码
    var citycode: String?

    ///区域名称
    var district: String?

    ///区域编码
    var adcode: String?

    ///经纬度(poi点的经纬度)
    var coordinate2D: CLLocationCoordinate2D?
    
    /// AMapPOI
    var poiValue: AMapPOI?
    
    /// 实际经纬度
    var realCoordinate2D: CLLocationCoordinate2D?
    
    init(reGeocode: AMapReGeocode, coordinate2D: CLLocationCoordinate2D) {
        self.coordinate2D = coordinate2D
        self.isAnchorPoint = true
        let replaceValue = reGeocode.addressComponent.province + reGeocode.addressComponent.city + reGeocode.addressComponent.district + reGeocode.addressComponent.township
        let name = reGeocode.formattedAddress.replacingOccurrences(of: replaceValue, with: "")
        self.name = name
        self.address = replaceValue + reGeocode.addressComponent.neighborhood + reGeocode.addressComponent.streetNumber.street + reGeocode.addressComponent.streetNumber.number
        
        self.province = reGeocode.addressComponent.province
//        self.pcode = reGeocode.addressComponent
        self.city = reGeocode.addressComponent.city
        self.citycode = reGeocode.addressComponent.citycode
        self.district = reGeocode.addressComponent.district
        self.adcode = reGeocode.addressComponent.adcode
    }
    
    init(poi: AMapPOI) {
        self.poiValue = poi
        self.coordinate2D = CLLocationCoordinate2D.init(latitude: Double(poi.location.latitude), longitude: Double(poi.location.longitude))
        self.name = poi.name
        let prefix = poi.province + poi.city + poi.district
        if poi.address != "" {
            self.address = prefix + poi.address
        }else{
            self.address = prefix + poi.name
        }
        
        self.province = poi.province
        self.pcode = poi.pcode
        self.city = poi.city
        self.citycode = poi.citycode
        self.district = poi.district
        self.adcode = poi.adcode
    }
    
    override init() {
        
    }
}
