//
//  ComposeController.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/6.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit

class ComposeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
   

    @IBAction func publicMessage(sender: AnyObject) {
        println("发布微博")
    }
}
