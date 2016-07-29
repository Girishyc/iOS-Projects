//
//  ListReportsViewController.swift
//  Potholes
//
//  Created by Girish Chaudhari on 11/7/15.
//  Copyright © 2015 Girish Chaudhari. All rights reserved.
//  Red ID : 817375241
//

import UIKit
import Alamofire

class ListReportsViewController: UITableViewController {
    
    var reports = [Report]()
    let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    let URL = "http://bismarck.sdsu.edu/city/fromDate"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "List Reports"
        fetchAllReports()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reports.count
    }
    
    private struct Storyboard{
        static let cellReuseIdentifier = "Report"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellReuseIdentifier, forIndexPath:indexPath)
        let report = reports[indexPath.row]
        
        cell.textLabel?.text  = report.description.isEmpty ? "No Description Avaialble":report.description
        cell.detailTextLabel?.text = report.createdOn
        
        return cell
    }
    
    
    func fetchAllReports(){
        if(Util.isConnectedToNetwork()){
            
            let parameters = ["type" : "street"]
            
            Util.showSpinner(activitySpinner,forView:self)
            Alamofire.request(.GET, URL, parameters: parameters)
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        Util.stopSpinner(self.activitySpinner)
                        let JSON:NSArray = response.result.value as! NSArray
                        self.processFromDate(JSON)
                    case .Failure(_):
                        Util.stopSpinner(self.activitySpinner)
                        Util.showAlertView("Error", message:"Error in getting reports",view:self)
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
            
            let id:Int = potholeReport["id"] as! Int
            let latitude:Double = potholeReport["latitude"] as! Double
            let longitude:Double = potholeReport["longitude"] as! Double
            let type:String = potholeReport["type"] as! String
            let description:String = potholeReport["description"] as! String
            let createdOn:String = potholeReport["created"] as! String
            let imagetype:String = potholeReport["imagetype"] as! String
            
            reports.append(Report(id:id, latitude: latitude, longitude: longitude, type: type, description: description, createdOn: createdOn, imagetype: imagetype))
        }
        
        tableView.reloadData()
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "detailView"){
            
            let indexPath = self.tableView.indexPathForSelectedRow
            let detailView:DetailReportViewController  = segue.destinationViewController as! DetailReportViewController
            
            detailView.potholeDesc = reports[(indexPath?.row)!].description
            detailView.imageID = reports[(indexPath?.row)!].id
            detailView.imageType = reports[(indexPath?.row)!].imagetype
            
        }
    }
    
    
    
    
}

