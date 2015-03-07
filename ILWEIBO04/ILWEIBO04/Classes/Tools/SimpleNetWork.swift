//
//  SimpleNetWork.swift
//  SimpleNetwork
//
//  Created by 李龙 on 15/3/3.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import Foundation


//枚举类型
enum HTTPMethod : String{
    case GET = "GET"
    case POST = "POST"
}

class SimpleNetWork {

//MARK: ———————下载网络图片 ——————————
    // ————————————————————  下载网络图片 ——————————————————————————————
    
    ///  异步下载并获取网络图像
    ///
    ///  :param: urlString  urlString
    ///  :param: completion 完成回调，返回的是UIImage图像
    func requestImage(urlString: String, _ completion : Completion){
        // 1. 调用 download 下载图像，如果图片已经被缓存过，就不会再次下载
        downloadImage(urlString) { (_, error) -> () in
            // 2.1 错误处理
            if error != nil {
                completion(result: nil, error: error)
                
            } else {
                // 2.2 图像是保存在沙盒路径中的，文件名是 url ＋ md5
                let path = self.fullImageCachePath(urlString)
                // 将图像从沙盒加载到内存
                var image = UIImage(contentsOfFile: path)
                
                // 提示：尾随闭包，如果没有参数，没有返回值，都可以省略！
                dispatch_async(dispatch_get_main_queue()) {
                    //讲图片返回去
                    completion(result: image, error: nil)
                }
            }
         }
        
        
    }
    
    
    ///  多张图片同时下载
    ///  解决关键： 所有图片下载完后一起返回，怎么做到呢？？？GCD-调度组解决！！
    ///   下载多张图片这里，我们没有处理错误。因为比如我们下载很多图片，其中一张有错误，但是我们后边的图片还是要下载的
    ///
    ///  :param: urls       图片 URL 数组
    ///  :param: completion 所有图片下载完成后的回调
    func downloadImages(urls: [String], _ completion: Completion) {
        
        // 希望所有图片下载完成，统一回调！
        
        // 利用调度组统一监听一组异步任务执行完毕 
        //（create - leave要一一对应）
        let group = dispatch_group_create()
        
        // 遍历数组
        for url in urls {
            // 进入调度组
            dispatch_group_enter(group)
            downloadImage(url) { (result, error) -> () in
                // 一张图片下载完成，会自动保存在缓存目录
                // 下载多张图片的时候，有可能有些有错误，有些没错误！
                // 暂时不处理
                
                // 离开调度组
                dispatch_group_leave(group) //这里必须downloadImage方法中回调complete才能执行leave,所以下边记得回调
            }
        }
        
        // 在主线程回调
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            // 所有任务完成后的回调
            completion(result: nil, error: nil)
        }
    }

    
    
    
    
    ///  下载单张图像并且保存到沙盒
    ///
    ///  :param: urlString  urlString
    ///  :param: completion 完成回调
    func downloadImage(urlString: String, _ completion: Completion) {
        
        // 1. 获取缓存路径
        let path = fullImageCachePath(urlString)
        
        // 2.1 缓存检测，如果文件已经下载完成直接返回
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            println("\(urlString) 图片已经被缓存")
            completion(result: nil, error: nil)
            return
        }
        
        // 3. 下载图像
        if let url = NSURL(string: urlString) {
            //MARK: NSURlSession的方法全都是异步的，这个downloadTaskWithURL也是
            self.session!.downloadTaskWithURL(url) { (location, _, error) -> Void in
                
                // 错误处理
                if error != nil {
                    completion(result: nil, error: error)
                    return
                }
                
                // 将文件复制保存到缓存路径文件夹下
                NSFileManager.defaultManager().copyItemAtPath(location.path!, toPath: path, error: nil)
                
                // 直接回调，不传递任何参数
                completion(result: nil, error: nil)
                }.resume()
        }else{
            //如果if判断中链接没有办法从 “NSURL(string: ” 那么也一定要执行回调，把调度组leave掉。
            let error = NSError(domain: SimpleNetWork.errorDomain, code: -1, userInfo: ["error" : "无法创建url"])
            completion(result: nil, error: error)
        }
    }
    
    
    //获取cache的完整的存储路径
    private var cachePath : String? = {
        
        //1.获取路径
        var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory,  NSSearchPathDomainMask.UserDomainMask, true).last as! String
        path = path.stringByAppendingPathComponent(imageCachePath)
        
        //2.检查路径是否存在
        
        var isDirectory: ObjCBool = true
        let exists = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory)
        
        //3.如果有和文件夹 同名的文件，删除掉
        //注意要判断是不是文件
        if exists && !isDirectory {
            
            NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
        }
        
        //4.创建目录文件夹，如果有就不创建
        // withIntermediateDirectories -> 是否智能创建层级目录
        NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
        
//        println(path)
        
        return path
    }()
    
    
    ///  完整的 URL 缓存路径
    func fullImageCachePath(urlString: String) -> String {
        var path = urlString.md5
        return cachePath!.stringByAppendingPathComponent(path)
    }
    
    //文件夹名字
    private static let imageCachePath = "com.neusoft.imagecache"
    
//MARK: ———————————  发送网络请求，获取json数据  ——————————————————
    // ————————————————————   发送网络请求，获取json数据  ——————————————————————————————
    
    //定义一个闭包完成类型
    typealias Completion = (result : AnyObject?, error : NSError?) -> ()
    
    ///  请求 JSON 数据
    ///
    ///  :param: method     HTTP 访问方法
    ///  :param: urlString  urlString
    ///  :param: params     可选参数字典
    ///  :param: completion 完成回调
    func requestJSON(method : HTTPMethod, _ urlString : String, _ params : [String : String]?,_ completion : Completion){

    
        if let request = request(method, urlString, params) {
            
            //访问网络，本身的回调方法是异步的
            session!.dataTaskWithRequest(request, completionHandler: { (data, _, error) -> Void in
                
                //如果有错误，直接回调，将网络访问的错误传回
                if error != nil {
                    completion(result: nil, error: error)
                    return
                }
                
                
                //反序列化->转化成字典或者数组
                //TODO NSJSONReadingOptions.allZeros什么意思？
                let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil)
                
                //判断反序列化是否成功
                if json == nil {
                    let error = NSError(domain: SimpleNetWork.errorDomain, code: -1, userInfo: ["error" : "反序列化失败"])
                    completion(result: nil, error: error)
                    
                }else{
                    //有结果,这里是在主队列dispatch_get_main_queue返回
                    dispatch_async(dispatch_get_main_queue(), { () in
                        completion(result: json, error: nil)
                    })
                }
                
            }).resume()
            
            return
        }
        
        
        // 到这里的话，网络请求没有创建成功，应该生成一个错误，提供给其他的开发者
        /**
        domain: 错误所属领域字符串 com.itheima.error
        code: 如果是复杂的系统，可以自己定义错误编号
        userInfo: 错误信息字典
        */
        let error = NSError(domain: SimpleNetWork.errorDomain, code: -1, userInfo: ["error" : "请求建立失败"])
        completion(result: nil, error: error)
        
    }
    
    // 类属性，跟对象无关
    private static let errorDomain = "com.itheima.error"
    
   //  -----------准备工作-------------
    
    
    ///  返回网络访问请求
    ///
    ///  :param: method    HTTP访问方法
    ///  :param: urlString NSURL
    ///  :param: params    可选字典
    ///
    ///  :returns: 网络请求
//    func request(method : HTTPMethod, _ urlString: String , _ params : [String : String]?) ->  NSURLRequest?{
//        //isEmpty 是 "" 和 nil
//        if urlString .isEmpty {
//            return nil
//        }
//        
//        var urlStr = urlString
//        var r : NSMutableURLRequest?
//        
//        if method == .GET{
//            let query = queryString(params)
//            
//            if query != nil {
//                urlStr = urlString + "?" + query!
//            }
//            
//            r = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
//            
//        }else{
//            
//            //设置请求体,POST必须有请求体
//            if let query = queryString(params) {
//                r = NSMutableURLRequest(URL: NSURL(string: query)!)
//                
//                //设置请求方法
//                // swift 语言中，枚举类型，如果要去的返回值，需要使用一个 rawValue
//                r!.HTTPMethod = method.rawValue
//                
//                //设置请求数据体
//                //dataUsingEncoding 转成二进制数据 （HTTPBody: NSData）
//                r!.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
//                
//                
//                println("-----------\(r)")
//            }
//        }
//        
//        return r
//    }
    
    ///  返回网络访问的请求
    ///
    ///  :param: method    HTTP 访问方法
    ///  :param: urlString urlString
    ///  :param: params    可选参数字典
    ///
    ///  :returns: 可选网络请求
    private func request(method: HTTPMethod, _ urlString: String, _ params: [String: String]?) -> NSURLRequest? {
        
        // isEmpty 是 "" & nil
        if urlString.isEmpty {
            return nil
        }
        
        // 记录 urlString，因为传入的参数是不可变的
        var urlStr = urlString
        var r: NSMutableURLRequest?
        
        if method == .GET {
            // URL 的参数是拼接在URL字符串中的
            // 1. 生成查询字符串
            let query = queryString(params)
            
            // 2. 如果有拼接参数
            if query != nil {
                urlStr += "?" + query!
            }
            
            // 3. 实例化请求
            r = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
        } else {
            
            // 设置请求体，提问：post 访问，能没有请求体吗？=> 必须要提交数据给服务器
            if let query = queryString(params) {
                r = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
                
                // 设置请求方法
                // swift 语言中，枚举类型，如果要去的返回值，需要使用一个 rawValue
                r!.HTTPMethod = method.rawValue
                
                // 设置数据提
                r!.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            }
        }
        
        return r
    }
    
    
 
    //生成可查询的字符串
    private func queryString(params : [String : String]?) -> String?{//可能为空
        if params == nil {
            return nil
        }
        
        //数组使用技巧
        //实例化一个数组
        var array = [String]()
        //遍历字典，拼接字符串
        for (k,v) in params! {
            //转译： stringByAddingPercentEscapesUsingEncoding这个方法的返回值是 ？不确定，所以要加 ！
            let str = k + "=" + v.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            array.append(str)
        }
        
        //MARK: 数组使用技巧
        //join函数：array的子元素之间用&拼接
        return join("&", array)
    }
    
    
    //做框架，必须向外提供一个创建的构造函数
//    public init(){    }
    
    
    ///  全局网络会话，提示，可以利用构造函数，设置不同的网络会话配置
    private lazy var session : NSURLSession? = {
        return NSURLSession.sharedSession()
    }()
    
}