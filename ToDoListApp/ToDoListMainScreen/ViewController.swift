//
//  ViewController.swift
//  ToDoListApp
//
//  Created by Tushar  Verma on 11.03.24.
//

import UIKit
import ToDoListAppShared

class ViewController: UIViewController, TaskManagerDelegate {
    
    @IBOutlet weak var toDoListTable: UITableView!
    
    let taskOperationObj = TaskOperations()
    var tasksArray : [TaskList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskOperationObj.delegate = self
        
        toDoListTable.register(UINib(nibName: "ToDoListTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItem.Style.plain, target: self, action: #selector(addTask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tasksArray = taskOperationObj.fetchTask()
        toDoListTable .reloadData()
    }
    
    @objc func addTask(){
        self.navigateToEditScreen(taskTittleValue: nil, isParent: false, currentIndexTaskDataArray: nil)
    }
    
    func navigateToEditScreen(taskTittleValue: String?, isParent: Bool, currentIndexTaskDataArray: [TaskList]?){
        lazy var editVC = EditViewController()
        editVC.tittleValue = taskTittleValue
        editVC.isParent = isParent
        editVC.selectedTaskArray = currentIndexTaskDataArray
        navigationController?.pushViewController(editVC, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = toDoListTable.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoListTableViewCell
        self.configureCell(cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigateToEditScreen(taskTittleValue: tasksArray[indexPath.row].taskName, isParent: false, currentIndexTaskDataArray: [tasksArray[indexPath.row]])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completion) in
            self.deleteParentTaskAndSubtasks(self.tasksArray[indexPath.row])
            completion(true)
        }
        let addSubtaskAction = UIContextualAction(style: .normal, title: "Add Subtask") { (action, sourceView, completion) in
            self.navigateToEditScreen(taskTittleValue: nil, isParent: true, currentIndexTaskDataArray: [self.tasksArray[indexPath.row]])
            completion(true)
            
        }
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, addSubtaskAction])
        return swipeConfiguration
    }
    
    func deleteParentTaskAndSubtasks(_ parentTask: TaskList) {
        taskOperationObj.deleteParentTaskAndSubtasks(parentTask) { deletedSubtasks in
            // Update your table view data source and delete corresponding rows
            var indexPathsToRemove: [IndexPath] = []
            for task in deletedSubtasks {
                if let index = self.tasksArray.firstIndex(of: task) {
                    let indexPath = IndexPath(row: index, section: 0)
                    indexPathsToRemove.append(indexPath)
                }
            }
            self.toDoListTable.beginUpdates()
            self.tasksArray.removeAll { task in
                deletedSubtasks.contains(task)
            }
            self.toDoListTable.deleteRows(at: indexPathsToRemove, with: .automatic)
            self.toDoListTable.endUpdates()
            
            if let visibleIndexPaths = self.toDoListTable.indexPathsForVisibleRows {
                for indexPath in visibleIndexPaths {
                    if indexPath.row >= indexPathsToRemove[0].row {
                        if let cell = self.toDoListTable.cellForRow(at: indexPath) as? ToDoListTableViewCell {
                            self.configureCell(cell, for: indexPath)
                        }
                    }
                }
            }
        }
    }
    
    func configureCell(_ cell: ToDoListTableViewCell, for indexPath: IndexPath) {
        let task = self.tasksArray[indexPath.row]
        let indentation = String(repeating: "  ", count: task.level)
        if task.level == 0 {
            cell.hierarchicalNumberLabel.text = indentation + "Root "+task.hierarchicalNumber + " -"
        } else {
            cell.hierarchicalNumberLabel.text = indentation + "Child "+task.hierarchicalNumber + " -"
        }
        cell.taskNameLabel.text = task.taskName
        cell.taskCheckBtn.setImage(task.isCompleted ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "checkmark.circle"), for: .normal)
        cell.taskCheckBtn.addTarget(self, action: #selector(self.taskCompleteAction(_:)), for: .touchUpInside)
        cell.taskCheckBtn.tag = indexPath.row
    }
    
    @objc func taskCompleteAction(_ sender: UIButton){
        taskOperationObj.markSubtasksAsCompleted(forTask: tasksArray[sender.tag])
    }
    
    func indexPath(forTask task: TaskList) -> IndexPath {
        if let index = tasksArray.firstIndex(of: task) {
            return IndexPath(row: index, section: 0)
        }
        return IndexPath(row: 0, section: 0)
    }
    
    func subtasksMarked(asCompleted indexPaths: [IndexPath]) {
        // Reload the rows in the table view corresponding to the updated index paths
        toDoListTable.reloadRows(at: indexPaths, with: .automatic)
    }
}

