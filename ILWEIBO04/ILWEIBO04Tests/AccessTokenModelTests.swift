//
//  AccessTokenModelTests.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/5.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit
import XCTest

class AccessTokenModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIsExpired() {
        var dict = ["access_token": "2.00ml8IrFcgjGyC3a36539d80SOuztB",
            "expires_in": 1,
            "remind_in": 157679999,
            "uid": 5365823342]
        
        var token = AccessTokenModel(dict: dict)
        println(token.isExpired)
        
        dict = ["access_token": "2.00ml8IrFcgjGyC3a36539d80SOuztB",
            "expires_in": 0,
            "remind_in": 157679999,
            "uid": 5365823342]
        
        token = AccessTokenModel(dict: dict)
        println(token.isExpired)
        
        dict = ["access_token": "2.00ml8IrFcgjGyC3a36539d80SOuztB",
            "expires_in": -1,
            "remind_in": 157679999,
            "uid": 5365823342]
        
        token = AccessTokenModel(dict: dict)
        println(token.isExpired)
    }


}
