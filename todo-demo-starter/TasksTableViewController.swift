//
//  TasksTableViewController.swift
//  todo-demo-starter
//
//  Created by kndoshn on 2019/10/15.
//  Copyright © 2019 DittoLive Incorporated. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController {
    
    // We need to format the task creation date into a UTC string
    var dateFormatter = ISO8601DateFormatter()
    
    // This is the UITableView data source
    var tasks: [[String: Any?]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didClickAddTask(_ sender: Any) {
        // Create an alert
        let alert = UIAlertController(
            title: "Add New Task",
            message: nil,
            preferredStyle: .alert)

        // Add a text field to the alert for the new task text
        alert.addTextField()

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // Add a "OK" button to the alert. The handler calls addNewToDoItem()
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let text = alert.textFields?[0].text {
                let dateString = self.dateFormatter.string(from: Date())
                self.tasks.append([
                    "text": text,
                    "dateCreated": dateString,
                    "isComplete": false
                ])
                self.tableView.reloadData()
            }
        })

        // Present the alert to the user
        present(alert, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        
        // Configure the cell...
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task["text"] as? String
        let taskComplete = task["isComplete"] as! Bool
        if taskComplete {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tasks.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var task = tasks[indexPath.row]
        let isComplete = task["isComplete"] as! Bool
        task.updateValue(!isComplete, forKey: "isComplete")
        tasks[indexPath.row] = task
        tableView.reloadData()
    }
}
