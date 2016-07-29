//
//  Pothole.swift
//  Potholes
//
//  Created by Girish Chaudhari on 11/9/15.
//  Copyright © 2015 Girish Chaudhari. All rights reserved.
//  Red ID : 817375241
//

import MapKit

class Pothole: NSObject, MKAnnotation  {

    let title:String?
    let subtitle:String?
    let coordinate: CLLocationCoordinate2D
    
    init(title:String,coordinate:CLLocationCoordinate2D,subtitle:String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
    
}