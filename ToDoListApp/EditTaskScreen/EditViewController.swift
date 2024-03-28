//
//  EditViewController.swift
//  ToDoListApp
//
//  Created by Tushar  Verma on 11.03.24.
//

import UIKit
import ToDoListAppShared

class EditViewController: UIViewController, UITextViewDelegate {

    var tittleValue : String?
    var isParent = Bool()
    
    let tittleTextView = UITextView()
    let taskOperationObj = TaskOperations()
    
    var selectedTaskArray:[TaskList]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(backToParentView))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // Create a UILabel
        let taskLabel = UILabel()
        // Set label properties
        taskLabel.text = "Tittle"
        taskLabel.textColor = UIColor.black
        taskLabel.font = UIFont.systemFont(ofSize: 18)
        taskLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add label to the view
        view.addSubview(taskLabel)
        
        // Configure constraints
        NSLayoutConstraint.activate([
            taskLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taskLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            taskLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            taskLabel.heightAnchor.constraint(equalToConstant: 50)
            
        ])
        
        // Set textView properties
        tittleTextView.textColor = UIColor.black
        tittleTextView.font = UIFont.systemFont(ofSize: 18)
        tittleTextView.isScrollEnabled = false // Disable scrolling
        tittleTextView.delegate = self
        tittleTextView.layer.borderColor = UIColor.black.cgColor
        tittleTextView.layer.borderWidth = 0.5
        
        if let tittleValue = tittleValue {
            tittleTextView.text = tittleValue
        }
        
        // Ensure that autoresizing mask is set to false for using auto layout
        tittleTextView.translatesAutoresizingMaskIntoConstraints = false
        // Add textView to the view
        view.addSubview(tittleTextView)
        
        // Configure constraints
        NSLayoutConstraint.activate([
            tittleTextView.topAnchor.constraint(equalTo: taskLabel.bottomAnchor),
            tittleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tittleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tittleTextView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
    }
    
    @objc func backToParentView(){
        if(tittleValue == nil && isParent){
            taskOperationObj.addSubtask(withName: tittleTextView.text, subtaskLevel: selectedTaskArray![0].level+1, parentTask: selectedTaskArray![0])
        }
        else if(tittleValue == nil){
            taskOperationObj.addTask(tittleTextView.text, taskLevel: 0)
        }
        else{
            taskOperationObj.updateTask(withName: tittleTextView.text, ofTask: selectedTaskArray![0])
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func textViewDidChange(_ textView: UITextView) {
        if(textView.text.isEmpty || textView.text == tittleValue){
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        else{
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        adjustTextViewHeight(textView)
    }

    func adjustTextViewHeight(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = size.height
            }
        }
        view.layoutIfNeeded()
    }

}
