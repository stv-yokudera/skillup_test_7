//
//  FolderListTableViewProvider.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import UIKit

protocol FolderListProviderDelegate: class {
    
    /// フォルダが削除されたことを通知する
    ///
    /// - Parameter folderId: 削除対象のfolderId
    func deleteFolder(folderId: Int)
}

final class FolderListTableViewProvider: NSObject {
    
    fileprivate var folders: [Folder] = []
    weak var delegate: FolderListProviderDelegate?
    
    func setFolders(folders: [Folder]) {
        self.folders = folders
    }
    
    /// フォルダを取得
    ///
    /// - Parameter indexPath: TableViewのインデックス
    /// - Returns: フォルダ
    func folder(indexPath: IndexPath) -> Folder {
        
        if indexPath.row >= folders.count {
            fatalError("foldersの要素数超過")
        }
        return folders[indexPath.row]
    }
}

// MARK: - UITableViewDataSource
extension FolderListTableViewProvider: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.folderListTableViewCell.identifier,
                                                 for: indexPath)
        cell.textLabel?.text = folders[indexPath.row].folderName
        cell.detailTextLabel?.text = folders[indexPath.row].taskCountString()
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let folder = self.folder(indexPath: indexPath)
            folders.remove(at: indexPath.row)
            delegate?.deleteFolder(folderId: folder.folderId)
        }
    }
}
