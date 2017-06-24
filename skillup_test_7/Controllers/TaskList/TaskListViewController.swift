//
//  TaskListViewController.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import UIKit

final class TaskListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbarButton: UIBarButtonItem!
    
    fileprivate let dataSource = TaskListTableViewProvider()
    fileprivate var alertController: UIAlertController?
    
    var folder = Folder()
    
    // MARK : - factory
    
    class func makeWith(folder: Folder) -> TaskListViewController {
        
        guard let taskListVC = R.storyboard.taskListViewController.instantiateInitialViewController() else {
            fatalError("TaskListViewController is nil.")
        }
        taskListVC.folder = folder
        return taskListVC
    }
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTaskList()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        setupToolbarButton(isEditing: editing)
        tableView.isEditing = editing
    }
    
    // MARK: - action
    
    @IBAction func didTapToolbarButton(_ sender: UIBarButtonItem) {
        isEditing ? showDeleteAllActionSheet() : showTaskAlertWith()
    }
    
    // MARK: - private
    
    private func setup() {
        navigationItem.title = folder.folderName
        navigationItem.rightBarButtonItem = editButtonItem
        setupToolbarButton(isEditing: isEditing)
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(R.nib.taskCell(), forCellReuseIdentifier: R.reuseIdentifier.taskCell.identifier)
        
        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.allowsSelectionDuringEditing = true
    }
    
    private func setupToolbarButton(isEditing: Bool) {
        toolbarButton.title = isEditing ?
            R.string.localizable.deleteAll() :
            R.string.localizable.addNewTask()
    }
}

// MARK: - fileprivate
private extension TaskListViewController {
    
    /// フォルダ一覧を再読み込み
    func reloadTaskList() {
        
        let tasks = TaskDao.findAllSortedDateWithFolderId(folderId: folder.folderId)
        dataSource.setTasks(tasks: tasks)
        tableView.reloadData()
    }
    
    /// すべて削除ボタン押下時のアクションシート
    func showDeleteAllActionSheet() {
        
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: R.string.localizable.delete(), style: .destructive) { [weak self] (action) in
            
            guard let `self` = self else { return }
            TaskDao.deleteAll()
            self.reloadTaskList()
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(),
                                         style: .cancel,
                                         handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// フォルダ登録/編集アラート
    ///
    /// - Parameter folderId: 新規の場合はfolderId == nil, 編集の場合はfolderId != nil
    func showTaskAlertWith(taskId: Int? = nil) {
        
        var taskName  = ""
        
        if let taskId = taskId,
            let findResult = TaskDao.findByID(taskId: taskId) {
            // 更新の場合、登録済みのタスク名をセット
            taskName = findResult.taskName
        }
        
        let message = taskId != nil ?
            R.string.localizable.editTask() :
            R.string.localizable.registerTask()
        
        alertController = UIAlertController(title: taskName,
                                            message: message,
                                            preferredStyle: .alert)
        
        guard let alertController = self.alertController else { return }
        
        alertController.addTextField { (textField) in
            
            textField.text = taskName
            textField.placeholder = message
            NotificationCenter.default.addObserver(self,
                                                   selector: .alertTextFieldTextDidChange,
                                                   name: .UITextFieldTextDidChange,
                                                   object: textField)
        }
        
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)  { [weak self] (alertAction) in
            guard let `self` = self else { return }
            self.removeTextFieldObserver()
        }
        
        let saveAction = UIAlertAction(title: R.string.localizable.save(), style: .default) { [weak self] (alertAction) in
            
            guard let `self` = self,
                let taskName = self.alertController?.textFields?.first?.text else { return }
            
            if let taskId = taskId,
                let findResult = TaskDao.findByID(taskId: taskId) {
                // 更新
                findResult.taskName = taskName
                _ = TaskDao.update(model: findResult)
            } else {
                // 新規登録
                let task = Task()
                task.folderId = self.folder.folderId
                task.taskName = taskName
                TaskDao.add(model: task)
            }
            
            self.removeTextFieldObserver()
            self.reloadTaskList()
        }
        
        // 新規登録の場合はfalse, 更新の場合はtrue
        saveAction.isEnabled = (taskId != nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /// アラート内のtextFieldの文字入力通知を削除
    func removeTextFieldObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .UITextFieldTextDidChange,
                                                  object: alertController?.textFields?.first)
    }
    
    /// アラート内のtextFieldの文字入力通知
    @objc func alertTextFieldTextDidChange(notification: NSNotification) {
        guard let textField = notification.object as? UITextField,
            let charactersCount = textField.text?.characters.count else { return }
        alertController?.actions.last?.isEnabled = charactersCount > 0
    }
}

// MARK: - fileprivate Selector
private extension Selector {
    static let alertTextFieldTextDidChange =
        #selector(TaskListViewController.alertTextFieldTextDidChange(notification:))
}

// MARK: - UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedTask = dataSource.task(indexPath: indexPath)
        
        if isEditing {
            // 登録済みタスク編集
            showTaskAlertWith(taskId: selectedTask.taskId)
        }
    }
}

// MARK: - TaskListProviderDelegate
extension TaskListViewController: TaskListProviderDelegate {
    
    func deleteTask(taskId: Int) {
        // タスクテーブルから対象のタスクを削除する
        TaskDao.delete(taskId: taskId)
        reloadTaskList()
    }
}
