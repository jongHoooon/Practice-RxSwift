//
//  GeolocationService.swift
//  RxExample
//
//  Created by Carlos García on 19/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

class GeolocationService {
    
    static let instance = GeolocationService()
    private (set) var authorized: Driver<Bool>
    private (set) var location: Driver<CLLocationCoordinate2D>
    
    private let locationManager = CLLocationManager()
    
    private init() {
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        // deferred는 구독할때 마다 받는다
        authorized = Observable.deferred { [weak locationManager] in
            
                let status = CLLocationManager.authorizationStatus()
            
                // 없으면 현재 상태 그냥 연결
                guard let locationManager = locationManager else {
                    return Observable.just(status)
                }
            
                // 있으면(한번이라도 해당 서비스를 사용했다면)
                return locationManager
                    .rx.didChangeAuthorizationStatus
                    // 변경이 일어나지 않았을 경우를 대비해서 앞에 현재상태 붙이기
                    .startWith(status)
            }
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .authorizedAlways:
                    return true
                case .authorizedWhenInUse:
                    return true    
                default:
                    return false
                }
            }
        
        location = locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .flatMap {
                return $0.last.map(Driver.just) ?? Driver.empty()
            }
            .map { $0.coordinate }
        
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}
