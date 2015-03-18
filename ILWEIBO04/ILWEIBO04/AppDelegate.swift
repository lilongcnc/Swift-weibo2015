//
//  AppDelegate.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/2.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        //测试打开数据库
        SQLite.sharedSQLite.openDatabase("reade.db")
        
        
        
        // 检查沙盒中是否已经保存的 token
        // 如果已经存在 token，应该直接显示主界面
        if let token = AccessTokenModel.loadAccessToken() {
            println(token.debugDescription)
            println(token.uid)
            
            showMainControllerView()
        } else {
            // 添加通知监听，监听用户登录成功
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMainInterface", name: WB_Login_Successed_Notification, object: nil)
        }
        
        return true
    }
    
    ///  测试上拉刷新数据的代码
    func demoLoadData() {
        //测试存储图片数据
        // 加载数据测试代码 － 第一次刷新，都是从服务器加载数据！
        StatusesModel.loadStatusesModel(maxId: 0, topId: 0) { (data, error) -> () in
            
            // 第一次加载的数据
            if let statuses = data?.statuses {
                // 模拟上拉刷新
                // 取出最后一条记录中的 id，id -1 -> maxId
                let mId = statuses.last!.id
                let tId = statuses.first!.id
                println("maxId \(mId) ---- topId \(tId)")
                
                // 上拉刷新
                 StatusesModel.loadStatusesModel(maxId: (mId - 1 ), topId: tId, completiom: { (data, error) -> () in
                    println("第一次上拉刷新结束")
                    
                    // 再一次加载的数据
                    if let statuses = data?.statuses {
                        // 模拟上拉刷新
                        // 取出最后一条记录中的 id，id -1 -> maxId
                        let mId = statuses.last!.id
                        let tId = statuses.first!.id
                        println("2222 maxId \(mId) ---- topId \(tId)")
                        
                        // 上拉刷新
                          StatusesModel.loadStatusesModel(maxId: (mId - 1), topId: tId, completiom: { (data, error) -> () in
                                println("第二次下拉刷新")
                          })
                    }
                })
            }
        }
    }
    
    
//        println("\(EmoticonsSection.loadEmoticons())")
        
//        //从沙盒中获取 access_token,有则直接跳转到 主界面
//        if let token = AccessTokenModel.loadAccessToken(){
////            println(token.debugDescription)
////            println(token.uid)
//            //跳转到主界面
//            showMainControllerView()
//        }else{
//            //通知监听 是否登陆成功
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMainControllerView", name: WB_Login_Successed_Notification, object: nil)
//        }
    
//        return true


    
    //现实主界面
    func showMainControllerView() {
        //成功登陆后销毁通知
        NSNotificationCenter.defaultCenter().removeObserver(self, name: WB_Login_Successed_Notification, object: nil)
        
        //设置现实主界面
        let sb = UIStoryboard(name: "Main", bundle: nil)
        window!.rootViewController = sb.instantiateInitialViewController() as? UIViewController
        
        //设置 导航条nvi 的外观
        setNviAppearance()
    }
    

    func setNviAppearance() {
        //设置所有的tintColor
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
    }
}

/**
let net = SimpleNetWork()
//        net("http://ww1.sinaimg.cn/thumbnail/6ba75546jw1epwgd1pfh8j20dh0c93zg.jpg", { (result, error) -> () in
//        })


let urls = ["http://ww1.sinaimg.cn/thumbnail/62c13fbagw1epuww0k4xgj20c8552b29.jpg",
"http://ww3.sinaimg.cn/thumbnail/e362b134jw1epuxb47zoyj20dw0ku421.jpg",
"http://ww1.sinaimg.cn/thumbnail/e362b134jw1epuxbaym1sj20ku0dwgpu.jpg",
"http://ww2.sinaimg.cn/thumbnail/e362b134jw1epuxbdhirmj20dw0kuae8.jpg"]

println(net.downloadImages(urls, { (result, error) -> () in
println("OK")
}))

*/
