//
//  MapViewController.swift
//  Ling Land Info
//
//  Created by Potchara Puttawanchai on 26/4/2561 BE.
//  Copyright © 2561 Potchara Puttawanchai. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    // MARK: - Variables : Received
    
    var plan: Plan!
    
    // MARK: - Variables : Storyboard UI

    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Constants
    
    let defaultZoom: Float = 16.0
    
    // MARK: - Functions : Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Generate plan
        generatePlanOnMap()
    }

    // MARK: - Functions
    
    func generatePlanOnMap() {
        if self.plan.coordinatesArray.count >= 3 {
            self.mapView.camera = GMSCameraPosition.camera(withTarget: self.plan.polygonCentroidCoordinate, zoom: self.defaultZoom)
        }
        else if self.plan.coordinatesArray.count > 0 {
            self.mapView.camera = GMSCameraPosition.camera(withTarget: self.plan.coordinatesArray[0], zoom: self.defaultZoom)
        }
        self.mapView.mapType = .satellite
        self.plan.addToMapView(self.mapView)
    }
    
}
