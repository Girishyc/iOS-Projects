//
//  ViewController.swift
//  Potholes
//
//  Created by Girish Chaudhari on 11/4/15.
//  Copyright © 2015 Girish Chaudhari. All rights reserved.
//  Red ID : 817375241
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
    
     let locationManager:CLLocationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "San Diego Potholes"
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            print("Authorization status changed to \(status.rawValue)")
            switch status {
            case .Authorized, .AuthorizedWhenInUse:
                locationManager.startUpdatingLocation()
                
            default:
                locationManager.stopUpdatingLocation()
            }
    }
    
    
}

