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
        
        let url = NSURL(string: "http://tankuje.com/assets/marker?value=10.01&output=png")
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        
        self.icon = UIImage(data: data!)!
//        self.icon.alignmentRectInsets.bottom = 25
        
        self.icon = self.scaleImage(self.icon, size: CGSizeMake(50, 50))
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
    
    func fetchMarkers(session: NSURLSession) {
        println(session.delegate)
        let url = NSURL(string: "http://tankuje.com/webservice")
//        NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("", forHTTPHeaderField: "Accept-Encoding")
        request.HTTPMethod = "POST"
        
        let task = session.downloadTaskWithRequest(request)
        
        task.resume()
    }
    
    var icon: UIImage
    
    func addMarker(lat: Double, lng: Double, company_id: String) {
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(lat, lng)
        marker.userData = company_id
        marker.icon = self.icon
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
        marker.map = self.mapView
    }
    
    func scaleImage(originalImage: UIImage, size:CGSize) -> UIImage {
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size)) {
        return originalImage;
    }
    
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
    
    //draw
    originalImage.drawInRect(CGRectMake(0.0, 0.0, size.width, size.height))
    
    //capture resultant image
    let image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
    }
}