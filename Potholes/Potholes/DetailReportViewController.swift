//
//  DetailReportViewController.swift
//  Potholes
//
//  Created by Girish Chaudhari on 11/7/15.
//  Copyright © 2015 Girish Chaudhari. All rights reserved.
//  Red ID : 817375241
//

import UIKit
import Alamofire

class DetailReportViewController: UIViewController {
    
    
    @IBOutlet weak var potHoleImage: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    
    let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    let IMAGE_URL = "http://bismarck.sdsu.edu/city/image"
    
    var potholeDesc: String = ""
    var imageID:Int = 0
    var imageType = ""
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Report"
        
        potHoleImage.layer.borderWidth = 1
        potHoleImage.layer.cornerRadius = 5
        potHoleImage.layer.borderColor = (UIColor.grayColor()).CGColor
        
        descriptionText.layer.borderColor = (UIColor.grayColor()).CGColor
        descriptionText.layer.borderWidth = 1
        descriptionText.layer.cornerRadius = 5
        
        descriptionText.text = potholeDesc
        
        fetchImageFromServer(imageID,imamgeType:imageType )
    }
    
    
    func fetchImageFromServer(imageID:Int , imamgeType:String){
        if(Util.isConnectedToNetwork()){
            Util.showSpinner(activitySpinner,forView:self)
            let parameter = ["id" :imageID]
            Alamofire.request(.GET, IMAGE_URL,parameters:parameter,headers:["Content-Type":"image/\(imamgeType)"])
                .responseData { (responseData) -> Void in
                    switch responseData.result {
                    case .Success:
                        Util.stopSpinner(self.activitySpinner)
                        self.downloadImage(responseData.result.value)
                    case .Failure(let error):
                        Util.stopSpinner(self.activitySpinner)
                        Util.showAlertView("Error", message:error.description,view: self)
                    }
                    
            }
        }else{
            Util.showAlertView("No Internet Connection", message: "Make sure your device is connected to internet", view: self)
        }
    }
    
    
    func downloadImage(data:NSData?) -> Void {
        if data != nil {
            if let image = UIImage.init(data: data! ) {
                self.performSelectorOnMainThread("setImage:", withObject: image,
                    waitUntilDone: false)
            }else{
                potHoleImage.image = UIImage(named: "image_not_found.png")
            }
            
        }
    }
    
    func setImage(image: NSObject) {
        let realImage = image as! UIImage
        potHoleImage.image = realImage
    }
    
}
