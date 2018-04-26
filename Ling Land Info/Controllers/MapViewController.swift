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
    
    // MARK: - Variables : received
    
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
        let camera = GMSCameraPosition.camera(withTarget: self.plan.polygonCentroidCoord, zoom: self.defaultZoom)
        self.mapView.camera = camera
        self.mapView.mapType = .satellite
        self.plan.addToMapView(self.mapView)
    }
    
}
