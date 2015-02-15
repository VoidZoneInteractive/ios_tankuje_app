//
//  MainViewController.swift
//  ios_tankuje_app
//
//  Created by Grzegorz Gurzeda on 03.02.2015.
//  Copyright (c) 2015 Grzegorz Gurzeda. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate,NSURLSessionDelegate,
NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate {
    // Interface Builder Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var navitem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var navigationMenuButton: UIBarButtonItem!
    
    @IBOutlet weak var addressLine1: UILabel!
    @IBOutlet weak var addressLine2: UILabel!
    @IBOutlet weak var oilstationImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SETUP SESSION
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        self.session = session
        
        // HIDE BOTTOM INFO BOX
        self.bottomViewHeight.constant = 0
        
        
        
        // GOOGLE MAPS DELEGATE
        mapView.delegate = self
        
        // LOCATION MANAGER DELEGATE
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // INSTANTIATE MAP
        self.map = Map(mapView: mapView)
        self.map.fetchMarkers(session)
        
        // SET LOGO TO NAVIGATION BAR
        let logo = UIImage(named: "logo.png")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.frame.size.height = 40
        navitem.titleView = imageView
        
        // SET LOGO TO MENU BUTTON
        let menuButtonImage = self.map.scaleImage(UIImage(named: "burger-menu.png")!, size: CGSizeMake(21, 21))
        menuButton.setImage(menuButtonImage, forState: UIControlState.Normal)
        
        
        // SEMI TRANSPARENT NAV
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        navBar.translucent = true
    }
    
    var realTotalBytesString:NSString = ""
    
    func URLSession(session: NSURLSession,
        downloadTask: NSURLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64){
            let response = downloadTask.response as NSHTTPURLResponse
            self.realTotalBytesString = response.allHeaderFields["Tankuje-Len"] as NSString
            
            dispatch_async(dispatch_get_main_queue()) {
                self.progress.setProgress(Float(Double(totalBytesWritten) / Double(self.realTotalBytesString.intValue)), animated: true)
            }
            
//            print(totalBytesWritten)
//            print(" - ")
//            print(self.realTotalBytesString.intValue)
//            print(" - ")
//            println(self.progress.progress)
    }
    
    func URLSession(session: NSURLSession,
        downloadTask: NSURLSessionDownloadTask,
        didFinishDownloadingToURL location: NSURL){

            // Hide progress view
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                        self.progress.alpha = 0
                    }, completion: { finished in
                })
            }
            let data = NSData(contentsOfURL: location)
            var result = NSString(data: data!, encoding:
                NSASCIIStringEncoding)!
            let jsonData = result.dataUsingEncoding(NSUTF8StringEncoding)
            
            let json = JSON(data: jsonData!)
            
//            dispatch_async(dispatch_get_main_queue()) {
                for (key: String, subJson: JSON) in json {
                    self.map.addMarker(subJson)
                }
//            }
            //println("Finished writing the downloaded content to URL = \(location)")
    }
    
    /* We now get to know that the download procedure was finished */
    func URLSession(session: NSURLSession, task: NSURLSessionTask!,
        didCompleteWithError error: NSError!){
            
            print("Finished ")
            
            if error == nil{
                println("without an error")
            } else {
                println("with an error = \(error)")
            }
            
            /* Release the delegate */
            session.finishTasksAndInvalidate()
            
    }
    
    var session: NSURLSession!
    var map: Map!
    
    let locationManager = CLLocationManager()
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        println(marker.userData)
        self.reverseGeocodeCoordinate(marker)

        return false
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            
        }
    }
    
    func reverseGeocodeCoordinate(marker: GMSMarker) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(marker.position) { response , error in
            if let address = response?.firstResult() {
                
                let lines = address.lines as [String]
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.addressLine1.text = lines[0]
                    self.addressLine2.text = lines[1]
                    
                    var newHeight = CGFloat(96)
                    
                    self.oilstationImage.contentMode = UIViewContentMode.ScaleAspectFit
                    self.oilstationImage.image = UIImage(named: marker.userData as String + ".png")
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