//
//  Task.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import Foundation
import RealmSwift

/// Realm Taskテーブルモデルクラス
final class Task: Object {
    
    dynamic var taskId = 0
    dynamic var folderId = 0
    dynamic var updateDate = Date()
    dynamic var taskName = ""
    
    override static func primaryKey() -> String? {
        return "taskId"
    }
}
