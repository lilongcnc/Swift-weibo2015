//
//  StatusesModel.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/6.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//


/**

模型自己封装了 获取模型数据的方法 ，这样减轻了视图控制器的负担

*/

import UIKit

/// 加载微博数据 URL
private let WB_Home_Timeline_URL = "https://api.weibo.com/2/statuses/home_timeline.json"

///  微博数据列表模型
class StatusesModel: NSObject, DictModelProtocol {
    ///  微博记录数组
    var statuses: [StatusModel]?
    ///  微博总数
    var total_number: Int = 0
    ///  未读数量
    var has_unread: Int = 0
    
    //字典转模型方法
    static func customClassMapping() -> [String: String]? {
        return ["statuses": "\(StatusModel.self)"]
    }
    
    
    ///  刷新微博数据 - 专门加载网络数据以及错误处理的回调
    ///  一旦加载成功，负责字典转模型，回调传回转换过的模型数据
    //MARK: 这个方法供外界调用，一定要写class,否则调用到方法不会自己提示出 completiom 闭包
    //MARK: 可以直接初始设置值为 maxId : = 0
    class func loadStatusesModel(maxId : Int = 0,completiom:(data : StatusesModel?, error :NSError?) -> ()){
        
        let net = NetWorkManager.instance
        //获取access_token
        if let token = AccessTokenModel.loadAccessToken()?.access_token {
            
            let params = ["access_token" : token, "max_id" : "\(maxId)"]
            //发送网络请求，获取模型数据
            net.requestJSON(.GET, WB_Home_Timeline_URL, params) { (result, error) -> () in
                
                //处理错误
                if error != nil{
//                    println(error)
//                    SVProgressHUD.showErrorWithStatus("\(error)")
                    //直接回调报错
                    completiom(data: nil, error: error!)
                    return
                }
                
                //字典转模型
                let data = DictModelManager.sharedManager.objectWithDictionary(result as! NSDictionary, cls: StatusesModel.self) as? StatusesModel
                
                //保存微博数据
                self.saveStatusData(data?.statuses)
                
                
                // 如果有下载图像的 url，就先下载图像
                if let urls = StatusesModel.pictureURLs(data?.statuses) { //获取 图像链接数组
                    net.downloadImages(urls) { (result, error) -> () in //这里我们不处理(result, error) 参数，可以换成（ _ ,_ ）
                        // 回调通知视图控制器刷新数据
                        completiom(data: data, error: nil)
                    }
                }else{
                    
                    //回调，将结果发送给视图控制器
                    /**
                    报错：fatal error: unexpectedly found nil while unwrapping an Optional value
                    因为 completiom(data: data, error: error!) error加了 ！
                    */
                    completiom(data: data, error: nil)
                    
                }
                
            }
        }
    }
    
    
    
    class func saveStatusData(status : [StatusModel]?) {
        
        
        
    }
    
    
    ///  取出给定的微博数据中 正文的所有图片的 URL 数组
    ///
    ///  :param: statuses 微博数据数组，可以为空
    ///
    ///  :returns: 微博数组中的 url 完整数组，可以为空（为纯文本数据的话，那么就没有图片的url）
    class func pictureURLs(statues : [StatusModel]?) -> [String]?{
        // 判断 微博数组是否有值
        if statues == nil {
            return nil
        }
        
        // 遍历微博模型数组，保存到中间数组
        var list = [String]()
        for statue in statues! {
            // 遍历微博模型数组中的 图像链接数组
            if let pictureURLS = statue.pictureUrls{
                for pictureURL in pictureURLS{
//                    println(pictureURL.thumbnail_pic)
                    list.append(pictureURL.thumbnail_pic!)
                }
            }
        }
        
        // 判断 图像链接数组 是否有值
        if list.count > 0 {
            return list
        }else{
            return nil
        }
    }
}



///  微博模型
class StatusModel: NSObject,DictModelProtocol {
    ///  微博创建时间
    var created_at: String?
    ///  微博ID
    var id: Int = 0
    ///  微博信息内容
    var text: String?
    ///  微博来源
    var source: String?
    
    //自定义属性： 过滤后的微博来源
    var sourceStr : String {
        return source?.removeHref() ?? ""
    }
    
    ///  转发数
    var reposts_count: Int = 0
    ///  评论数
    var comments_count: Int = 0
    ///  表态数
    var attitudes_count: Int = 0
    
    /// 用户信息
    var user: UserInfoModel?
    
    ///  配图数组
    var pic_urls: [StatusPictureURLModel]?
    
    /// 转发微博,如果这个参数有值，就说明有转发的微博。没有就说明是自己发的微博。可以用这个属性来判断 是否转发
    var retweeted_status: StatusModel?
    
    /// 要显示的配图数组
    /// 如果是原创微博，就使用 pic_urls
    /// 如果是转发微博，使用 retweeted_status.pic_urls
    var pictureUrls: [StatusPictureURLModel]? {
        if retweeted_status != nil {
            return retweeted_status?.pic_urls
        } else {
            return pic_urls
        }
    }
    
    
    
    /// 自定义属性： 返回所有的大图链接URL
    var large_pic_Urls : [String]? {
        //MARK : 写get { } 严谨？？？待验证
        get{
            // 使用KVC直接获取 所有的大图链接URL
            let allurls = self.valueForKeyPath("pictureUrls.large_pic") as! [String]
            return allurls
        }
    }
    
    
    //字典转模型方法
    static func customClassMapping() -> [String : String]? {
        return ["pic_urls":"\(StatusPictureURLModel.self)","user":"\(UserInfoModel.self)","retweeted_status":"\(StatusModel.self)"]
    }

}

///  微博配图模型
class StatusPictureURLModel: NSObject {
    ///  缩略图 URL
    var thumbnail_pic: String? {
        didSet{
            let largeURL = thumbnail_pic!.stringByReplacingOccurrencesOfString("thumbnail", withString: "large")
            large_pic = largeURL
        }
    }
    
    /// 大图 URl
    var large_pic: String?
    
}
