//
//  MainViewController.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/6.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    @IBOutlet weak var mianTabBar: TabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //添加自控制器
        addControllers()
        
        //弹出发布微博页面
        weak var mainSelf = self //"weak var"解决闭包循环嵌套的问题
        mianTabBar.composedButtonClicked = {
            //创建并弹出发布信息页面
            let sb = UIStoryboard(name: "Compose", bundle: nil)
            
            mainSelf!.presentViewController(sb.instantiateInitialViewController() as! UIViewController, animated: true, completion: nil)
        }
        
    }
    
    // denit 和 OC 中的dealloc功能一样
    deinit {
        println("没有循环引用")
    }
    
    
    
    //添加子控制器
    func addControllers(){
        addChildController("Home", "首页", "tabbar_home", "tabbar_home_highlighted")
        addChildController("Message", "消息", "tabbar_message_center", "tabbar_message_center_highlighted")
        addChildController("Discover", "发现", "tabbar_discover", "tabbar_discover_highlighted")
        addChildController("Profile", "我", "tabbar_profile", "tabbar_profile_highlighted")
        
    }
    //设置自控制器
    func addChildController(sbName : String, _ title: String, _ imageName : String, _ selectedImage : String ){
        let sb = UIStoryboard(name:sbName , bundle: nil)
        let vc = sb.instantiateInitialViewController() as! UINavigationController
        
        vc.title = title
        //MARK：细节:设置颜色,设置了选中状态颜色，不选中状态自动变灰色
        vc.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.orangeColor()], forState: UIControlState.Selected)
        
        //图片不被渲染
        vc.tabBarItem.image = UIImage(named:imageName)
        vc.tabBarItem.selectedImage = UIImage(named: selectedImage)?.imageWithRenderingMode(.AlwaysOriginal)
        
        self.addChildViewController(vc)
    }
    

    
}
