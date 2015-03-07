//
//  AccessTokenModel.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/5.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import Foundation

/**
AccessToken 是后续操作的关键点
*/

class AccessTokenModel : NSObject,NSCoding{
    ///  用于调用access_token，接口获取授权后的access token。
    var access_token : String?
    ///  access_token的生命周期，单位是秒数。
    ///  从微博服务器返回的 token 是有有效期的。
    ///  在有效期内，不需要再进行登录操作
    ///  如果是开发者自己，时间是 5 年，如果是其他用户，时间是 2/3 天
    ///  如果不是在有效期，需要让用户重新登录！
    var expires_in : NSNumber? {
        didSet{
            //在set方法中给过期日期赋值
            expiresDate = NSDate(timeIntervalSinceNow: expires_in!.doubleValue)
            println("生命周期：\(expiresDate)")
        }
    }
    
    //自定义属性：token的过期日期
    var expiresDate : NSDate?
    //自定义属性：是否过期
    var isExpired : Bool? {
        return expiresDate?.compare(NSDate())  == NSComparisonResult.OrderedAscending
    }
    
    
    ///  access_token的生命周期（该参数即将废弃，开发者请使用expires_in）。
    var remind_in: NSNumber?
    
    // 构造函数一旦写了， init会被忽略
    //KVC,给属性赋值
    init(dict: NSDictionary) {
        super.init()
        //kvc赋值
        self.setValuesForKeysWithDictionary(dict as [NSObject : AnyObject])
    }
    
    
    ///  当前授权用户的ID号，可以通过这个 id 获取用户的进一步信息
    ///  整数类型如果要归档&接档，需要使用 Int 类型，NSNumber
    var uid : Int = 0
    
    // 重载init方法
//    override init() { }
    /**
    归档：遵守NSCoding 实现两个方法
    
    */
    //MARK ： 友情提示，我们在改变归档的格式的时候，可能会出现错误。这个时候把归档文件删除掉重新创建就可以了
    //归档方法
    func encodeWithCoder(encoder: NSCoder) {
        //MARK: 我们在OC中是使用的 k:v对应的写法，我们不带k的话，会自动默认用和属性姓名一样的做键值
        encoder.encodeObject(access_token)
        encoder.encodeObject(expiresDate)
        
        //如果是基本数据类型，需要指定    这里uid是Int型
        encoder.encodeInteger(uid, forKey: "uid")
    }
    
    //解档方法,加一个required
    // required 的构造函数不能写在 extension分类方法中
    required init(coder decoder: NSCoder) {
        access_token = decoder.decodeObject() as? String
        expiresDate = decoder.decodeObject() as? NSDate
        
        //基本数据类型
        uid = decoder.decodeIntegerForKey("uid")
    }
    
    
    //获取保存在沙盒的路径
    class func tokenPath() -> String {
        var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last as! String
        
        path = path.stringByAppendingPathComponent("WBToken.plist")
        
        return path
    }
    
    //将数据保存到沙盒
    func saveAccessToken() {
        NSKeyedArchiver.archiveRootObject(self, toFile: AccessTokenModel.tokenPath())
    }
    
    //从沙盒中读取数据
    class func loadAccessToken() -> AccessTokenModel? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(AccessTokenModel.tokenPath()) as? AccessTokenModel
    }
    
}


//extension 是一个分类，分类不允许有存储能力
//如果要打印对象信息，OC 中的 description，在 swift 中需要遵守协议 DebugPrintable
extension AccessTokenModel: DebugPrintable {
    
    //重写 debugDescription 这个方法
    override var debugDescription: String {
        //dictionaryWithValuesForKeys ： 把对象转换为字典
        let dict = self.dictionaryWithValuesForKeys(["access_token", "expiresDate", "uid"])
        return "\(dict)"
    }
    
}



















