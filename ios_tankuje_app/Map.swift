//
//  Map.swift
//  ios_tankuje_app
//
//  Created by Grzegorz Gurzeda on 01.02.2015.
//  Copyright (c) 2015 Grzegorz Gurzeda. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// http://tankuje.com/webservice

class Map {
    
    var mapView:GMSMapView
    var appDelegate:AppDelegate
    var managedContext:NSManagedObjectContext
    
    init(mapView:GMSMapView) {
        
        // Managed content
        self.appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        self.managedContext = self.appDelegate.managedObjectContext!
        
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
    
    func fetchMarkers(session: NSURLSession) {
        
//        let store = NSPersistentStore()
//        let storeURL = store.URL
//        
//        let storeCoordinator = NSPersistentStoreCoordinator()
//        var error: NSError?
//        storeCoordinator.removePersistentStore(store, error: &error)
//        
//        let fileManager = NSFileManager()
//        fileManager.removeItemAtURL(storeURL!, error: &error)
        
        println(session.delegate)
        let url = NSURL(string: "http://tankuje.com/webservice.json")
//        NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("", forHTTPHeaderField: "Accept-Encoding")
        
        let task = session.downloadTaskWithRequest(request)
        
        task.resume()
    }
    
//    var icon: UIImage
    
    func addMarker(json: JSON) {
        // ["lat"].double!, lng: subJson["lng"].double!, company_id: subJson["company_id"].string!
        var marker = GMSMarker()
        
        marker.icon = self.fetchIconFromUrlOrCoreData(json["price_type"].string!, newness: json["newness"].string!, price: json["price"].string!)
        
        marker.position = CLLocationCoordinate2DMake(json["lat"].double!, json["lng"].double!)
        marker.userData = json["company_id"].string!
//        marker.icon = self.icon
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
        marker.map = self.mapView
    }
    
    var icons = [String: UIImage]()
    var iconKey = ""
    
    func fetchIconFromUrlOrCoreData(priceType: String, newness: String, price: String) -> UIImage {
        
        var icon = UIImage()
        iconKey = priceType + newness + price
        
        if (icons[iconKey] == nil) {
            
            let fetchRequest = NSFetchRequest(entityName:"Markers")

            // Create a new predicate that filters out any object that
            let newnessPredicate = NSPredicate(format: "newness == %@", newness)
            let priceTypePredicate = NSPredicate(format: "price_type == %@", priceType)
            let pricePredicate = NSPredicate(format: "price == %@", price)

            // Combine the three predicates above in to one compound predicate
            let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [newnessPredicate!, pricePredicate!, priceTypePredicate!])
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
            
            var error: NSError?
            
            let count = self.managedContext.countForFetchRequest(fetchRequest, error: &error)
            
            println(count)
            
            if (count > 0) {
                
                let fetchedResults = self.managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
                
                icon = UIImage(data: fetchedResults?.first?.valueForKey("image") as NSData)!
                icon = self.scaleImage(icon, size: CGSizeMake(50, 50))
                icons[iconKey] = icon
            } else {
                
                
                let url = NSURL(string: "http://tankuje.com/assets/marker?price=" + price + "&price_type=" + priceType + "&newness=" + newness + "&output=png")
                let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                
                icon = UIImage(data: data!)!
                
                icon = self.scaleImage(icon, size: CGSizeMake(50, 50))
                
                
                let entity = NSEntityDescription.entityForName("Markers", inManagedObjectContext: managedContext)
                
                let marker = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
                
                marker.setValue(data, forKey: "image")
                marker.setValue(newness, forKey: "newness")
                marker.setValue(price, forKey: "price")
                marker.setValue(priceType, forKey: "price_type")
                marker.setValue(NSDate(timeIntervalSinceNow: 0), forKey: "created_at")
                
                var error: NSError?
                if !managedContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
                
                icons[iconKey] = icon
            }
        } else {
            icon = icons[iconKey]!
        }
        
        return icon
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