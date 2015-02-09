//
//  MainViewController.swift
//  ios_tankuje_app
//
//  Created by Grzegorz Gurzeda on 03.02.2015.
//  Copyright (c) 2015 Grzegorz Gurzeda. All rights reserved.
//

import Foundation

class MainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var navitem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addressLine1: UILabel!
    @IBOutlet weak var addressLine2: UILabel!
    @IBOutlet weak var oilstationImage: UIImageView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bottomViewHeight.constant = 0
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let map = Map(mapView: mapView)
        map.fetchMarkers()
        
        self.mapView.padding = UIEdgeInsets(top: navBar.frame.height, left: 0, bottom: bottomView.frame.height, right: 0)
        
        let logo = UIImage(named: "logo.png")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.frame.size.height = 40
        navitem.titleView = imageView
        
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        navBar.translucent = true
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        self.reverseGeocodeCoordinate(marker.position)

        return false
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            
        }
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            if let address = response?.firstResult() {
                
                let lines = address.lines as [String]
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.addressLine1.text = lines[0]
                    self.addressLine2.text = lines[1]
                    
                    var newHeight = CGFloat(96)
                    
                    self.oilstationImage.contentMode = UIViewContentMode.ScaleAspectFit
                    self.oilstationImage.image = UIImage(named: "orlen.png")
//                    self.oilstationImage.alpha = 0.5
                    
                    self.bottomViewHeight.constant = newHeight
                    
                    self.bottomView.layoutIfNeeded()
                    
                    
                    self.mapView.padding = UIEdgeInsets(top: self.navBar.frame.height, left: 0, bottom: newHeight, right: 0)
                    
                    }, completion: { finished in
//                        println(self.addressLine.text)
                })
            }
        }
    }
}