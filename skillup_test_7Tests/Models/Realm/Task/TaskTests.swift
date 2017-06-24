//
//  TaskTests.swift
//  skillup_test_7
//
//  Created by OkuderaYuki on 2017/06/24.
//  Copyright © 2017年 Okudera Yuki. All rights reserved.
//

import XCTest
@testable import skillup_test_7

final class TaskTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /// PrimaryKeyが正しいかテスト
    func testPrimaryKey() {
        // Verify
        XCTAssertEqual(Task.primaryKey(), "taskId")
    }
}
