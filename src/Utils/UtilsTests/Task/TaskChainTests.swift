//
//  Created on 22/08/2018
//  Copyright © Vladimir Benkevich 2018
//


import XCTest
@testable import Utils

class TaskChainTests: XCTestCase {

    var executeQueue: DispatchQueue!
    var notifyQueue: DispatchQueue!

    override func setUp() {
        super.setUp()
        executeQueue = DispatchQueue(label: "task.execute", qos: .default)
        notifyQueue = DispatchQueue(label: "task.notify", qos: .default)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleChain() {
        let notifyTask1 = expectation(description: "notify task1")
        let createTask2 = expectation(description: "create task2")
        let notifyTask2 = expectation(description: "notify task2")

        let result1 = 1
        let result2 = "2"

        let createSecondTask: (Task<Int>) -> Task<String> = { [executeQueue] (task: Task<Int>) in
            XCTAssertEqual(task.result, result1)
            XCTAssertEqual(task.status, .success(result1))
            createTask2.fulfill()

            return executeQueue!.async(Task {
                return result2
            })
        }

        let task = Task<Int> { return result1 }

        task.notify(notifyQueue) {
            XCTAssertEqual($0.result, result1)
            XCTAssertEqual($0.status, .success(result1))
            notifyTask1.fulfill()
        }
        .chain(factory: createSecondTask)
        .notify(notifyQueue) {
            XCTAssertEqual($0.result, result2)
            XCTAssertEqual($0.status, .success(result2))
            notifyTask2.fulfill()
        }

        executeQueue.async(task)

        wait(for: [notifyTask1, createTask2, notifyTask2], timeout: 1)
    }
}
