//
//  ProgramsViewController.swift
//  Running
//
//  Created by Romain Hild on 30/04/2018.
//  Copyright © 2018 Romain Hild. All rights reserved.
//

import UIKit

class ProgramsViewController: UITableViewController {
    
    let programsSaved = ProgramsSaved.shared
    var delegate: ProgramsProtocol! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programsSaved.programs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "programCell", for: indexPath)
        let program = programsSaved.programs[indexPath.row]
        cell.textLabel!.text = program.name
        cell.detailTextLabel!.text = intToTime(time: program.totalTime)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.selectedProgram(at: indexPath.row)
        dismiss(animated: true, completion: nil)
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

protocol ProgramsProtocol {
    func selectedProgram(at index: Int)
}
