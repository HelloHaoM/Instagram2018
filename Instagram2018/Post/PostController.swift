//
//  PostController.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import Foundation
import UIKit
import YPImagePicker
import AVFoundation
import AVKit
import Photos

class PostController: UIViewController {
    
    var selectedItems = [YPMediaItem]()
    
    let selectedImageV = UIImageView()
    let pickButton = UIButton()
    let resultsButton = UIButton()
    let sharePhotoController = SharePhotoController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPicker()
    }
    
    // MARK: - Configuration
    @objc
    func showPicker() {
        
        var config = YPImagePickerConfiguration()
        
        config.library.onlySquare = true
        config.library.mediaType = .photo
        config.shouldSaveNewPicturesToAlbum = false
        config.video.compression = AVAssetExportPresetMediumQuality
        config.startOnScreen = .library
        config.video.libraryTimeLimit = 500.0
        config.showsCrop = .rectangle(ratio: (1/1))
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
        config.library.maxNumberOfItems = 5
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                picker.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("💀🧀 \($0)") }
            
            self.selectedItems = items
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    self.selectedImageV.image = photo.image
                    picker.dismiss(animated: true, completion: nil)
                case .video(let video):
                    self.selectedImageV.image = video.thumbnail
                    
                    let assetURL = video.url
                    let playerVC = AVPlayerViewController()
                    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
                    playerVC.player = player
                    
                    picker.dismiss(animated: true, completion: { [weak self] in
                        self?.present(playerVC, animated: true, completion: nil)
                    })
                }
            }
            self.sharePhotoController.selectedImage = self.selectedImageV.image
            self.navigationController?.pushViewController(self.sharePhotoController,
                                                          animated: true)
        }
        present(picker, animated: true, completion: nil)
    }
}

