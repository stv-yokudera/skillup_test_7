//
//  TaskListTableViewProvider.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import UIKit
import STV_Extensions

protocol TaskListProviderDelegate: class {
    
    /// タスクが削除されたことを通知する
    ///
    /// - Parameter taskId: 削除対象のtaskId
    func deleteTask(taskId: Int)
}

final class TaskListTableViewProvider: NSObject {
    
    fileprivate var tasks: [Task] = []
    weak var delegate: TaskListProviderDelegate?
    
    func setTasks(tasks: [Task]) {
        self.tasks = tasks
    }
    
    /// タスクを取得
    ///
    /// - Parameter indexPath: TableViewのインデックス
    /// - Returns: フォルダ
    func task(indexPath: IndexPath) -> Task {
        
        if indexPath.row >= tasks.count {
            fatalError("tasksの要素数超過")
        }
        return tasks[indexPath.row]
    }
}

// MARK: - UITableViewDataSource
extension TaskListTableViewProvider: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.taskCell.identifier,
                                                 for: indexPath) as! TaskCell
        cell.taskNameLabel.text = tasks[indexPath.row].taskName
        cell.dateLabel.text = tasks[indexPath.row].updateDate.dateStyle()
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let task = self.task(indexPath: indexPath)
            tasks.remove(at: indexPath.row)
            delegate?.deleteTask(taskId: task.taskId)
        }
    }
}
