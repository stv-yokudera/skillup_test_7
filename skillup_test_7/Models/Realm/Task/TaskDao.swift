//
//  TaskDao.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import Foundation
import RealmSwift

final class TaskDao {
    
    static let daoHelper = RealmDaoHelper<Task>()
    
    // MARK: - find
    
    /// taskIdを指定して、レコードを取得する
    static func findByID(taskId: Int) -> Task? {
        guard let object = daoHelper.findFirst(key: taskId as AnyObject) else {
            return nil
        }
        return Task(value: object)
    }
    
    /// updateDateの降順(新しい順)で、全件取得する
    static func findAllSortedDateWithFolderId(folderId: Int) -> [Task] {
        let objects =  daoHelper.findAll().filter("folderId = \(folderId.description)").sorted(byKeyPath: "updateDate", ascending: false)
        return objects.map { Task(value: $0) }
    }
    
    // MARK: - add
    
    /// レコードを追加する
    static func add(model: Task) {
        
        let newObject = Task()
        
        if let newId = daoHelper.newId() {
            newObject.taskId = newId
        }
        newObject.folderId = model.folderId
        newObject.updateDate = model.updateDate
        newObject.taskName = model.taskName
        
        daoHelper.add(d: newObject)
    }
    
    // MARK: - update
    
    /// レコードを更新する
    static func update(model: Task) -> Bool {
        
        guard let object = daoHelper.findFirst(key: model.taskId as AnyObject) else {
            return false
        }
        
        // update
        do {
            daoHelper.realm.beginWrite()
            object.folderId = model.folderId
            object.updateDate = model.updateDate
            object.taskName = model.taskName
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
    
    /// taskIdを指定して、レコードを削除する
    static func delete(taskId: Int) {
        
        guard let object = daoHelper.findFirst(key: taskId as AnyObject) else {
            return
        }
        daoHelper.delete(d: object)
    }
    
    /// レコードを全件削除する
    static func deleteAll() {
        daoHelper.deleteAll()
    }
}
