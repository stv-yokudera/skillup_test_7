//
//  FolderDaoTests.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import XCTest
import RealmSwift
import STV_Extensions
@testable import skillup_test_7

final class FolderDaoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        TaskDao.deleteAll()
        FolderDao.deleteAll()
    }
    
    override func tearDown() {
        TaskDao.deleteAll()
        FolderDao.deleteAll()
        super.tearDown()
    }
    
    // MARK: - find
    
    /// folderIdを指定して、レコードを取得するテスト
    func testFindByID() {
        
        // Setup
        setupFoldersData()
        
        // Exercise
        guard let findResult = FolderDao.findByID(folderId: 1) else {
            XCTFail("レコード取得失敗")
            return
        }
        
        // Verify
        XCTAssertEqual(findResult.folderId, 1)
        XCTAssertEqual(findResult.updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/06/22 01:23:45")
        XCTAssertEqual(findResult.folderName, "フォルダ1")
        XCTAssertEqual(findResult.tasks.count, 1)
    }
    
    /// 更新日の降順で全件取得するテスト
    func testFindAllSortedDate() {
        
        // Setup
        setupFoldersData()
        
        // Exercise
        let allTask = FolderDao.findAllSortedDate()
        
        // Verify
        XCTAssertEqual(allTask.count, 2)
        
        XCTAssertEqual(allTask[0].folderId, 2)
        XCTAssertEqual(allTask[0].updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/06/24 01:23:45")
        XCTAssertEqual(allTask[0].folderName, "フォルダ2")
        XCTAssertEqual(allTask[0].tasks.count, 0)
        
        XCTAssertEqual(allTask[1].folderId, 1)
        XCTAssertEqual(allTask[1].updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/06/22 01:23:45")
        XCTAssertEqual(allTask[1].folderName, "フォルダ1")
        XCTAssertEqual(allTask[1].tasks.count, 1)
    }
    
    // MARK: - add
    
    /// フォルダを追加するテスト
    func testAdd() {
        
        // Setup
        let folder1 = Folder()
        folder1.updateDate = "2017/06/22 01:23:45".toDate(dateFormat: "yyyy/MM/dd HH:mm:ss")
        folder1.folderName = "フォルダ1"
        folder1.tasks = setupTasksData()
        
        // Exercise
        FolderDao.add(model: folder1)
        
        // Verify
        let allTask = FolderDao.findAllSortedDate()
        
        XCTAssertEqual(allTask.count, 1)
        
        XCTAssertEqual(allTask[0].folderId, 1)
        XCTAssertEqual(allTask[0].updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/06/22 01:23:45")
        XCTAssertEqual(allTask[0].folderName, "フォルダ1")
        XCTAssertEqual(allTask[0].tasks.count, 1)
        
        XCTAssertEqual(allTask[0].tasks[0].taskId, 1)
        XCTAssertEqual(allTask[0].tasks[0].updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/07/01 01:23:45")
        XCTAssertEqual(allTask[0].tasks[0].taskName, "タスク1")
    }
    
    // MARK: - update
    
    /// 登録済みのフォルダを更新するテスト
    func testUpdate() {
        
        // Setup
        setupFoldersData()
        guard let updateFolder1 = FolderDao.findByID(folderId: 1) else {
            XCTFail("レコード取得失敗")
            return
        }
        
        TaskDao.delete(taskId: 1)
        updateFolder1.folderName = "フォルダ1α"
        updateFolder1.updateDate = "2017/07/01 01:23:45".toDate(dateFormat: "yyyy/MM/dd HH:mm:ss")
        
        // Exercise
        let updateResult = FolderDao.update(model: updateFolder1)
        guard let updateData = FolderDao.findByID(folderId: updateFolder1.folderId) else {
            XCTFail("レコード取得失敗")
            return
        }
        
        // Verify
        XCTAssertTrue(updateResult)
        XCTAssertEqual(updateData.folderId, 1)
        XCTAssertEqual(updateData.updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/07/01 01:23:45")
        XCTAssertEqual(updateData.folderName, "フォルダ1α")
        XCTAssertEqual(updateData.tasks.count, 0)
    }
    
    // MARK: - delete
    
    /// folderIdを指定して、レコードを削除するテスト
    func testDelete() {
        
        // Setup
        setupFoldersData()
        
        // Exercise
        FolderDao.delete(folderId: 1)
        
        // Verify
        let allFolder = FolderDao.findAllSortedDate()
        
        XCTAssertEqual(allFolder.count, 1)
        
        XCTAssertEqual(allFolder[0].folderId, 2)
        XCTAssertEqual(allFolder[0].updateDate.toStr(dateFormat: "yyyy/MM/dd HH:mm:ss"), "2017/06/24 01:23:45")
        XCTAssertEqual(allFolder[0].folderName, "フォルダ2")
        XCTAssertEqual(allFolder[0].tasks.count, 0)
    }
    
    /// レコードを全件削除するテスト
    func testDeleteAll() {
        
        // Setup
        setupFoldersData()
        
        // Exercise
        FolderDao.deleteAll()
        
        // Verify
        let allFolder = FolderDao.findAllSortedDate()
        
        XCTAssertEqual(allFolder.count, 0)
    }
    
    // MARK: - private
    
    private func setupFoldersData() {
        
        let folder1 = Folder()
        folder1.updateDate = "2017/06/22 01:23:45".toDate(dateFormat: "yyyy/MM/dd HH:mm:ss")
        folder1.folderName = "フォルダ1"
        folder1.tasks = setupTasksData()
        FolderDao.add(model: folder1)
        
        let folder2 = Folder()
        folder2.updateDate = "2017/06/24 01:23:45".toDate(dateFormat: "yyyy/MM/dd HH:mm:ss")
        folder2.folderName = "フォルダ2"
        folder2.tasks = List<Task>()
        FolderDao.add(model: folder2)
    }
    
    private func setupTasksData() -> List<Task> {
        
        let taskList = List<Task>()
        
        let task1 = Task()
        task1.taskId = 1
        task1.updateDate = "2017/07/01 01:23:45".toDate(dateFormat: "yyyy/MM/dd HH:mm:ss")
        task1.taskName = "タスク1"
        taskList.append(task1)
        
        return taskList
    }    
}
