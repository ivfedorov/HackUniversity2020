//
//  ARPresenter.swift
//  HackAR
//
//  Created by viktor.volkov on 21.03.2020.
//  Copyright © 2020 viktor.volkov. All rights reserved.
//

import Foundation
import CoreLocation
import ARKit

protocol ARViewControllerInput: AnyObject {
    
    var output: ARViewControllerOutput? { get set }
    
    func showNode(_ node: SCNNode)
    func updateDistance(_ value: Int)
}

class ARPresenter: NSObject {
    
    weak var view: ARViewControllerInput?
    
    private let service = MapService()
    
    private let somePointMock = CLLocation(latitude: 59.929631,
                                           longitude: 30.305279)
    
    private var userNode: SCNNode?
    
    private lazy var locationManager: LocationManager = {
        let manager = LocationManager()
        manager.delegate = self
        return manager
    }()
    
}

extension ARPresenter: ARViewControllerOutput {
    
    func viewDidLoad() {
        locationManager.startScanning()
        service.loadPolygons {
            result in
            
            if case .success(let polygons) = result {
                print(polygons)
            }
        }
    }
}

extension ARPresenter: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            print(location)
            let distance = location.distance(from: somePointMock)
            view?.updateDistance(Int(distance))
            let node: SCNNode
            if let userNode = userNode {
                node = userNode
            } else {
                node = SceneCreator.createNode()
                userNode = node
            }
            node.updatePosition(location, somePointMock)
            view?.showNode(node)
        }
    }
}
