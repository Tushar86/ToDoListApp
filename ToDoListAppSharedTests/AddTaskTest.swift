//
//  AddTaskTest.swift
//  ToDoListAppSharedTests
//
//  Created by Tushar  Verma on 28.03.24.
//

import XCTest
import CoreData
@testable import ToDoListAppShared

class AddTaskTest: XCTestCase {

    var taskOperationObj: TaskOperations!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        taskOperationObj = TaskOperations()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        taskOperationObj = nil
        try super.tearDownWithError()
    }

    func testAddTask() {
        
        let taskName = "Test"
        let taskLevel = 0
        
        taskOperationObj.addTask(taskName, taskLevel: Int(taskLevel))
        
        let fetchedTasks = taskOperationObj.fetchTask()
        XCTAssertNotEqual(fetchedTasks.count, 0, "Expected one task to be added")
        XCTAssertEqual(fetchedTasks.last!.taskName, taskName, "Task name should match the expected value")
        XCTAssertEqual(fetchedTasks.last!.level, taskLevel, "Task level should match the expected value")
    }

    func testAddSubtask() {
            // Create a parent task and fetch
        taskOperationObj.addTask("Parent Task", taskLevel: 0)
        let parentTask = taskOperationObj.fetchTask()
        
            // Create a subtask task and fetch
        taskOperationObj.addSubtask(withName: "Subtask", subtaskLevel: 1, parentTask: parentTask.last!)
        let subtasks = taskOperationObj.fetchTask()
        
        XCTAssertEqual(subtasks.count, parentTask.count + 1)
        XCTAssertEqual(subtasks.last!.taskName, "Subtask")
        XCTAssertEqual(subtasks.last!.level, 1)
        XCTAssertEqual(subtasks.last!.parentTask, parentTask.last)
        }
}
