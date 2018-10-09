//
//  MultiPeerUtilities.swift
//  Instagram2018
//
//  Created by wry on 2018/10/9.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import Foundation
import UIKit

class MultiPeerUtilties {
    static var senderNames = [String]()
    static var senderImages = [UIImage]()
    
    static func appendData(name: String? = nil, image: UIImage? = nil){
        if let name = name {
            MultiPeerUtilties.senderNames.append(name)
        }
        
        if let image = image {
            MultiPeerUtilties.senderImages.append(image)
        }
    }
}

