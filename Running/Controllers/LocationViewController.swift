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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var walkLabel: UILabel!
    @IBOutlet weak var slowLabel: UILabel!
    @IBOutlet weak var easyLabel: UILabel!
    @IBOutlet weak var hardLabel: UILabel!
    
    var allLocations: [([CLLocation],Speed)] = []
    var walkSpeed: Double { return averageSpeed(loc: locationsForSpeed(speed: .walk)) }
    var slowSpeed: Double { return averageSpeed(loc: locationsForSpeed(speed: .slow)) }
    var easySpeed: Double { return averageSpeed(loc: locationsForSpeed(speed: .easy)) }
    var hardSpeed: Double { return averageSpeed(loc: locationsForSpeed(speed: .hard)) }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LocationViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        var maprect: MKMapRect = MKMapRectNull
        for (locs, s) in allLocations {
            let poly = SpeedPolyline(coordinates: locs.map {$0.coordinate}, count: locs.count)
            poly.speed = s
            mapView.add(poly)
            maprect = MKMapRectUnion(maprect, poly.boundingMapRect)
        }
        if !MKMapRectIsNull(maprect) {
            let midx = MKMapRectGetMidX(maprect)
            let midy = MKMapRectGetMidY(maprect)
            let midCoord = MKCoordinateForMapPoint(MKMapPointMake(midx, midy))
            let region = MKCoordinateRegionMakeWithDistance(midCoord, 1000, 1000)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
        }
        
        walkLabel.text = String(format: "Walk: %.2f km/h", walkSpeed*3.6)
        slowLabel.text = String(format: "Slow: %.2f km/h", slowSpeed*3.6)
        easyLabel.text = String(format: "Easy: %.2f km/h", easySpeed*3.6)
        hardLabel.text = String(format: "Hard: %.2f km/h", hardSpeed*3.6)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func locationsForSpeed(speed: Speed) -> [CLLocation] {
        return allLocations.filter{$0.1 == speed}.map{$0.0}.reduce([]){$0 + $1}
    }
    
    func averageSpeed(loc: [CLLocation]) -> Double {
        if loc.count == 0 {
            return 0
        } else {
            return (loc.reduce(0) {$0+$1.speed})/Double(loc.count)
        }

    }
}

extension LocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is SpeedPolyline{
            let lineView = MKPolylineRenderer(overlay: overlay)
            let speedOverlay = overlay as! SpeedPolyline
            lineView.strokeColor = speedOverlay.speed!.color()
            return lineView
        } else {
            return MKOverlayRenderer()
        }
    }
}
