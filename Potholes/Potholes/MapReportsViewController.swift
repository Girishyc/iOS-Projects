//
//  MapReportsViewController.swift
//  Potholes
//
//  Created by Girish Chaudhari on 11/5/15.
//  Copyright © 2015 Girish Chaudhari. All rights reserved.
//  Red ID : 817375241
//

import UIKit
import Alamofire
import MapKit


class MapReportsViewController: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var potholes = [Pothole]()
    
    let locationManager = CLLocationManager()
    let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    let URL = "http://bismarck.sdsu.edu/city/fromDate"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Map Reports"
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView!.showsUserLocation = true
        
        loadInitialData()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        Util.showAlertView("Location Error", message: "Error in getting location",view:self)
    }
    
    
    func sanDiegoCountyLocation()-> MKCoordinateRegion {
        let center = CLLocationCoordinate2DMake(32.76572795, -117.07319880 )
        let widthMeters:CLLocationDistance = 100
        let heightMeters:CLLocationDistance = 1000*120
        return MKCoordinateRegionMakeWithDistance(center, widthMeters, heightMeters)
    }
    
    
    func loadInitialData(){
        if(Util.isConnectedToNetwork()){
            Util.showSpinner(activitySpinner, forView: self)
            let parameters = ["type" : "street"]
            Alamofire.request(.GET, URL, parameters: parameters)
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        let JSON:NSArray = response.result.value as! NSArray
                        self.processFromDate(JSON)
                        Util.stopSpinner(self.activitySpinner)
                    case .Failure(let error):
                        Util.stopSpinner(self.activitySpinner)
                        Util.showAlertView("Error", message:error.description,view:self)
                    }
            }
        }else{
            Util.showAlertView("No Internet Connection", message: "Make sure your device is connected to internet", view: self)
        }
        
    }
    
    func processFromDate(data:NSArray) {
        
        for index in 0...data.count-1{
            
            let report : AnyObject? = data[index]
            let potholeReport = report! as! Dictionary<String, AnyObject>
            
            let latitude:Double = potholeReport["latitude"] as! Double
            let longitude:Double = potholeReport["longitude"] as! Double
            let description:String = potholeReport["description"] as! String
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let pothole = Pothole(title: description, coordinate: coordinate, subtitle: "Pothole")
            potholes.append(pothole)
        }
        
        mapView.addAnnotations(potholes)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Pothole {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                
            }
            return view
        }
        return nil
    }
    @IBAction func changeMapType(control: UISegmentedControl) {
     
        if control.selectedSegmentIndex == 0{
            mapView.mapType = MKMapType.Standard
        }else if control.selectedSegmentIndex == 1{
            mapView.mapType = MKMapType.Hybrid
        }else{
            mapView.mapType = MKMapType.Satellite
        }
        
    }

}
