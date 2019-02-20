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
    
    var isForeground = true
    var isFinish = false {
        didSet {
            locationManager.stopUpdatingLocation()
            if isForeground {
                timer.invalidate()
                performSegue(withIdentifier: "locationSegue", sender: nil)
            }
        }
    }
    
    var timer = Timer()
    let timerInterval = 0.1
    var counter = 0.0
    var counterFromStart: Int = 0
    var isRunning = false
    var startDate: Date = Date(timeIntervalSinceNow: 0)
    
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
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            locationManager.requestAlwaysAuthorization()
            return
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let app = UIApplication.shared
        let resignSelec = #selector(TableViewController.applicationWillResignActive(notification:))
        NotificationCenter.default.addObserver(self, selector: resignSelec, name: .UIApplicationWillResignActive, object: app)
        let fgSelec = #selector( TableViewController.applicationWillEnterForeground(notification:))
        NotificationCenter.default.addObserver(self, selector: fgSelec, name: .UIApplicationWillEnterForeground, object: app)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let app = UIApplication.shared
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: app)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: app)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func applicationWillResignActive(notification: NSNotification) {
        isForeground = false
        if isRunning {
            timer.invalidate()
        }
        startDate = Date(timeIntervalSinceNow: 0)
    }
    
    @objc func applicationWillEnterForeground(notification: NSNotification) {
        isForeground = true
        if isFinish {
            performSegue(withIdentifier: "locationSegue", sender: nil)
        } else {
            if isRunning {
                timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            }
            tableView.reloadData()
        }
    }
    
    @IBAction func startRunning(_ sender: Any) {
        startDate = Date(timeIntervalSinceNow: 0)
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        playSpeed(speed: program[index].1)
        isRunning = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(pauseRunning(_:)))
    }
    
    @IBAction func pauseRunning(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        timer.invalidate()
        isRunning = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self,
                                                                 action: #selector(startRunning(_:)))
    }
    
    @objc func updateTimer() {
        counter += timerInterval
        if self.advanceIndex() {
            self.tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
        let cell0 = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        let cell1 = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        cell0?.textLabel?.text = intToTime(time: self.counterFromStart)
        cell1?.textLabel?.text = doubleToTime(time: self.counter)
    }
    
    @discardableResult
    func advanceIndex() -> Bool {
        if counter >= Double(program[index].0) {
            counterFromStart += program[index].0
            counter = 0.0
            if index+1 < program.count {
                playSpeed(speed: program[index+1].1)
                allLocations.append(([],program[index+1].1))
            } else {
                self.isFinish = true
            }
            index += 1
            return true
        } else {
            return false
        }
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        if !isFinish {
            allLocations[index].0.append(newLocation)
            if !isForeground && newLocation.timestamp.compare(startDate) == .orderedDescending {
                counter += newLocation.timestamp.timeIntervalSince(startDate)
                startDate = newLocation.timestamp
                self.advanceIndex()
            }
        }
    }
}

