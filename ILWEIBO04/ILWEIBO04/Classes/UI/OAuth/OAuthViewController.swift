//
//  OAuthViewController.swift
//  02-TDD
//
//  Created by apple on 15/2/28.
//  Copyright (c) 2015年 heima. All rights reserved.
//

import UIKit

// 发送通知的请求
let WB_Login_Successed_Notification = "WB_Login_Successed_Notification"


class OAuthViewController: UIViewController {

    let WB_API_URL_String       = "https://api.weibo.com"
    let WB_Redirect_URL_String  = "http://www.baidu.com"
    let WB_Client_ID            = "2105659899"
    let WB_Client_Secret        = "8207985f2251507de62c0e3374d1e6d1"
    let WB_Grant_Type           = "authorization_code"
    
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadAuthPage()
    }
    
    /// 加载授权页面
    func loadAuthPage() {
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(WB_Client_ID)&redirect_uri=\(WB_Redirect_URL_String)"
        let url = NSURL(string: urlString)
        
        webView.loadRequest(NSURLRequest(URL: url!))
    }
}

extension OAuthViewController: UIWebViewDelegate {
    
    //MARK:用不到的方法
    func webViewDidStartLoad(webView: UIWebView) {
//        println(__FUNCTION__)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
//        println(__FUNCTION__)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
//        println(__FUNCTION__)
    }
    
    /// 页面重定向
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        println(request.URL)
        
        //获取accesstoken
        let result = continueWithCode(request.URL!)
        
        if let code = result.code {
            println("可以换 accesstoken \(code)")
            
            let params = ["client_id": WB_Client_ID,
                "client_secret": WB_Client_Secret,
                "grant_type": WB_Grant_Type,
                "redirect_uri": WB_Redirect_URL_String,
                "code": code]
            
            //发送网络请求
            let net  = NetWorkManager.instance
            net.requestJSON(HTTPMethod.POST,  "https://api.weibo.com/oauth2/access_token", params ) { (result, error) -> () in
                
                
                let token = AccessTokenModel(dict: result as! NSDictionary)
                token.saveAccessToken()
                
                //MARK: 获取并保存用户token.access_token之后，我们从登陆界面跳转到主界面
                // 用来通知 告诉 AppDeleagte 进行切换 视图界面
                NSNotificationCenter.defaultCenter().postNotificationName(WB_Login_Successed_Notification, object: nil)
                
//                println(token.access_token)
//                println(result)
            }
        }
        
        if !result.load {
            /**
            如果不加载页面，需要重新刷新授权页面
            直接只写loadAuthPage()，有可能出县多次加载页面
            当我们先点击取消之后，就不能点击授权按钮了，所以我们需要在点击刷新之后，对页面进行刷新
            */
            //只有点击授权页面的取消按钮才重新刷新当前页面
            if result.reloadPage {
                SVProgressHUD.showErrorWithStatus("你真的要拒绝吗？点击授权有更多惊喜哦~~~你懂的", maskType: SVProgressHUDMaskType.Gradient)
                loadAuthPage()
            }
        }
        
        return result.load
    }
    
    ////  根据URL判断是否继续
    ///
    ///  :param: url URL
    ///
    ///  :returns: 1. 是否加载当前页面 2. code(如果有) 3. 是否刷新授权页面
    /// 返回：是否加载，如果有 code，同时返回 code，否则返回 nil
    func continueWithCode(url: NSURL) -> (load: Bool, code: String?,reloadPage : Bool) {
        
        // 1. 将url转换成字符串
        let urlString = url.absoluteString!
        
        // 2. 如果不是微博的 api 地址，都不加载
        if !urlString.hasPrefix(WB_API_URL_String) {
            // 3. 如果是回调地址，需要判断 code
            if urlString.hasPrefix(WB_Redirect_URL_String) {
                if let query = url.query {
                    let codestr: NSString = "code="
                    
                    // 访问新浪微博授权的时候，带有回调地址的url只有两个，一个是正确的，一个是错误的！
                    if query.hasPrefix(codestr as String) {
                        var q = query as NSString!
                        return (false, q.substringFromIndex(codestr.length),false)
                    }else{
                        //说明点击取消，发送的错误的链接，没有code=
                        return (false, nil, true)
                    }
                }
            }
            
            return (false, nil,false)
        }
        
        return (true, nil,false)
    }
}
