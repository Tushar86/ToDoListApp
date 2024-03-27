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
        let task = tasksArray[indexPath.row]
        let indentation = String(repeating: "  ", count: task.level)
        if task.level == 0 {
            cell.hierarchicalNumberLabel.text = indentation + "Root "+task.hierarchicalNumber + " -"
        } else {
            cell.hierarchicalNumberLabel.text = indentation + "Child "+task.hierarchicalNumber + " -"
        }
        cell.taskNameLabel.text = task.taskName
        cell.taskCheckBtn.setImage(task.isCompleted ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "checkmark.circle"), for: .normal)

        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigateToEditScreen(taskTittleValue: tasksArray[indexPath.row].taskName, tittleIndexValue: indexPath.row, isParent: false, currentIndexTaskDataArray: [tasksArray[indexPath.row]])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completion) in
            completion(true)
        }
        let addSubtaskAction = UIContextualAction(style: .normal, title: "Add Subtask") { (action, sourceView, completion) in
            self.navigateToEditScreen(taskTittleValue: nil, tittleIndexValue: indexPath.row, isParent: true, currentIndexTaskDataArray: [self.tasksArray[indexPath.row]])
            completion(true)
            
        }
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, addSubtaskAction])
        return swipeConfiguration
    }
}

