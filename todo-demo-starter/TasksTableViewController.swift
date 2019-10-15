//
//  TasksTableViewController.swift
//  todo-demo-starter
//
//  Created by kndoshn on 2019/10/15.
//  Copyright © 2019 DittoLive Incorporated. All rights reserved.
//

import UIKit
import DittoKit

class TasksTableViewController: UITableViewController {
    var ditto: DittoKit!
    var collection: DittoCollection!
    var liveQuery: DittoLiveQuery?
    
    // We need to format the task creation date into a UTC string
    var dateFormatter = ISO8601DateFormatter()
    
    // This is the UITableView data source
    var tasks: [DittoDocument] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ditto = try! DittoKit()
        
        ditto.setAccessLicense("<INSERT ACCESS LICENSE>")
        
        ditto.start()
        
        collection = try! ditto.store.collection(name: "tasks")
        
        setupTaskList()
    }
    
    func setupTaskList() {
        liveQuery = try! collection.findAll().sort("dateCreated", isAscending: true).observe { [weak self] docs, event in
            guard let self = self else { return }
            switch event {
            case .initial:
                self.tasks = docs
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .update(_, let insertions, let deletions, let updates, let moves):
                guard insertions.count > 0 || deletions.count > 0 || updates.count > 0  || moves.count > 0 else { return }
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.performBatchUpdates({
                        let deletionIndexPaths = deletions.map { idx -> IndexPath in
                            return IndexPath(row: idx, section: 0)
                        }
                        self.tableView.deleteRows(at: deletionIndexPaths, with: .automatic)
                        let insertionIndexPaths = insertions.map { idx -> IndexPath in
                            return IndexPath(row: idx, section: 0)
                        }
                        self.tableView.insertRows(at: insertionIndexPaths, with: .automatic)
                        let updateIndexPaths = updates.map { idx -> IndexPath in
                            return IndexPath(row: idx, section: 0)
                        }
                        self.tableView.reloadRows(at: updateIndexPaths, with: .automatic)
                        for move in moves {
                            let from = IndexPath(row: move.from, section: 0)
                            let to = IndexPath(row: move.to, section: 0)
                            self.tableView.moveRow(at: from, to: to)
                        }
                    })
                    self.tasks = docs
                    self.tableView.endUpdates()
                }
            default: break
            }
        }
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
                
                try! self.collection.insert([
                    "text": text,
                    "dateCreated": dateString,
                    "isComplete": false
                ])
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
        cell.textLabel?.text = task["text"].stringValue
        let taskComplete = task["isComplete"].boolValue
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
        let task = tasks[indexPath.row]
        try! collection.findByID(task._id).remove()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        try! collection.findByID(task._id).update({ newTask in
            try! newTask?["isComplete"].set(!task["isComplete"].boolValue)
        })
    }
}
