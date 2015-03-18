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
    //MARK: 函数中，可以直接给形参设置初始值为 maxId : Int = 0
    ///  topId: 是视图控制器中 statues 的第一条微博的 id，topId 和 maxId 之间就是 statuses 中的所有数据
    class func loadStatusesModel(maxId : Int = 0,topId : Int, completiom:(data : StatusesModel?, error :NSError?) -> ()){
        //上拉加载，判断是否可以从本地缓存加在数据
        if maxId > 0 {
            //检查本地数据，如果存在本地数据，那么就从本地加载
            if let result = checkLocalData(maxId){
                println(")))))))))))))))   加载本地数据...")
                //从本地加载了数据，直接回调
                let data = StatusesModel()
                data.statuses = result
                completiom(data: data, error: nil)
                return
            }
            
        }
        
        //下边是直接从网络上加载模型数据
        println("=====> 从网络加载数据")
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
                
                // MARK: 如果 maxId > 0，表示是上拉刷新，将 maxId & topId 之间的所有数据的 refresh 状态修改成 1
                self.updateRefreshState(maxId, topId: topId)
                
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
    
    
    
    //检查本地是否存在小于maxId的连续数据，存在则返回本地数据，不存在则返回nil,然后调用加载网络方法
    class func checkLocalData(maxId: Int) -> [StatusModel]?{
        // 1. 判断 refresh 标记
        let sql = "SELECT count(*) FROM T_Status \n" +
        "WHERE id = (\(maxId) + 1) AND refresh = 1"
        
        if SQLite.sharedSQLite.execCount(sql) == 0 {
            return nil
        }
        println("--> 加载本地缓存数据")
        // TODO: 生成应用程序需要的结果集合直接返回即可！
        // 结果集合中包含微博的数组，同时，需要把分散保存在数据表中的数据，再次整合！
        let resultSQL = "SELECT id, text, source, created_at, reposts_count, \n" +
            "comments_count, attitudes_count, userId, retweetedId FROM T_Status \n" +
            "WHERE id < \(maxId) \n" +
            "ORDER BY id DESC \n" +
        "LIMIT 20"
        
        // 实例化微博数据数组
        var statuses = [StatusModel]()
        /// 查询返回结果集合
        let recordSet = SQLite.sharedSQLite.execRecordSet(resultSQL)
        ///  遍历数组，建立目标微博数据数组
        for record in recordSet {
            // TODO: - 建立微博数据
            statuses.append(StatusModel(record: record as! [AnyObject]))
            println("你好啊啊")
        }
        
        if statuses.count == 0 {
            return nil
        }else{
            return statuses
        }
    }
    
    //修改模型数据的refresh属性 为 1
    class func updateRefreshState(maxId : Int,topId : Int){
        let sql = "UPDATE T_Status SET refresh = 1 \n" + "WHERE id BETWEEN \(maxId) AND \(topId);"
        SQLite.sharedSQLite.execSQL(sql)
    }
    
    
    //保存微博数据到数据库
    class func saveStatusData(statuses : [StatusModel]?) {
        if statuses == nil {
            return
        }
        
        //MARK: 1.事物，可以在存储过程中，把结果回回滚到最开始“ BEGIN TRANSACTION ”的位置
        SQLite.sharedSQLite.execSQL("BEGIN TRANSACTION")
        
        //遍历数据
        for s in statuses! {
            //2. 存储配图记录
            if !StatusPictureURLModel.savePictures(s.id, pictures: s.pic_urls){ //这里不要随便加 ！号
                // 一旦出现错误就“回滚” - 放弃自“BEGIN”以来所有的操作
                println("配图记录插入错误")
                SQLite.sharedSQLite.execSQL("ROLLBACK TRANSACTION")
                //这里要特别注意出错直接跳出
                break
            }
            //3.存储用户记录 - 用户不能左右服务器返回的数据
            if s.user != nil {
                if !s.user!.insertDB(){
                    println("插入用户数据错误")
                    SQLite.sharedSQLite.execSQL("ROLLBACK TRANSACTION")
                    break
                }
            }
            
            //4.存储微博数据
            if !s.insertDB(){ //保存微博数据
                //到这里说明保存失败
                println("保存微博数据失败")
                
                SQLite.sharedSQLite.execSQL("ROLLBACK TRANSACTION")
            }
            
            //5.存储转发的微博数据(用户数据/配图)
            if s.retweeted_status != nil { //或者let a = s.retweeted_status.
                //说明存在转发微博，判断是否存储成功
                if !s.retweeted_status!.insertDB(){
                    println("插入转发微博数据错误")
                    SQLite.sharedSQLite.execSQL("ROLLBACK TRANSACTION")
                    break
                }
            }
        }
        
        //提交事务（到这里说明前边没让回滚）
        SQLite.sharedSQLite.execSQL("COMMIT TRANSACTION")
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
    
    
    ///  使用数据库的结果集合，实例化微博数据
    ///  构造函数，实例化并且返回对象
    init(record: [AnyObject]) {
        // id, text, source, created_at, reposts_count, comments_count, attitudes_count, userId, retweetedId
        id = record[0] as! Int
        text = record[1] as? String
        source = record[2] as? String
        created_at = record[3] as? String
        reposts_count = record[4] as! Int
        comments_count = record[5] as! Int
        attitudes_count = record[6] as! Int
        
        // 用户对象
        let userId = record[7] as! Int
        user = UserInfoModel(pkId: userId)
        
        // 转发微博对象
        let retId = record[8] as! Int
        // 如果存在转发数据
        if retId > 0 {
            retweeted_status = StatusModel(pkId: retId)
        }
        
        // 配图数组
        pic_urls = StatusPictureURLModel.pictureUrls(id)
    }
    
    ///  使用数据库的主键实例化对象
    ///  MARK:convenience 不是主构造函数，简化的构造函数，必须调用默认的构造函数
    convenience init(pkId: Int) {
        // 使用主键查询数据库
        let sql = "SELECT id, text, source, created_at, reposts_count, \n" +
            "comments_count, attitudes_count, userId, retweetedId FROM T_Status \n" +
        "WHERE id = \(pkId) "
        
        let record = SQLite.sharedSQLite.execRow(sql)
        
        self.init(record: record!) //MARK: 这里切记要调用默认的主要的构造函数
    }
    
    
    
    ///  保存微博数据
    func insertDB() -> Bool{
        //用户id或者转发微博的id 是否有值
        let userID = user?.id ?? 0
        let retID = retweeted_status?.id ?? 0
        
        //判断是否数据已经存在，存在的话，就不插入
        var sql = "SELECT count(*) FROM T_Status WHERE id = \(id);"
        if SQLite.sharedSQLite.execCount(sql) > 0{
            return true //有数据
        }
    
        //这里存入微博数据，只使用 INSERT，是因为 INSERT AND REPLACE 会在更新数据的时候，直接将 refresh 重新设置为 0
        sql = "INSERT INTO T_Status \n" +
            "(id, text, source, created_at, reposts_count, comments_count, attitudes_count, userId, retweetedId) \n" +
            "VALUES \n" +
        "(\(id), '\(text!)', '\(source!)', '\(created_at!)', \(reposts_count), \(comments_count), \(attitudes_count), \(userID), \(retID));"
        
        return SQLite.sharedSQLite.execSQL(sql)
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
    ///  使用数据库结果集合实例化对象,并且赋值
    init(record: [AnyObject]) {
        println("\(record[0] as? String)")
        thumbnail_pic = record[0] as? String
    }
    
    ///  如果要返回对象的数组，可以使用类函数
    ///  给定一个微博代号，返回改微博代号对应配图数组，0~9张配图
    class func pictureUrls(statusId: Int) -> [StatusPictureURLModel]? {
        let sql = "SELECT thumbnail_pic FROM T_StatusPic WHERE status_id = \(statusId)"
        let recordSet = SQLite.sharedSQLite.execRecordSet(sql)
        
        // 实例化数组
        var list = [StatusPictureURLModel]()
        for record in recordSet {
            list.append(StatusPictureURLModel(record: record as! [AnyObject]))
        }
        
        if list.count == 0 {
            return nil
        } else {
            return list
        }
    }

    
    
    ///将配图数组存入数据库
    class func  savePictures(statusID : Int,pictures:[StatusPictureURLModel]?) -> Bool{
        if pictures == nil {
            //没有图需要保存，继续后边的存储工作
            return true
        }
        
        //避免图片数据被重复插入，在插入数据前需要先判断一下
        //依据 已存的statusID 是否等于 要存的 statusID
        let sql = "SELECT count(*) FROM T_StatusPic WHERE statusId = \(statusID);"
        if SQLite.sharedSQLite.execCount(sql) > 0{ //TODO .....
            return true
        }
        
        //更新微博图片
        for p in pictures! {
            //保存图片
            if !p.insertToDB(statusID){
                //这里说明 图片保存失败，直接返回
                return false
            }
        }
        
        return true
    }
    
    /// 插入到数据库的方法
    func insertToDB(statusID :Int) -> Bool{
        //把微博id和对应的图片存入，数据库中出现同一个id对应这不同的地址的图片地址
        let sql = "INSERT INTO T_StatusPic (statusId, thumbnail_pic) VALUES (\(statusID), '\(thumbnail_pic!)');"
//        println("--------·\(statusID)----\(thumbnail_pic)")
        return SQLite.sharedSQLite.execSQL(sql)
    }
    
}
