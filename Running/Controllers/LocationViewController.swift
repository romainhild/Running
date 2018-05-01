//
//  LocationViewController.swift
//  Running
//
//  Created by Romain Hild on 01/05/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var allLocations: [CLLocation] = []
    var isReceivingUpdates: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getLoc(_ sender: Any) {
        if !isReceivingUpdates {
            let authStatus = CLLocationManager.authorizationStatus()
            if authStatus == .notDetermined {
                locationManager.requestAlwaysAuthorization()
                return
            }
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.activityType = .fitness
            locationManager.startUpdatingLocation()
        } else {
            isReceivingUpdates = false
            locationManager.stopUpdatingLocation()
            let lastCoord = allLocations.last!.coordinate
            var otherLocations = [lastCoord]
            for i in 1...100 {
                otherLocations.append(CLLocationCoordinate2DMake(CLLocationDegrees(lastCoord.latitude + (48.567366-lastCoord.latitude)*Double(i)/100.0), CLLocationDegrees(lastCoord.longitude + (7.767551-lastCoord.longitude)*Double(i)/100.0)))
            }
            let myPolyline = MKPolyline(coordinates: otherLocations, count: otherLocations.count)
            mapView.add(myPolyline)
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isReceivingUpdates = true
        let newLocation = locations.last!
        allLocations.append(newLocation)
        let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
        print("didUpdateLocations[\(locations.count)] \(newLocation)")
    }
}

extension LocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("render")
        if overlay is MKPolyline{
            print("polyline")
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.green
            return lineView
        } else {
            return MKOverlayRenderer()
        }
    }
}
