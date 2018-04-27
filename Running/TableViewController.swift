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
    var soundList: [String] = ["bip", "bip2", "bip3", "bip4"]
    var soundsId: [SystemSoundID] = []
    var timesSpeeds: [(String,Double,String,UIColor)] = []
    
    var timer = Timer()
    let timeInterval = 0.1
    var counter = 0.0
    var counterFromStart = 0.0
    var isRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "runningCell")
        for sound in soundList {
            let path = Bundle.main.path(forResource: "\(sound)", ofType:"m4a")!
            let url = URL(fileURLWithPath: path)
            var soundId: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url as CFURL, &soundId)
            soundsId.append(soundId)
        }
        if timesSpeeds.count == 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneRunning(_ sender: Any) {
        timer.invalidate()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startRunning(_ sender: Any) {
        if !isRunning {
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            playSpeed(speed: timesSpeeds[0].2)
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
        if counter >= timesSpeeds[0].1 {
            counterFromStart += counter
            counter = 0.0
            if timesSpeeds.count > 1 {
                playSpeed(speed: timesSpeeds[1].2)
            } else {
                timer.invalidate()
                counter = counterFromStart - timeInterval
                counterFromStart = 0.0
            }
            self.timesSpeeds.remove(at: 0)
            self.tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        }
        cell0?.textLabel?.text = doubleToString(time: counterFromStart)
        cell1?.textLabel?.text = doubleToString(time: counter)
    }
    
    func playSpeed(speed: String) {
        switch speed {
        case "Walk":
            AudioServicesPlaySystemSound(soundsId[0])
        case "Slow":
            AudioServicesPlaySystemSound(soundsId[1])
        case "Easy":
            AudioServicesPlaySystemSound(soundsId[2])
        default:
            AudioServicesPlaySystemSound(soundsId[3])
        }
    }
    
    func doubleToString(time: Double) -> String {
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
        if indexPath.row > 1 {
            let timeSpeed = timesSpeeds[indexPath.row-2]
            cell.textLabel?.text = "\(timeSpeed.0)"
            cell.contentView.backgroundColor = timeSpeed.3
        } else {
            cell.textLabel?.text = "0s"
        }
        if indexPath.row == 1 {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 80)
            cell.textLabel?.adjustsFontSizeToFitWidth = true
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
