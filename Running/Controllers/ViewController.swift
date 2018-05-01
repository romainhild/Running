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

    @IBOutlet weak var targetView: TargetView!
    @IBOutlet weak var chevronView: ChevronView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var indexProgram: Int? = nil {
        didSet {
            self.loadProgram()
        }
    }
    var program: Program = Program()

    var isEditingTableView: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.loadProgram()
 
        totalLabel.text = intToTime(time: program.totalTime)
        self.navigationItem.rightBarButtonItems![1].isEnabled = false
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
    
    func loadProgram() {
        if let index = self.indexProgram {
            program = ProgramsSaved.shared.programs[index]
            self.navigationItem.title = program.name
        } else {
            program = Program()
            self.navigationItem.title = "Program"
        }
        tableView.reloadData()
    }

    @IBAction func editTableView(_ sender: Any) {
        tableView.setEditing(!isEditingTableView, animated: true)
        isEditingTableView = !isEditingTableView
        self.navigationItem.rightBarButtonItems![1].isEnabled = false
    }
    
    @IBAction func copyRows(_ sender: Any) {
        let rows = tableView.indexPathsForSelectedRows!.map { $0.row }
        var indexes: [IndexPath] = []
        for row in rows {
            indexes.append(IndexPath(row: program.count, section: 0))
            program.append(program[row])
        }
        tableView.beginUpdates()
        tableView.insertRows(at: indexes, with: .automatic)
        tableView.endUpdates()
        if tableView.frame.height < tableView.contentSize.height + CGFloat(44*indexes.count) {
            tableView.scrollToRow(at: indexes.last!, at: .bottom, animated: true)
        }
        totalLabel.text = intToTime(time: program.totalTime)
    }
    
    @IBAction func saveProgram(_ sender: Any) {
        let alertController: UIAlertController
        if let index = self.indexProgram {
            alertController = UIAlertController(title: "Modify \(self.program.name)", message: "", preferredStyle: .alert)
            alertController.addTextField { $0.text = self.program.name }
            let saveAction = UIAlertAction(title: "Save", style: .default) { alert -> Void in
                let name = alertController.textFields![0].text!
                self.program.name = name
                let programsSaved = ProgramsSaved.shared
                programsSaved.replaceProgram(at: index, with: self.program)
                programsSaved.savePrograms()
                self.indexProgram = index
            }
            alertController.addAction(saveAction)
        } else {
            alertController = UIAlertController(title: "Save Program", message: "", preferredStyle: .alert)
            alertController.addTextField { $0.placeholder = "Enter a name:" }
            let saveAction = UIAlertAction(title: "Save", style: .default) { alert -> Void in
                let name = alertController.textFields![0].text!
                self.program.name = name
                let programsSaved = ProgramsSaved.shared
                programsSaved.addProgram(self.program)
                programsSaved.savePrograms()
                self.indexProgram = programsSaved.programs.count-1
            }
            alertController.addAction(saveAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addProgram() {
        self.indexProgram = nil
        self.loadProgram()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "runningSegue" {
            let runningController = segue.destination as? TableViewController
            runningController?.program = program
        } else if segue.identifier == "programsSegue" {
            let navController = segue.destination as? UINavigationController
            let programsController = navController?.topViewController as? ProgramsViewController
            programsController?.delegate = self
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
        self.navigationItem.rightBarButtonItems![1].isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let _ = tableView.indexPathsForSelectedRows else {
            self.navigationItem.rightBarButtonItems![1].isEnabled = false
            return
        }
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return program.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath)
        let timeSpeed = program[indexPath.row]
        cell.textLabel?.text = "\(intToTime(time: timeSpeed.0)) \(timeSpeed.1.string())"
        cell.showsReorderControl = isEditingTableView
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.program.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            totalLabel.text = intToTime(time: program.totalTime)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let timeToMove = program.remove(at: sourceIndexPath.row)
        program.insert(timeToMove, at: destinationIndexPath.row)
    }
}

extension ViewController : UIGestureRecognizerDelegate {
    @IBAction func handleGesture(recognizer: RunGestureRecognizer) {
        targetView.pointLayers.forEach { $0.opacity = 0.0 }
        if recognizer.state == .changed {
            var transform = CATransform3DIdentity;
            transform = CATransform3DRotate(transform, recognizer.angle, 0.0, 0.0, 1.0);
            transform = CATransform3DTranslate(transform, 0, targetView.targetLayer.size*CGFloat(recognizer.level), 0)
            chevronView.layer.sublayerTransform = transform
            targetView.pointLayers.forEach { $0.opacity = 0.0 }
            for i in 0..<recognizer.alpha {
                targetView.pointLayers[recognizer.level*24+i].opacity = 1.0
            }
        } else if recognizer.state == .ended {
            guard let speed = Speed(rawValue: recognizer.level) else {
                chevronView.layer.sublayerTransform = CATransform3DIdentity
                return
            }

            let time = recognizer.alpha*30
            program.append((time,speed))
            let index = IndexPath(row: program.count-1, section: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [index], with: .automatic)
            tableView.endUpdates()
            if tableView.frame.height < tableView.contentSize.height + 44 {
                tableView.scrollToRow(at: index, at: .bottom, animated: true)
            }
            totalLabel.text = intToTime(time: program.totalTime)
            chevronView.layer.sublayerTransform = CATransform3DIdentity
        } else {
            chevronView.layer.sublayerTransform = CATransform3DIdentity
        }
    }

}

extension ViewController : ProgramsProtocol {
    func selectedProgram(at index: Int) {
        self.indexProgram = index
    }
}
