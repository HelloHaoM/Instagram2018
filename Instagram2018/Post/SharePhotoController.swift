//
//  SharePhotoController.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SharePhotoController: UIViewController, CLLocationManagerDelegate {
    //set location manager
    var locationManager = CLLocationManager()
    
    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
        }
    }
    
    let padding: CGFloat = 12
    //set globle variable: the address of the user
    var userAddress = ""
    //store the user location information as coordinates
    var coordinates: Array<Double> = Array(repeating: 0, count: 2)
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let textView: PlaceholderTextView = {
        let tv = PlaceholderTextView()
        tv.placeholderLabel.text = "Add a caption..."
        tv.placeholderLabel.font = UIFont.systemFont(ofSize: 14)
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.autocorrectionType = .no
        return tv
    }()
    
    private let addLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Location", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleAddLocation), for: .touchUpInside)
        return button
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .gray
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        layoutViews()
    }
    
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    private func layoutViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, height: 100)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, width: 84)
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingLeft: 4)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.addSubview(separatorView)
        separatorView.anchor(top: containerView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, height: 0.5)
        
        let locationView = UIView()
        locationView.backgroundColor = .white
        view.addSubview(locationView)
        
        locationView.anchor(top: separatorView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, height: 70)
        
        locationView.addSubview(addLocationButton)
        addLocationButton.anchor(top: locationView.topAnchor, left: locationView.leftAnchor, paddingLeft: padding)
        
        view.addSubview(locationLabel)
        locationLabel.anchor(top: addLocationButton.bottomAnchor, left: locationView.leftAnchor, paddingTop: padding, paddingLeft: padding)
    }
    
    @objc private func handleShare() {
        guard let postImage = selectedImage else { return }
        guard let caption = textView.text else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        textView.isUserInteractionEnabled = false
        //create a new post when clicking "share", send image, caption, address and location information
        Database.database().createPost(withImage: postImage, caption: caption, address: self.userAddress, location: self.coordinates) { (err) in
            if err != nil {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.textView.isUserInteractionEnabled = true
                return
            }
            //after post, update home page feeds and user profile page feeds
            NotificationCenter.default.post(name: NSNotification.Name.updateHomeFeed, object: nil)
            NotificationCenter.default.post(name: NSNotification.Name.updateUserProfileFeed, object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleAddLocation() {
        
        // Ask for Authorisation from the User
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        //store coordinates information
        self.coordinates[0] = locValue.latitude
        self.coordinates[1] = locValue.longitude
        let userLocation = locations.last
        
        let geocoder = CLGeocoder()
        
        //based on the coordinates information, show its address
        geocoder.reverseGeocodeLocation(userLocation!,
                                        completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                let firstLocation = placemarks?[0]
                                                let address = firstLocation?.compactAddress
                                                self.locationLabel.text = address
                                                self.userAddress = address ?? ""
                                            }
                                            else {
                                                // An error occurred during geocoding.
                                                self.locationLabel.text = "cannot get location information"
                                            }
        })
    }
}

//customize the format of address information
extension CLPlacemark {
    
    var compactAddress: String? {
        if let name = name {
            var result = name
            
            if let city = locality {
                result += ", \(city)"
            }
            
            if let country = country {
                result += ", \(country)"
            }
            
            return result
        }
        
        return nil
    }
    
}





