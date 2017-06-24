//
//  Folder.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import Foundation
import RealmSwift

/// Realm Folderテーブルモデルクラス
final class Folder: Object {
    dynamic var folderId = 0
    dynamic var updateDate = Date()
    dynamic var folderName = ""
    var tasks = List<Task>()
    
    override static func primaryKey() -> String? {
        return "folderId"
    }
    
    func taskCountString() -> String {
        return TaskDao.findAllSortedDateWithFolderId(folderId: folderId).count.description
    }
}
