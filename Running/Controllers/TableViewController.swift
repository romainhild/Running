//
//  TableViewController.swift
//  Running
//
//  Created by Romain Hild on 27/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class TableViewController: UITableViewController {
    var soundsId: [Speed: SystemSoundID] = [:]
    var program: Program! = nil
    var index: Int = 0
    
    var timer = Timer()
    let timeInterval = 0.1
    var counter = 0.0
    var counterFromStart: Int = 0
    var isRunning = false
    
    let locationManager = CLLocationManager()
    var allLocations: [([CLLocation],Speed)] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "runningCell")
        for speed in Speed.allValues {
            let path = Bundle.main.path(forResource: "\(speed.sound())", ofType:"m4a")!
            let url = URL(fileURLWithPath: path)
            var soundId: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url as CFURL, &soundId)
            soundsId[speed] = soundId
        }
        if program.count == 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            self.allLocations.append(([],program[0].1))
        }
        self.navigationItem.title = program.name
        
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            return
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startRunning(_ sender: Any) {
//        performSegue(withIdentifier: "locationSegue", sender: nil)
        if !isRunning {
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            playSpeed(speed: program[index].1)
            isRunning = true
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(startRunning(_:)))
            if CLLocationManager.authorizationStatus() == .authorizedAlways {
                locationManager.startUpdatingLocation()
            }
        } else {
            timer.invalidate()
            isRunning = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startRunning(_:)))
            if CLLocationManager.authorizationStatus() == .authorizedAlways {
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    @objc func updateTimer() {
        let cell0 = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        let cell1 = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        counter += timeInterval
        if counter >= Double(program[index].0) {
            counterFromStart += Int(counter)
            counter = 0.0
            if index+1 < program.count {
                playSpeed(speed: program[index+1].1)
                allLocations.append(([],program[index+1].1))
            } else {
                locationManager.stopUpdatingLocation()
                timer.invalidate()
                counter = Double(counterFromStart)
                counterFromStart = 0
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                performSegue(withIdentifier: "locationSegue", sender: nil)
            }
            index += 1
            self.tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
        cell0?.textLabel?.text = intToTime(time: self.counterFromStart)
        cell1?.textLabel?.text = doubleToTime(time: self.counter)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationSegue" {
            let locView = segue.destination as? LocationViewController
            locView?.allLocations = self.allLocations
        }
    }
    
    func playSpeed(speed: Speed) {
        AudioServicesPlaySystemSound(soundsId[speed]!)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return program.count - index + 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "runningCell", for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        cell.textLabel?.adjustsFontSizeToFitWidth = false
        cell.contentView.backgroundColor = UIColor.white
        cell.textLabel?.backgroundColor = UIColor.white
        if indexPath.row == 0 {
            cell.contentView.backgroundColor = UIColor.white
            cell.textLabel?.backgroundColor = UIColor.white
            cell.textLabel?.text = intToTime(time: counterFromStart)
        } else if indexPath.row == 1 {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 80)
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            if index < program.count {
                cell.textLabel?.backgroundColor = program[index].1.color()
                cell.contentView.backgroundColor = program[index].1.color()
            } else {
                cell.contentView.backgroundColor = UIColor.white
                cell.textLabel?.backgroundColor = UIColor.white
            }
            cell.textLabel?.text = doubleToTime(time: counter)
        } else {
            let timeSpeed = program[indexPath.row-2+index]
            cell.textLabel?.text = intToTime(time: timeSpeed.0)
            cell.contentView.backgroundColor = timeSpeed.1.color()
            cell.textLabel?.backgroundColor = timeSpeed.1.color()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 100.0
        } else {
            return UITableViewAutomaticDimension
        }
    }
}

extension TableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        allLocations[index].0.append(newLocation)
        print("didUpdateLocations[\(locations.count)] \(newLocation)")
    }
}

