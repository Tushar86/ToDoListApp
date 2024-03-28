//
//  UpdateTaskTest.swift
//  ToDoListAppSharedTests
//
//  Created by Tushar  Verma on 28.03.24.
//

import XCTest
import CoreData
@testable import ToDoListAppShared

class UpdateTaskTest: XCTestCase {

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

    func testUpdateTaskWithName() {
        let parentTask = taskOperationObj.fetchTask()
        if(!parentTask.isEmpty){
            // Call the method with updated name
            let updatedName = "New Task Name"
            taskOperationObj.updateTask(withName: updatedName, ofTask: parentTask.last!)
            
            // Assert that taskName is updated
            XCTAssertEqual(parentTask.last!.taskName, updatedName)
        }
    }

}
