//
//  Map.swift
//  ios_tankuje_app
//
//  Created by Grzegorz Gurzeda on 01.02.2015.
//  Copyright (c) 2015 Grzegorz Gurzeda. All rights reserved.
//

import Foundation
import UIKit

class Map {
    func initialize() -> GMSMapView {
        var camera = GMSCameraPosition.cameraWithLatitude(-33.86,
            longitude: 151.20, zoom: 6)
        var mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        return mapView
    }
}