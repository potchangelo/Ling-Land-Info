//
//  Plan.swift
//  Ling Land Info
//
//  Created by Potchara Puttawanchai on 25/4/2561 BE.
//  Copyright © 2561 Potchara Puttawanchai. All rights reserved.
//

import UIKit
import GoogleMaps
import Geotum

class Plan: NSObject {
    
    // MARK: - Variables
    
    var coordinatesArray = [CLLocationCoordinate2D]()
    
    // MARK: - Variables : Helpers
    
    // MARK: -- Polygon centroid getters
    
    var polygonArea: Double {
        var sigma: Double = 0
        for i in 0 ..< self.coordinatesArray.count {
            let coordinate0 = self.coordinatesArray[i]
            var coordinate1: CLLocationCoordinate2D!
            if i == self.coordinatesArray.count - 1 {
                coordinate1 = self.coordinatesArray[0]
            }
            else {
                coordinate1 = self.coordinatesArray[i+1]
            }
            sigma += ( coordinate0.latitude * coordinate1.longitude ) - ( coordinate1.latitude * coordinate0.longitude )
        }
        return sigma/2
    }
    
    var polygonCentroidCoordinate: CLLocationCoordinate2D {
        let area = self.polygonArea
        var sigmaCenterX: Double = 0, sigmaCenterY: Double = 0
        for i in 0 ..< self.coordinatesArray.count {
            let coordinate0 = self.coordinatesArray[i]
            var coordinate1: CLLocationCoordinate2D!
            if i == self.coordinatesArray.count - 1 {
                coordinate1 = self.coordinatesArray[0]
            }
            else {
                coordinate1 = self.coordinatesArray[i+1]
            }
            let backPart = ( coordinate0.latitude * coordinate1.longitude - coordinate1.latitude * coordinate0.longitude )
            sigmaCenterX += ( coordinate0.latitude + coordinate1.latitude ) * backPart
            sigmaCenterY += ( coordinate0.longitude + coordinate1.longitude ) * backPart
        }
        let centerX = sigmaCenterX / ( 6 * area ), centerY = sigmaCenterY / ( 6 * area )
        return CLLocationCoordinate2DMake(centerX, centerY)
    }
    
    // MARK: -- UTM latitudinal zone
    
    var utmLatZone: Character {
        let zoneChars = "CDEFGHJKLMNPQRSTUVWX"
        let latitude = self.polygonCentroidCoordinate.latitude
        
        // If latitude is around north or south pole, just return "Z"
        if latitude < -80 || latitude > 84 { return "Z" }
        
        // Else, Find latitudinal zone and return
        for (index, char) in zoneChars.enumerated() {
            let latZoneMin = -80.0 + ( 8.0 * Double(index) )
            let latZoneMax = latZoneMin + 8
            if latitude >= latZoneMin && latitude < latZoneMax {
                return char
            }
        }
        
        // Fallback that might be never reached
        return "-"
    }
    
    // MARK: - Constants
    
    let polygonFillColor = UIColor(red: 255.0/255.0, green: 240.0/255.0, blue: 30/255.0, alpha: 0.25)
    let polygonStrokeColor = UIColor(red: 255.0/255.0, green: 240.0/255.0, blue: 30/255.0, alpha: 0.5)
    let polygonAnchorsMarkerColor = UIColor.yellow
    
    // MARK: - Initializer
    
    override init() {}
    
    // MARK: - Functions
    
    func addToMapView(_ mapView: GMSMapView) {
        // Create polygon path & anchors markers
        let polygonPath = GMSMutablePath()
        var polygonAnchorsMarkersArray = [GMSMarker]()
        for coordinate in self.coordinatesArray {
            polygonPath.add(coordinate)
            let marker = GMSMarker(position: coordinate)
            marker.icon = GMSMarker.markerImage(with: self.polygonAnchorsMarkerColor)
            marker.opacity = 0.65
            polygonAnchorsMarkersArray.append(marker)
        }
        
        // Draw polygon
        let polygon = GMSPolygon(path: polygonPath)
        polygon.fillColor = self.polygonFillColor
        polygon.strokeColor = self.polygonStrokeColor
        polygon.strokeWidth = 2
        polygon.map = mapView
        
        // Draw polygon anchors markers
        for marker in polygonAnchorsMarkersArray {
            marker.map = mapView
        }
        
        // Draw polygon centroid marker to map
        // Only draw if coordinates count >= 3
        if self.coordinatesArray.count >= 3 {
            let polygonCentroidMarker = GMSMarker(position: self.polygonCentroidCoordinate)
            let latLonCoordinate = LatLonCoordinate(latiudinalDegrees: self.polygonCentroidCoordinate.latitude, longitudinalDegrees: self.polygonCentroidCoordinate.longitude)
            let utmPoint = UTMConverter(datum: .wgs84).utmCoordinatesFrom(coordinates: latLonCoordinate)
            let longZone = utmPoint.zone
            let easting = String(format: "%.2f", utmPoint.easting)
            let northing = String(format: "%.2f", utmPoint.northing)
            polygonCentroidMarker.title = "\(longZone)\(self.utmLatZone), \(easting)E, \(northing)N"
            polygonCentroidMarker.map = mapView
            mapView.selectedMarker = polygonCentroidMarker
        }
    }
    
    func addCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.coordinatesArray.append(coordinate)
    }
    
}
