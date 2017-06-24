//
//  TaskCellTests.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import XCTest
import STV_Extensions
@testable import skillup_test_7

final class TaskCellTests: XCTestCase {
    
    var tableView: UITableView!
    let dataSource = FakeDataSource()
    var cell: TaskCell!
    
    override func setUp() {
        super.setUp()
        
        guard let taskListVC = R.storyboard.taskListViewController
            .instantiateInitialViewController() else {
                XCTFail("TaskListViewController is nil.")
                return
        }
        
        _ = taskListVC.view
        tableView = taskListVC.tableView
        tableView?.dataSource = dataSource
        
        cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.taskCell.identifier,
                                                 for: IndexPath(row: 0, section: 0)) as! TaskCell
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /// 日付を確認するテスト (今年以外)
    func testSetDateLabel_ForYYYYMMDD() {
        
        let task = setupTaskData(dateString: "2020/01/02 03:04:05")
        cell.taskNameLabel.text = task.taskName
        cell.dateLabel.text = task.updateDate.dateStyle()
        
        XCTAssertEqual(cell.dateLabel.text, "2020/01/02")
    }
    
    /// 日付を確認するテスト (今年)
    func testSetDateLabel_ForMMDD() {
        
        let task = setupTaskData(dateString: "2017/01/02 03:04:05")
        cell.taskNameLabel.text = task.taskName
        cell.dateLabel.text = task.updateDate.dateStyle()
        XCTAssertEqual(cell.dateLabel.text, "01/02")
    }
    
    /// 日付を確認するテスト (今日)
    func testSetDateLabel_ForHHMM() {
        
        let task = setupTaskData(dateString: "2017/06/24 11:50:01")
        cell.taskNameLabel.text = task.taskName
        cell.dateLabel.text = task.updateDate.dateStyle()
        XCTAssertEqual(cell.dateLabel.text, "11:50")
    }
    
    /// タスク名を確認するテスト
    func testSetTaskName() {
        let task = setupTaskData(dateString: "2017/06/24 11:50:01")
        cell.taskNameLabel.text = task.taskName
        cell.dateLabel.text = task.updateDate.dateStyle()
        XCTAssertEqual(cell.taskNameLabel.text, "タスク1")
    }
    
    // MARK: - private
    
    private func setupTaskData(dateString: String) -> Task {
        let task = Task()
        task.folderId = 1
        task.updateDate = dateString.toDate(dateFormat: "yyyy/MM/dd HH:mm:ss")
        task.taskName = "タスク1"
        return task
    }
}

extension TaskCellTests {
    
    final class FakeDataSource: NSObject, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView,
                       numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return UITableViewCell()
        }
    }
}
