//
//  TaskDaoTests.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import XCTest
import STV_Extensions
@testable import skillup_test_7

final class TaskDaoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        TaskDao.deleteAll()
    }
    
    override func tearDown() {
        super.tearDown()
        TaskDao.deleteAll()
    }
    
    // MARK: - find
    
    /// taskIdを指定して、レコードを取得するテスト
    func testFindByID() {
        
        // Setup
        setupTasksData()
        
        // Exercise
        guard let findResult = TaskDao.findByID(taskId: 1) else {
            XCTFail("レコード取得失敗")
            return
        }
        
        // Verify
        XCTAssertEqual(findResult.taskId, 1)
        XCTAssertEqual(findResult.folderId, 1)
        XCTAssertEqual(findResult.updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/06/22 01:23:45")
        XCTAssertEqual(findResult.taskName, "タスク1")
    }
    
    /// 更新日の降順で全件取得するテスト
    func testFindAllSortedDateWithFolderId() {
        
        // Setup
        setupTasksData()
        
        // Exercise
        let allTask = TaskDao.findAllSortedDateWithFolderId(folderId: 1)
        
        // Verify
        XCTAssertEqual(allTask.count, 3)
        
        XCTAssertEqual(allTask[0].taskId, 2)
        XCTAssertEqual(allTask[0].folderId, 1)
        XCTAssertEqual(allTask[0].updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/06/24 01:23:45")
        XCTAssertEqual(allTask[0].taskName, "タスク2")
        
        XCTAssertEqual(allTask[1].taskId, 3)
        XCTAssertEqual(allTask[1].folderId, 1)
        XCTAssertEqual(allTask[1].updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/06/23 01:23:45")
        XCTAssertEqual(allTask[1].taskName, "タスク3")
        
        XCTAssertEqual(allTask[2].taskId, 1)
        XCTAssertEqual(allTask[2].folderId, 1)
        XCTAssertEqual(allTask[2].updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/06/22 01:23:45")
        XCTAssertEqual(allTask[2].taskName, "タスク1")
    }
    
    // MARK: - add
    
    /// タスクを追加するテスト
    func testAdd() {
        
        // Setup
        let task1 = Task()
        task1.folderId = 1
        task1.updateDate = "2017/06/22 01:23:45".toDate(dateFormat: "yyyy/MM/dd HH:mm:ss")
        task1.taskName = "タスク1"
        
        // Exercise
        TaskDao.add(model: task1)
        
        // Verify
        let allTask = TaskDao.findAllSortedDateWithFolderId(folderId: 1)
        
        XCTAssertEqual(allTask.count, 1)
        
        XCTAssertEqual(allTask[0].taskId, 1)
        XCTAssertEqual(allTask[0].folderId, 1)
        XCTAssertEqual(allTask[0].updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/06/22 01:23:45")
        XCTAssertEqual(allTask[0].taskName, "タスク1")
        
    }
    
    // MARK: - update
    
    
    /// 登録済みのタスクを更新するテスト
    func testUpdate() {
        
        // Setup
        setupTasksData()
        guard let updateTask1 = TaskDao.findByID(taskId: 1) else {
            XCTFail("レコード取得失敗")
            return
        }
        updateTask1.updateDate = "2017/07/01 01:23:45".toDate(dateFormat: "yyyy/MM/dd HH:mm:ss")
        updateTask1.taskName = "タスク1α"
        
        // Exercise
        let updateResult = TaskDao.update(model: updateTask1)
        guard let updateData = TaskDao.findByID(taskId: updateTask1.taskId) else {
            XCTFail("レコード取得失敗")
            return
        }
        
        // Verify
        XCTAssertTrue(updateResult)
        XCTAssertEqual(updateData.taskId, 1)
        XCTAssertEqual(updateData.updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/07/01 01:23:45")
        XCTAssertEqual(updateData.taskName, "タスク1α")
        
    }
    
    // MARK: - delete
    
    /// taskIdを指定して、レコードを削除するテスト
    func testDelete() {
        
        // Setup
        setupTasksData()
        
        // Exercise
        TaskDao.delete(taskId: 1)
        
        // Verify
        let allTask = TaskDao.findAllSortedDateWithFolderId(folderId: 1)
        
        XCTAssertEqual(allTask.count, 2)
        
        XCTAssertEqual(allTask[0].taskId, 2)
        XCTAssertEqual(allTask[0].folderId, 1)
        XCTAssertEqual(allTask[0].updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/06/24 01:23:45")
        XCTAssertEqual(allTask[0].taskName, "タスク2")
        XCTAssertEqual(allTask[1].taskId, 3)
        XCTAssertEqual(allTask[1].folderId, 1)
        XCTAssertEqual(allTask[1].updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/06/23 01:23:45")
        XCTAssertEqual(allTask[1].taskName, "タスク3")
    }
    
    /// レコードを全件削除するテスト
    func testDeleteAll() {
        
        // Setup
        setupTasksData()
        
        // Exercise
        TaskDao.deleteAll()
        
        // Verify
        let allTask = TaskDao.findAllSortedDateWithFolderId(folderId: 1)
        
        XCTAssertEqual(allTask.count, 0)
    }
    
    // MARK: - private
    
    private func setupTasksData() {
        let task1 = Task()
        task1.folderId = 1
        task1.updateDate = "2017/06/22 01:23:45".toDate(dateFormat: "yyyy/MM/dd HH:mm:ss")
        task1.taskName = "タスク1"
        TaskDao.add(model: task1)
        
        let task2 = Task()
        task2.folderId = 1
        task2.updateDate = "2017/06/24 01:23:45".toDate(dateFormat: "yyyy/MM/dd HH:mm:ss")
        task2.taskName = "タスク2"
        TaskDao.add(model: task2)
        
        let task3 = Task()
        task3.folderId = 1
        task3.updateDate = "2017/06/23 01:23:45".toDate(dateFormat: "yyyy/MM/dd HH:mm:ss")
        task3.taskName = "タスク3"
        TaskDao.add(model: task3)
    }
}
