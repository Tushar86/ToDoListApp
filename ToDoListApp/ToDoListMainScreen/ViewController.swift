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
    
//    var dataArray = ["ABC", "DEF", "GHI", "JKL"]
    
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
        self.navigateToEditScreen(taskTittleValue: nil, tittleIndexValue: nil)
    }
    
    func navigateToEditScreen(taskTittleValue: String?, tittleIndexValue: Int?){
        lazy var editVC = EditViewController()
        editVC.tittleValue = taskTittleValue
        editVC.indexvalue = tittleIndexValue
        navigationController?.pushViewController(editVC, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataArray[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigateToEditScreen(taskTittleValue: dataArray[indexPath.row].name, tittleIndexValue: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completion) in
            self.dataArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        let addSubtaskAction = UIContextualAction(style: .normal, title: "Add Subtask") { (action, sourceView, completion) in
            self.navigateToEditScreen(taskTittleValue: nil, tittleIndexValue: nil)
            completion(true)
            
        }
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, addSubtaskAction])
        return swipeConfiguration
    }
}

