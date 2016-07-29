//
//  Util.swift
//  Potholes
//
//  Created by Girish Chaudhari on 11/11/15.
//  Copyright © 2015 Girish Chaudhari. All rights reserved.
//  Red ID : 817375241
//

import Foundation
import UIKit
import SystemConfiguration


// Extension added to handle KeyBoard hide event.
extension UIView {
    func getFirstResponder() ->UIView? {
        if isFirstResponder() {
            return self
        }
        for view in subviews {
            if let responder = view.getFirstResponder() {
                return responder
            }
        }
        return nil
    }
    
}

// Helper class containes helper functions such as showSpinner/stopSpinner/Connectivity check.

class Util {
    
    static func  showAlertView(title:String, message:String,view:AnyObject){
        let alert = UIAlertController(title: title, message:message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        view.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    static func isConnectedToNetwork() -> Bool {
        Reach().monitorReachabilityChanges()
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            return false
        case .Online(.WWAN):
            return true
        case .Online(.WiFi):
            return true
        }
    }
    
    static func showSpinner(activitySpinner:UIActivityIndicatorView , forView:UIViewController){
        
        activitySpinner.center = forView.view.center
        activitySpinner.hidesWhenStopped = true
        activitySpinner.color = UIColor.blackColor()
        activitySpinner.center = forView.view.center
        activitySpinner.startAnimating()
        
        forView.view.addSubview(activitySpinner)
    }
    
    
    static  func stopSpinner(activitySpinner:UIActivityIndicatorView){
        activitySpinner.stopAnimating()
    }
    
    
}

