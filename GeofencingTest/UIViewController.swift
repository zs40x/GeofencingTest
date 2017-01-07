//
//  UIViewController.swift
//  GeofencingTest
//
//  Created by Stefan Mehnert on 07/01/2017.
//  Copyright © 2017 Stefan Mehnert. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlertDialog(title: String?, errorMessage: String) {
        
        let alertController =
            UIAlertController(
                title: title ?? "Geofencing",
                message: errorMessage,
                preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
