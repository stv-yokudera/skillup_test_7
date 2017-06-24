//
//  FolderDao.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import Foundation
import RealmSwift

final class FolderDao {
    
    static let daoHelper = RealmDaoHelper<Folder>()
    
    // MARK: - find
    
    /// folderIdを指定して、レコードを取得する
    static func findByID(folderId: Int) -> Folder? {
        guard let object = daoHelper.findFirst(key: folderId as AnyObject) else {
            return nil
        }
        return Folder(value: object)
    }
    
    /// updateDateの降順(新しい順)で、全件取得する
    static func findAllSortedDate() -> [Folder] {
        let objects =  daoHelper.findAll().sorted(byKeyPath: "updateDate", ascending: false)
        return objects.map { Folder(value: $0) }
    }
    
    // MARK: - add
    
    /// レコードを追加する
    static func add(model: Folder) {
        
        let newObject = Folder()
        
        if let newId = daoHelper.newId() {
            newObject.folderId = newId
        }
        newObject.updateDate = model.updateDate
        newObject.folderName = model.folderName
        newObject.tasks = model.tasks
        
        daoHelper.add(d: newObject)
    }
    
    // MARK: - update
    
    /// レコードを更新する
    static func update(model: Folder) -> Bool {
        
        guard let object = daoHelper.findFirst(key: model.folderId as AnyObject) else {
            return false
        }
        
        // update
        do {
            daoHelper.realm.beginWrite()
            object.updateDate = model.updateDate
            object.folderName = model.folderName
            object.tasks = model.tasks
            try daoHelper.realm.commitWrite()
            return true
        } catch let error {
            Logger.error(message: error.localizedDescription)
            if daoHelper.realm.isInWriteTransaction {
                daoHelper.realm.cancelWrite()
            }
            return false
        }
    }
    
    // MARK: - delete
    
    /// folderIdを指定して、レコードを削除する
    static func delete(folderId: Int) {
        
        guard let object = daoHelper.findFirst(key: folderId as AnyObject) else {
            return
        }
        daoHelper.delete(d: object)
    }
    
    /// レコードを全件削除する
    static func deleteAll() {
        daoHelper.deleteAll()
    }
}
