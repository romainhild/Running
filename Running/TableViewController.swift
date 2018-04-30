//
//  TableViewController.swift
//  Running
//
//  Created by Romain Hild on 27/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit
import AVFoundation

class TableViewController: UITableViewController {
    let soundList: [Speed: String] = [.walk: "bip", .slow: "bip2", .easy: "bip3", .hard: "bip4"]
    var soundsId: [Speed: SystemSoundID] = [:]
    let colorList: [Speed: UIColor] = [ .walk: UIColor.yellow,
                                        .slow: UIColor.init(red: 1.0, green: 0.66, blue: 0, alpha: 1),
                                        .easy: UIColor.init(red: 1.0, green: 0.33, blue: 0, alpha: 1),
                                        .hard: UIColor.red]
    var timesSpeeds: [(Int,Speed)] = []
    
    var timer = Timer()
    let timeInterval = 0.1
    var counter = 0.0
    var counterFromStart: Int = 0
    var isRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "runningCell")
        for (speed,sound) in soundList {
            let path = Bundle.main.path(forResource: "\(sound)", ofType:"m4a")!
            let url = URL(fileURLWithPath: path)
            var soundId: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url as CFURL, &soundId)
            soundsId[speed] = soundId
        }
        if timesSpeeds.count == 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startRunning(_ sender: Any) {
        if !isRunning {
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            playSpeed(speed: timesSpeeds[0].1)
            isRunning = true
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(startRunning(_:)))
        } else {
            timer.invalidate()
            isRunning = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startRunning(_:)))
        }
    }
    
    @objc func updateTimer() {
        let cell0 = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        let cell1 = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        counter += timeInterval
        if counter >= Double(timesSpeeds[0].0) {
            counterFromStart += Int(counter)
            counter = 0.0
            if timesSpeeds.count > 1 {
                playSpeed(speed: timesSpeeds[1].1)
            } else {
                timer.invalidate()
                counter = Double(counterFromStart)
                counterFromStart = 0
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
            self.timesSpeeds.remove(at: 0)
            self.tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
        cell0?.textLabel?.text = self.intToTime(time: self.counterFromStart)
        cell1?.textLabel?.text = self.doubleToTime(time: self.counter)
    }
    
    func playSpeed(speed: Speed) {
        AudioServicesPlaySystemSound(soundsId[speed]!)
    }
    
    func intToTime(time: Int) -> String {
        let m: Int = time/60
        let s: Int = time % 60
        var t: String = "0s"
        if m > 0 {
            if s > 0 {
                t = String(format: "%dm %ds", m, s)
            } else {
                t = String(format: "%dm", m)
            }
        } else if s > 0 {
            t = String(format: "%ds", s)
        }
        return t
    }
    
    func doubleToTime(time: Double) -> String {
        let m: Int = Int(time/60)
        let s: Double = time.truncatingRemainder(dividingBy: 60)
        var t: String = "0s"
        if m > 0 {
            if s > 0 {
                t = String(format: "%dm %.1fs", m, s)
            } else {
                t = String(format: "%dm", m)
            }
        } else if s > 0 {
            t = String(format: "%.1fs", s)
        }
        return t
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return timesSpeeds.count + 2
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
            if timesSpeeds.count > 0 {
                cell.textLabel?.backgroundColor = colorList[timesSpeeds[0].1]
                cell.contentView.backgroundColor = colorList[timesSpeeds[0].1]
            } else {
                cell.contentView.backgroundColor = UIColor.white
                cell.textLabel?.backgroundColor = UIColor.white
            }
            cell.textLabel?.text = doubleToTime(time: counter)
        } else {
            let timeSpeed = timesSpeeds[indexPath.row-2]
            cell.textLabel?.text = intToTime(time: timeSpeed.0)
            cell.contentView.backgroundColor = colorList[timeSpeed.1]
            cell.textLabel?.backgroundColor = colorList[timeSpeed.1]
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

    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
     */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
