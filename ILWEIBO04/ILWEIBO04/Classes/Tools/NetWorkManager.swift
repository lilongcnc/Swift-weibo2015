//
//  NetWorkManger.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/3.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import Foundation

//我们需要 隔离，避免之后第三方框架不支持之后，大范围的修改
///  这个类是用来隔离第三方框架 和 自己的项目的
class NetWorkManager {
    
    //单例,Swift1.2现在只要写这一句话就可以了
    static let instance = NetWorkManager()
    // 定义一个类变量，提供全局的访问入口,ST1.2之后就不需要了
//    class var sharedManager: NetWorkManager {
//        return instance
//    }
    
    
    //这里是主要的隔离代码
    //定义一个类的完成闭包类型，方便缩减func方法的长度
    typealias Completion = (result : AnyObject?,error : NSError?) -> ()
    //1. 请求头 2.网络地址 3.请求参数 4.完成闭包
    func requestJSON(method :HTTPMethod, _ urlString : String, _ params : [String : String]?, _ completion : Completion){
        ///  请求 JSON 数据
        net.requestJSON(method, urlString, params, completion)
    }

    ///  下载单张图像并且保存到沙盒
    ///
    ///  :param: urlString  urlString
    ///  :param: completion 完成回调
    func downloadImage(urlString: String, _ completion: Completion) {
        net.downloadImage(urlString, completion)
    }
    
    ///  多张图片同时下载
    ///
    ///  :param: urls       图片 URL 数组
    ///  :param: completion 所有图片下载完成后的回调
    func downloadImages(urls: [String], _ completion: Completion) {
        net.downloadImages(urls, completion)
        
    }
    
    ///  异步下载并获取网络图像
    ///
    ///  :param: urlString  urlString
    ///  :param: completion 完成回调
    func requestImage(urlString: String, _ completion : Completion){
        net.requestImage(urlString, completion)
    }
    
    
    /// 完整的 URL 缓存路径
    func fullImageCachePath(urlString: String) -> String {
       return net.fullImageCachePath(urlString)
    }
    
    
    //全局的网络实例，本身也只会被实例化一次
    private let net = SimpleNetWork()
    
}