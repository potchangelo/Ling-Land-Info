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
            let coord0 = self.coordinatesArray[i]
            var coord1: CLLocationCoordinate2D!
            if i == self.coordinatesArray.count - 1 {
                coord1 = self.coordinatesArray[0]
            }
            else {
                coord1 = self.coordinatesArray[i+1]
            }
            sigma += ( coord0.latitude * coord1.longitude ) - ( coord1.latitude * coord0.longitude )
        }
        return sigma/2
    }
    
    var polygonCentroidCoord: CLLocationCoordinate2D {
        let area = self.polygonArea
        var sigmaCx: Double = 0, sigmaCy: Double = 0
        for i in 0 ..< self.coordinatesArray.count {
            let coord0 = self.coordinatesArray[i]
            var coord1: CLLocationCoordinate2D!
            if i == self.coordinatesArray.count - 1 {
                coord1 = self.coordinatesArray[0]
            }
            else {
                coord1 = self.coordinatesArray[i+1]
            }
            let backPart = ( coord0.latitude * coord1.longitude - coord1.latitude * coord0.longitude )
            sigmaCx += ( coord0.latitude + coord1.latitude ) * backPart
            sigmaCy += ( coord0.longitude + coord1.longitude ) * backPart
        }
        let cx = sigmaCx / ( 6 * area ), cy = sigmaCy / ( 6 * area )
        return CLLocationCoordinate2DMake(cx, cy)
    }
    
    // MARK: -- UTM latitudinal zone
    
    var utmLatZone: Character {
        let zoneChars = "CDEFGHJKLMNPQRSTUVWX"
        let latitude = self.polygonCentroidCoord.latitude
        
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
        for coord in self.coordinatesArray {
            polygonPath.add(coord)
            let marker = GMSMarker(position: coord)
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
        // Only if coordinates count >= 3
        if self.coordinatesArray.count >= 3 {
            let polygonCentroidMarker = GMSMarker(position: self.polygonCentroidCoord)
            let latLonCoordinate = LatLonCoordinate(latiudinalDegrees: self.polygonCentroidCoord.latitude, longitudinalDegrees: self.polygonCentroidCoord.longitude)
            let utmPoint = UTMConverter(datum: .wgs84).utmCoordinatesFrom(coordinates: latLonCoordinate)
            let longZone = utmPoint.zone
            let easting = String(format: "%.2f", utmPoint.easting)
            let northing = String(format: "%.2f", utmPoint.northing)
            polygonCentroidMarker.title = "\(longZone)\(self.utmLatZone), \(easting)E, \(northing)N"
            polygonCentroidMarker.map = mapView
            mapView.selectedMarker = polygonCentroidMarker
        }
    }
    
    func addCoordinate(_ coord: CLLocationCoordinate2D) {
        self.coordinatesArray.append(coord)
    }
    
}
