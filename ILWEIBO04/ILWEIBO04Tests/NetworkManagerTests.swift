//
//  NetworkManagerTests.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/4.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit
import XCTest

class NetworkManagerTests: XCTestCase {

    
    let net = NetWorkManager()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    //测试创建的单例是否是为同一个
    func testSingleton() {
        let manager1 = NetWorkManager.instance
        let manager2 = NetWorkManager.instance
        
        XCTAssert(manager1 === manager2, "创建的对象实例不一样")
        
    }

    
    
    

}
