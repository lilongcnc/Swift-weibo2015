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
        
        
        
//        println("\(EmoticonsSection.loadEmoticons())")
        
        //从沙盒中获取 access_token,有则直接跳转到 主界面
        if let token = AccessTokenModel.loadAccessToken(){
//            println(token.debugDescription)
//            println(token.uid)
            //跳转到主界面
            showMainControllerView()
        }else{
            //通知监听 是否登陆成功
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMainControllerView", name: WB_Login_Successed_Notification, object: nil)
        }
        
        return true
    }

    
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
