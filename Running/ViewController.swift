//
//  ViewController.swift
//  Running
//
//  Created by Romain Hild on 27/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit
import AVFoundation

enum Speed: Int {
    case walk = 0
    case slow
    case easy
    case hard
    
    static let allValues = [walk, slow, easy, hard]

    func string() -> String {
        switch self {
        case .walk: return "Walk"
        case .slow: return "Slow"
        case .easy: return "Easy"
        case .hard: return "Hard"
        }
    }
    
    func color() -> UIColor {
        switch self {
        case .walk: return UIColor.yellow
        case .slow: return UIColor.init(red: 1.0, green: 0.66, blue: 0, alpha: 1)
        case .easy: return UIColor.init(red: 1.0, green: 0.33, blue: 0, alpha: 1)
        case .hard: return UIColor.red
        }
    }
    
    func sound() -> String {
        switch self {
        case .walk: return "bip"
        case .slow: return "bip2"
        case .easy: return "bip3"
        case .hard: return "bip4"
        }
    }
    
    func radius() -> CGFloat {
        switch self {
        case .walk: return 5.0/10.0
        case .slow: return 4.5/10.0
        case .easy: return 4.0/10.0
        case .hard: return 3.5/10.0
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var targetView: TargetView!
    @IBOutlet weak var chevronView: ChevronView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    var selectedTimesAndSpeeds: [(Int,Speed)] = []
    
    var isEditingTableView: Bool = false
    var totalTime: Int {
        get {
            return selectedTimesAndSpeeds.reduce(0) { $0 + $1.0}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        totalLabel.text = intToTime(time: totalTime)
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

    @IBAction func editTableView(_ sender: Any) {
        tableView.setEditing(!isEditingTableView, animated: true)
        isEditingTableView = !isEditingTableView
        self.navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    @IBAction func copyRows(_ sender: Any) {
        let rows = tableView.indexPathsForSelectedRows!.map { $0.row }
        var indexes: [IndexPath] = []
        for row in rows {
            indexes.append(IndexPath(row: selectedTimesAndSpeeds.count, section: 0))
            selectedTimesAndSpeeds.append(selectedTimesAndSpeeds[row])
        }
        tableView.beginUpdates()
        tableView.insertRows(at: indexes, with: .automatic)
        tableView.endUpdates()
        if tableView.frame.height < tableView.contentSize.height + CGFloat(44*indexes.count) {
            tableView.scrollToRow(at: indexes.last!, at: .bottom, animated: true)
        }
        totalLabel.text = intToTime(time: totalTime)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "runningSegue" {
            let runningController = segue.destination as? TableViewController
            runningController?.timesSpeeds = selectedTimesAndSpeeds
        }
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
        return selectedTimesAndSpeeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath)
        let timeSpeed = selectedTimesAndSpeeds[indexPath.row]
        cell.textLabel?.text = "\(intToTime(time: timeSpeed.0)) \(timeSpeed.1.string())"
        cell.showsReorderControl = isEditingTableView
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.selectedTimesAndSpeeds.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            totalLabel.text = intToTime(time: totalTime)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let timeToMove = selectedTimesAndSpeeds.remove(at: sourceIndexPath.row)
        selectedTimesAndSpeeds.insert(timeToMove, at: destinationIndexPath.row)
    }
}

extension ViewController : UIGestureRecognizerDelegate {
    @IBAction func handleGesture(recognizer: RunGestureRecognizer) {
        if recognizer.state == .changed {
            var transform = CATransform3DIdentity;
            transform = CATransform3DRotate(transform, recognizer.angle, 0.0, 0.0, 1.0);
            transform = CATransform3DTranslate(transform, 0, targetView.targetLayer.size*CGFloat(recognizer.level), 0)
            chevronView.layer.sublayerTransform = transform
        } else if recognizer.state == .ended {
            guard let speed = Speed(rawValue: recognizer.level) else {
                chevronView.layer.sublayerTransform = CATransform3DIdentity
                return
            }

            let time = recognizer.alpha*30
            selectedTimesAndSpeeds.append((time,speed))
            let index = IndexPath(row: selectedTimesAndSpeeds.count-1, section: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [index], with: .automatic)
            tableView.endUpdates()
            if tableView.frame.height < tableView.contentSize.height + 44 {
                tableView.scrollToRow(at: index, at: .bottom, animated: true)
            }
            totalLabel.text = intToTime(time: totalTime)
            chevronView.layer.sublayerTransform = CATransform3DIdentity
        } else {
            chevronView.layer.sublayerTransform = CATransform3DIdentity
        }
    }

}
