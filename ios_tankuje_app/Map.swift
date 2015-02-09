//
//  Map.swift
//  ios_tankuje_app
//
//  Created by Grzegorz Gurzeda on 01.02.2015.
//  Copyright (c) 2015 Grzegorz Gurzeda. All rights reserved.
//

import Foundation
import UIKit

// http://tankuje.com/webservice

class Map {
    
    var mapView:GMSMapView
    
    init(mapView:GMSMapView) {
        self.mapView = mapView
        self.mapView.myLocationEnabled = true
        var camera = GMSCameraPosition.cameraWithLatitude(52.413212,
            longitude: 16.903423, zoom: 14)
        
        self.mapView.moveCamera(GMSCameraUpdate.setCamera(camera))
    }
    
//    convenience init() {
//        var camera = GMSCameraPosition.cameraWithLatitude(52.413212,
//            longitude: 16.903423, zoom: 14)
//        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
//        self.init(mapHolder:mapView)
//    }
    
    func initialize() {
        var camera = GMSCameraPosition.cameraWithLatitude(52.413212,
            longitude: 16.903423, zoom: 14)
        
        self.mapView.moveCamera(GMSCameraUpdate.setCamera(camera))
    }
    
    func fetchMarkers() {
        let url = NSURL(string: "http://tankuje.com/webservice")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) -> Void in
            if error == nil {
                var result = NSString(data: data, encoding:
                    NSASCIIStringEncoding)!
                let jsonData = result.dataUsingEncoding(NSUTF8StringEncoding)
                
                let json = JSON(data: jsonData!)
                
                for (key: String, subJson: JSON) in json {
//                    println(subJson["lat"])
                    self.addMarker(subJson["lat"].double!, lng: subJson["lng"].double!)
                }
            }
        }
        
        task.resume()
    }
    
    func addMarker(lat: Double, lng: Double) {
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(lat, lng)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
        marker.map = self.mapView
//        if let mylocation = self.mapHolder.myLocation {
//            NSLog("User's location: %@", mylocation)
//        } else {
//            NSLog("User's location is unknown")
//        }
    }
}