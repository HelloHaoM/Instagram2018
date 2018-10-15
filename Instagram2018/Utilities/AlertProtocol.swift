//
//  AlertProtocol.swift
//  Instagram2018
//
//  Created by wry on 2018/10/9.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit

protocol AlertProtocol {}

extension AlertProtocol where Self: UIViewController {
    
    /// create a new alert
    ///
    /// - Parameters:
    ///   - title: the title of the alert
    ///   - msg: the msg of the alert
    func createAlertWithMsgAndTitle(_ title: String, msg: String) {
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Accept", style: .cancel, handler: { (alert) -> Void in
            alertController.removeFromParent()
        }))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
}

