//
//  DeleteTaskTest.swift
//  ToDoListAppSharedTests
//
//  Created by Tushar  Verma on 28.03.24.
//

import XCTest
import CoreData
@testable import ToDoListAppShared

class DeleteTaskTest: XCTestCase {

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

    func testDeleteTask() {
        let parentTask = taskOperationObj.fetchTask()
        if(!parentTask.isEmpty){
            // Create a mock completion block expectation
            let completionExpectation = expectation(description: "Completion block called")
            
            // Call the method under test
            taskOperationObj.deleteParentTaskAndSubtasks(parentTask.last!) { deletedTasks in
                // Assert the completion block is called
                XCTAssertNotNil(deletedTasks)
                completionExpectation.fulfill()
            }
            
            // Wait for the completion block to be called
            waitForExpectations(timeout: 5, handler: nil)
            
            // Add more assertions as needed to test specific behavior
        }else{
            print("No Task to Delete")
        }
    }

}
