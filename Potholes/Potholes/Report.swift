//
//  Report.swift
//  Potholes
//
//  Created by Girish Chaudhari on 11/7/15.
//  Copyright © 2015 Girish Chaudhari. All rights reserved.
//  Red ID : 817375241
//

import Foundation

class Report{
    
     var id:Int
     let latitude:Double
     let longitude:Double
     let type:String
     let description:String
     let createdOn:String
     let imagetype:String
    
    init (id:Int,latitude:Double,longitude:Double,type:String,description:String,createdOn:String,imagetype:String){
        
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.type = type
        self.description = description
        self.createdOn = createdOn
        self.imagetype = imagetype
        
    }
    
        
}