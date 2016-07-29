//
//  SubmitReportViewController.swift
//  Potholes
//
//  Created by Girish Chaudhari on 11/5/15.
//  Copyright © 2015 Girish Chaudhari. All rights reserved.
//  Red ID : 817375241
//

import UIKit
import MediaPlayer
import MobileCoreServices
import CoreLocation
import Alamofire

class SubmitReportViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate ,UITextViewDelegate{
    
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var potImageView: UIImageView!
    @IBOutlet weak var topUploadButton: UIButton!
    
    let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    private let placeholder:String = "Please enter pothole description."
    
    let locationManager:CLLocationManager = CLLocationManager()
    let POST_REPORT_URL = "http://bismarck.sdsu.edu/city/report"
    private let CHAR_LIMIT:Int = 300
    private let report_type:String = "street"
    
    private var latitude:Double = 0.0;
    private var longitude:Double = 0.0;
    private let userId:String = "GC_243"
    private let imagetype:String = "png"
    private var descriptionText:String = ""
    
    
    @IBAction func capturePhoto(sender: UIButton) {
        uploadButton.hidden = true
        showPhotoPickerOptions()
    }
    
    @IBAction func submitReport(sender: UIButton) {
        
        Util.showSpinner(activitySpinner,forView:self)
        self.view.userInteractionEnabled = false
        
        guard let parameters = getAllRequiredParamteres() else{
            self.view.userInteractionEnabled = true
            return
        }
        
        let URL = NSURL(string:POST_REPORT_URL )
        if(Util.isConnectedToNetwork()){
            Alamofire.request(.POST, URL!, parameters:parameters,encoding: .JSON).responseJSON {response in
                switch response.result {
                case .Success:
                    Util.stopSpinner(self.activitySpinner)
                    self.view.userInteractionEnabled = true
                    self.resetView()
                    Util.showAlertView("Success", message: "Report successfully submitted.",view: self)
                case .Failure(_):
                    Util.stopSpinner(self.activitySpinner)
                    self.view.userInteractionEnabled = true
                    Util.showAlertView("Error", message: " \tError in report submission\t\tplease try again.",view: self)
                }
            }
        }else{
            Util.stopSpinner(self.activitySpinner)
            self.view.userInteractionEnabled = true
            Util.showAlertView("No Internet Connection", message: "Make sure your device is connected to internet.", view: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPreConfigSettings()
    }
    
    
    func getAllRequiredParamteres()-> [String:AnyObject]? {
        
        var parameters:[String:AnyObject]?
        let description = descriptionTextView.text
        
        guard !isEmpty(description) else {
            Util.showAlertView("Missing Description", message: "Please describe pothole in short.",view:self)
            Util.stopSpinner(activitySpinner)
            return parameters
        }
        
        
        guard let encodedImage = getBase64EncodedImage() else{
            
            parameters = [
                "type":report_type,
                "latitude":latitude,
                "longitude":longitude,
                "user":userId,
                "imagetype":"none",
                "description":description
            ]
            
            return parameters
        }
        
        parameters = [
            "type":report_type,
            "latitude":latitude,
            "longitude":longitude,
            "user":userId,
            "imagetype":imagetype,
            "description":description,
            "image":encodedImage
        ]
        
        return parameters
        
    }
    
    
    func isEmpty (description:String)->Bool{
        let desc = description.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return (desc.isEmpty) || (desc == placeholder)
    }
    
    
    private func showPhotoPickerOptions() {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
        settingsActionSheet.addAction(UIAlertAction(title:"Camera", style:UIAlertActionStyle.Default, handler:{ action in
            self.pickMediaFromSource(UIImagePickerControllerSourceType.Camera)
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Photo Library", style:UIAlertActionStyle.Default, handler:{ action in
            self.pickMediaFromSource(UIImagePickerControllerSourceType.PhotoLibrary)
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Cancel", style:UIAlertActionStyle.Cancel, handler:{ action in
            self.actionCancelled()}))
        presentViewController(settingsActionSheet, animated:true, completion:nil)
    }
    
    func actionCancelled(){
        if(potImageView.image == nil){
            uploadButton.hidden = false
        }
    }
    
    
    func pickMediaFromSource(sourceType:UIImagePickerControllerSourceType) {
        let mediaTypes: [String]? =
        UIImagePickerController.availableMediaTypesForSourceType(sourceType)
        
        guard mediaTypes != nil && mediaTypes?.count > 0 else {return}
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let picker = UIImagePickerController()
            picker.mediaTypes = [kUTTypeImage as String]
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = sourceType
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo editingInfo: [String : AnyObject]) {
            
            let mediaType = editingInfo[UIImagePickerControllerMediaType] as! String
            guard mediaType == kUTTypeImage as String else { return }
            if let image = editingInfo[UIImagePickerControllerEditedImage] as? UIImage {
                potImageView.image = image
            }
            
            picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion:nil)
        if(potImageView.image == nil){
            uploadButton.hidden = false
        }
    }
    
    func getBase64EncodedImage()->String?{
        guard let image = potImageView.image else{
            return nil
        }
        let imageData = UIImagePNGRepresentation(image)
        let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
        return base64String
    }
    
    func setPreConfigSettings () {
        
        self.title = "Submit Report"
        
        potImageView.layer.borderWidth = 1
        potImageView.layer.cornerRadius = 5
        potImageView.layer.borderColor = (UIColor.grayColor()).CGColor
        
        descriptionTextView.layer.borderColor = (UIColor.grayColor()).CGColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 5
        
        locationManager.delegate = self
        descriptionTextView.delegate = self
        
        descriptionTextView.text = placeholder
        descriptionTextView.textColor = UIColor.lightGrayColor()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            switch status {
            case .Authorized, .AuthorizedWhenInUse:
                locationManager.startUpdatingLocation()
                
            default:
                locationManager.stopUpdatingLocation()
            }
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        Util.showAlertView("Location Error", message: "Error in getting location",view:self)
    }
    
    
    func locationManager(manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                
                let horizontalAccuracy = location.horizontalAccuracy
                
                if horizontalAccuracy < 40 {
                    locationManager.stopUpdatingLocation()
                }
            }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return textView.text.characters.count + (text.characters.count - range.length) <= CHAR_LIMIT;
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func hideKeyboard() {
        view.getFirstResponder()?.resignFirstResponder()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        hideKeyboard()
    }
    
    func resetView(){
        self.potImageView.image = nil
        self.descriptionTextView.text = self.placeholder
        self.descriptionTextView.textColor = UIColor.lightGrayColor()
        self.uploadButton.hidden = false
    }
    
    
}
