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
        
    var dataArray:[TaskModel] = []
    
    let taskModel = TaskOperations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        toDoListTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItem.Style.plain, target: self, action: #selector(addTask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataArray = taskModel.loadDataFromPlist()
        toDoListTable .reloadData()
    }

    @objc func addTask(){
        self.navigateToEditScreen(taskTittleValue: nil, tittleIndexValue: nil, isParent: false, currentIndexTaskDataArray: nil)
    }
    
    func navigateToEditScreen(taskTittleValue: String?, tittleIndexValue: Int?, isParent: Bool, currentIndexTaskDataArray: [TaskModel]?){
        lazy var editVC = EditViewController()
        editVC.tittleValue = taskTittleValue
        editVC.indexvalue = tittleIndexValue
        editVC.isParent = isParent
        editVC.dataArray = currentIndexTaskDataArray
        navigationController?.pushViewController(editVC, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = dataArray[indexPath.row]
        // Indentation for hierarchy visualization (optional)
        let indentation = String(repeating: "    ", count: task.level)
          if (task.level == 0){
              cell.textLabel?.text = indentation + "Root " + task.name
          }else{
              cell.textLabel?.text = indentation + "Child " + task.name
          }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigateToEditScreen(taskTittleValue: dataArray[indexPath.row].name, tittleIndexValue: indexPath.row, isParent: false, currentIndexTaskDataArray: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] (action, sourceView, completion) in
            dataArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            taskModel.deleteTask(indexPath.row)
            completion(true)
        }
        let addSubtaskAction = UIContextualAction(style: .normal, title: "Add Subtask") { (action, sourceView, completion) in
            self.navigateToEditScreen(taskTittleValue: nil, tittleIndexValue: nil, isParent: true, currentIndexTaskDataArray: [self.dataArray[indexPath.row]])
            completion(true)
            
        }
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, addSubtaskAction])
        return swipeConfiguration
    }
}

