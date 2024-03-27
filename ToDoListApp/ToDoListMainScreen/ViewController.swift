//
//  ViewController.swift
//  ToDoListApp
//
//  Created by Tushar  Verma on 11.03.24.
//

import UIKit
import ToDoListAppShared

class ViewController: UIViewController {

    @IBOutlet weak var toDoListTable: UITableView!
    
    let taskOperationObj = TaskOperations()
    var tasksArray : [TaskList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        toDoListTable.register(UINib(nibName: "ToDoListTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItem.Style.plain, target: self, action: #selector(addTask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tasksArray = taskOperationObj.fetchTask()
        toDoListTable .reloadData()
    }

    @objc func addTask(){
        self.navigateToEditScreen(taskTittleValue: nil, tittleIndexValue: nil, isParent: false, currentIndexTaskDataArray: nil)
    }
    
    func navigateToEditScreen(taskTittleValue: String?, tittleIndexValue: Int?, isParent: Bool, currentIndexTaskDataArray: [TaskList]?){
        lazy var editVC = EditViewController()
        editVC.tittleValue = taskTittleValue
        editVC.indexvalue = tittleIndexValue
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
        self.navigateToEditScreen(taskTittleValue: tasksArray[indexPath.row].taskName, tittleIndexValue: indexPath.row, isParent: false, currentIndexTaskDataArray: [tasksArray[indexPath.row]])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completion) in
            self.deleteParentTaskAndSubtasks(self.tasksArray[indexPath.row])
            completion(true)
        }
        let addSubtaskAction = UIContextualAction(style: .normal, title: "Add Subtask") { (action, sourceView, completion) in
            self.navigateToEditScreen(taskTittleValue: nil, tittleIndexValue: indexPath.row, isParent: true, currentIndexTaskDataArray: [self.tasksArray[indexPath.row]])
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
                        // Update the index path
                        // Get the cell and update its content if needed
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
    }
}

