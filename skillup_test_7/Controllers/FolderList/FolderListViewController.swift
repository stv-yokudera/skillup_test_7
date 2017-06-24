//
//  FolderListViewController.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import UIKit

/// フォルダ一覧画面
final class FolderListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbarButton: UIBarButtonItem!
    
    fileprivate let dataSource = FolderListTableViewProvider()
    fileprivate var alertController: UIAlertController?
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadFolderList()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        setupToolbarButton(isEditing: editing)
        tableView.isEditing = editing
    }
    
    // MARK: - action
    
    @IBAction func didTapToolbarButton(_ sender: UIBarButtonItem) {
        isEditing ? showDeleteAllActionSheet() : showFolderAlertWith()
    }
    
    // MARK: - private
    
    private func setup() {
        navigationItem.title = NSLocalizedString("folder", comment: "フォルダ")
        navigationItem.rightBarButtonItem = editButtonItem
        setupToolbarButton(isEditing: isEditing)
        setupTableView()
    }
    
    private func setupTableView() {
        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.allowsSelectionDuringEditing = true
    }
    
    private func setupToolbarButton(isEditing: Bool) {
        toolbarButton.title = isEditing ?
            R.string.localizable.deleteAll() :
            R.string.localizable.addNewFolder()
    }
}

// MARK: - fileprivate
private extension FolderListViewController {
    
    /// フォルダ一覧を再読み込み
    func reloadFolderList() {
        
        let folders = FolderDao.findAllSortedDate()
        dataSource.setFolders(folders: folders)
        tableView.reloadData()
    }
    
    /// すべて削除ボタン押下時のアクションシート
    func showDeleteAllActionSheet() {
        
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: R.string.localizable.delete(), style: .destructive) { [weak self] (action) in
            
            guard let `self` = self else { return }
            FolderDao.deleteAll()
            self.reloadFolderList()
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
    func showFolderAlertWith(folderId: Int? = nil) {
        
        var folderName  = ""
        
        if let folderId = folderId,
            let findResult = FolderDao.findByID(folderId: folderId) {
            // 更新の場合、登録済みのフォルダ名をセット
            folderName = findResult.folderName
        }
        
        let message = folderId != nil ?
            R.string.localizable.editFolder() :
            R.string.localizable.registerFolder()
        
        alertController = UIAlertController(title: folderName,
                                            message: message,
                                            preferredStyle: .alert)
        
        guard let alertController = self.alertController else { return }
        
        alertController.addTextField { (textField) in
            
            textField.text = folderName
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
                let folderName = self.alertController?.textFields?.first?.text else { return }
            
            if let folderId = folderId,
                let findResult = FolderDao.findByID(folderId: folderId) {
                // 更新
                findResult.folderName = folderName
                _ = FolderDao.update(model: findResult)
            } else {
                // 新規登録
                let folder = Folder()
                folder.folderName = folderName
                FolderDao.add(model: folder)
            }
            
            self.removeTextFieldObserver()
            self.reloadFolderList()
        }
        
        // 新規登録の場合はfalse, 更新の場合はtrue
        saveAction.isEnabled = (folderId != nil)
        
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
        #selector(FolderListViewController.alertTextFieldTextDidChange(notification:))
}

// MARK: - UITableViewDelegate
extension FolderListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedFolder = dataSource.folder(indexPath: indexPath)
        
        if isEditing {
            // 登録済みフォルダ編集
            showFolderAlertWith(folderId: selectedFolder.folderId)
        } else {
            // タスク一覧画面に遷移
            let taskListVC = TaskListViewController.makeWith(folder: selectedFolder)
            self.navigationController?.pushViewController(taskListVC, animated: true)
        }
    }
}

// MARK: - FolderListProviderDelegate
extension FolderListViewController: FolderListProviderDelegate {
    func deleteFolder(folderId: Int) {
        // フォルタテーブルから対象のフォルダを削除する
        FolderDao.delete(folderId: folderId)
        reloadFolderList()
    }
}
