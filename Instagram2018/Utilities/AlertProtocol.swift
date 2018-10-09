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
    
    func createAlertWithMsgAndTitle(_ title: String, msg: String) {
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Accept", style: .cancel, handler: { (alert) -> Void in
            alertController.removeFromParent()
        }))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
}

