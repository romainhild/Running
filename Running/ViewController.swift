//
//  ViewController.swift
//  Running
//
//  Created by Romain Hild on 27/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var speedPickerView: UIPickerView!
    
    let times: [String] = ["30s", "1m", "1m30", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m", "10m", "11m", "12m"]
    let timesD: [Double] = [30, 60, 90, 120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720]
    let speeds: [String] = ["Walk", "Slow", "Easy", "Hard"]
    let speedsC: [UIColor] = [UIColor.yellow, UIColor.init(red: 1.0, green: 0.66, blue: 0, alpha: 1),
                              UIColor.init(red: 1.0, green: 0.33, blue: 0, alpha: 1), UIColor.red]
    var selectedTimes: [(String,Double,String,UIColor)] = []
    
    var isEditingTableView: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addTime(_ sender: Any) {
        let timeRow = timePickerView.selectedRow(inComponent: 0)
        let speedRow = speedPickerView.selectedRow(inComponent: 0)
        selectedTimes.append((times[timeRow], timesD[timeRow],speeds[speedRow],speedsC[speedRow]))
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: selectedTimes.count-1, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    @IBAction func editTableView(_ sender: Any) {
        tableView.setEditing(!isEditingTableView, animated: true)
        isEditingTableView = !isEditingTableView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "runningSegue" {
            let navbar = segue.destination as? UINavigationController
            let runningController = navbar?.topViewController as? TableViewController
            runningController?.timesSpeeds = selectedTimes
        }
    }
    
}

extension ViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == timePickerView {
            return times[row]
        } else {
            return speeds[row]
        }
    }
}

extension ViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == timePickerView {
            return times.count
        } else {
            return speeds.count
        }
    }
}

extension ViewController : UITableViewDelegate {
    
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath)
        let timeSpeed = selectedTimes[indexPath.row]
        cell.textLabel?.text = "\(timeSpeed.0) \(timeSpeed.2)"
        cell.showsReorderControl = isEditingTableView
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.selectedTimes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let timeToMove = selectedTimes.remove(at: sourceIndexPath.row)
        selectedTimes.insert(timeToMove, at: destinationIndexPath.row)
    }
}
