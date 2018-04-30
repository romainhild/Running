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

    @IBOutlet weak var chevronView: ChevronView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    let times: [String] = ["30s", "1m", "1m30", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m", "10m", "11m", "12m"]
    let timesD: [Int] = [30, 60, 90, 120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720]
    let speeds: [String] = ["Walk", "Slow", "Easy", "Hard"]
    let speedsC: [UIColor] = [UIColor.yellow, UIColor.init(red: 1.0, green: 0.66, blue: 0, alpha: 1),
                              UIColor.init(red: 1.0, green: 0.33, blue: 0, alpha: 1), UIColor.red]
    var selectedTimes: [(String,Int,String,UIColor)] = []
    
    var isEditingTableView: Bool = false
    var totalTime: Int {
        get {
            return selectedTimes.reduce(0) { $0 + $1.1}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        totalLabel.text = doubleToTime(time: totalTime)
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        tableView.allowsMultipleSelection = true
        tableView.contentOffset = CGPoint(x: 0, y: tableView.contentSize.height)
 
        let recognizer = RunGestureRecognizer(target: self,
                                              action:#selector(handleGesture(recognizer:)))
        recognizer.delegate = self
        chevronView.addGestureRecognizer(recognizer)
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addTime(_ sender: Any) {
//        let timeRow = timePickerView.selectedRow(inComponent: 0)
//        let speedRow = speedPickerView.selectedRow(inComponent: 0)
//        selectedTimes.append((times[timeRow], timesD[timeRow],speeds[speedRow],speedsC[speedRow]))
//        let index = IndexPath(row: selectedTimes.count-1, section: 0)
//        tableView.beginUpdates()
//        tableView.insertRows(at: [index], with: .automatic)
//        tableView.endUpdates()
//        if tableView.frame.height < tableView.contentSize.height + 44 {
//            tableView.scrollToRow(at: index, at: .bottom, animated: true)
//        }
//        totalLabel.text = doubleToTime(time: totalTime)
    }
    
    @IBAction func editTableView(_ sender: Any) {
        tableView.setEditing(!isEditingTableView, animated: true)
        isEditingTableView = !isEditingTableView
        self.navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    @IBAction func copyRows(_ sender: Any) {
        let rows = tableView.indexPathsForSelectedRows!.map { $0.row }
        var indexes: [IndexPath] = []
        for row in rows {
            indexes.append(IndexPath(row: selectedTimes.count, section: 0))
            selectedTimes.append(selectedTimes[row])
        }
        tableView.beginUpdates()
        tableView.insertRows(at: indexes, with: .automatic)
        tableView.endUpdates()
        if tableView.frame.height < tableView.contentSize.height + CGFloat(44*indexes.count) {
            tableView.scrollToRow(at: indexes.last!, at: .bottom, animated: true)
        }
        totalLabel.text = doubleToTime(time: totalTime)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "runningSegue" {
            let navbar = segue.destination as? UINavigationController
            let runningController = navbar?.topViewController as? TableViewController
            runningController?.timesSpeeds = selectedTimes
        }
    }
    
    func doubleToTime(time: Int) -> String {
        let m: Int = time/60
        let s: Int = time % 60
//         let s: Int = time.truncatingRemainder(dividingBy: 60)
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
    
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationItem.leftBarButtonItem?.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let _ = tableView.indexPathsForSelectedRows else {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            return
        }
    }
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
            totalLabel.text = doubleToTime(time: totalTime)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let timeToMove = selectedTimes.remove(at: sourceIndexPath.row)
        selectedTimes.insert(timeToMove, at: destinationIndexPath.row)
    }
}

extension ViewController : UIGestureRecognizerDelegate {
    @IBAction func handleGesture(recognizer: RunGestureRecognizer) {
        if recognizer.state == .changed {
            var transform = CATransform3DIdentity;
            transform = CATransform3DRotate(transform, recognizer.angle, 0.0, 0.0, 1.0);
            transform = CATransform3DTranslate(transform, 0, recognizer.view!.layer.bounds.height/10.0*CGFloat(recognizer.level), 0)
            chevronView.layer.sublayerTransform = transform
        } else {
            chevronView.layer.sublayerTransform = CATransform3DIdentity
        }
    }

}
