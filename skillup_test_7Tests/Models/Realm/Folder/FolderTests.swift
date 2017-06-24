//
//  FolderTests.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import XCTest
import RealmSwift
import STV_Extensions
@testable import skillup_test_7

final class FolderTests: XCTestCase {
    
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
    
    /// PrimaryKeyが正しいかテスト
    func testPrimaryKey() {
        // Verify
        XCTAssertEqual(Folder.primaryKey(), "folderId")
    }
    
    /// フォルダに紐づくタスク件数が正しいかテスト
    func testTaskCountString() {
        
        // Setup
        let folder1 = Folder()
        folder1.updateDate = "2017/06/24 01:23:45".toDate(dateFormat: "yyyy/MM/dd HH:mm:ss")
        folder1.folderName = "フォルダ1"
        folder1.tasks = setupTasksData()
        FolderDao.add(model: folder1)
        
        // Verify
        XCTAssertEqual(Folder().taskCountString(), "1")
    }
    
    // MARK: - private
    
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
