//
//  ComposeController.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/6.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit

class ComposeController: UIViewController {

    //发送微博按钮
    @IBOutlet weak var sendBtn: UIBarButtonItem!
    // 发送微博撰写
    @IBOutlet weak var textView: UITextView!
    //底部工具条的 底部视图
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    //手动添加 提醒文字Label
    lazy var placeHolderLabel : UILabel = {
        let label = UILabel()
        label.text = "分享新鲜事..."
        label.textColor = UIColor.lightGrayColor()
        label.font = UIFont.systemFontOfSize(18)
        label.frame = CGRectMake(5, 8, 0, 0)
        label.sizeToFit()
        
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置 UI
        setupUI()

        // 注册通知
        registerNotification()
    }
    
    deinit {
        //相当于是removeAll .移除当前控制器上的所有观察者
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //注册text监听
    func registerNotification(){
        //注册键盘通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardFrameChange:", name: UIKeyboardWillChangeFrameNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardFrameChange:", name: UIKeyboardWillHideNotification, object:nil)
    }
    
    //设置textView的初始状态
    func setupUI() {
        textView.addSubview(placeHolderLabel)
        //让textView有弹簧效果
        textView.alwaysBounceVertical = true
        
        //获取焦点
        textView.becomeFirstResponder()
    }
    
    ///  处理底部视图随键盘一起弹出
    func keyBoardFrameChange(notificaton : NSNotification) {
        //不进入if 判断语句的话，height为0，相当于视图跟随键盘退下的效果
        var height: CGFloat = 0
        var duration = 0.25

        if notificaton.name == UIKeyboardWillChangeFrameNotification {
            //键盘弹起
            //注意这个userInfo
            let rect = (notificaton.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
             height = rect.size.height
             duration = (notificaton.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        }
        
        toolBarBottomConstraint.constant = height
        
        //刷新控件显示
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        
        

        
        
    }

    

    //懒加载表情视图控制器
    lazy var emoticonsVC : EmoticonsViewController = {
        let sb = UIStoryboard(name: "Emoticons", bundle: nil)
        return sb.instantiateInitialViewController() as! EmoticonsViewController
    }()
    
    ///  发送表情按钮点击
    @IBAction func emoticonsOnClick() {
        //MARK：切换文本框的输入视图的时候，我们必须保证文本框当前没有处于编辑状态
        //解除文本框编辑状态
          textView.resignFirstResponder()
        
        //可以根据  textView.inputView == nil来判断是否当前的输入视图是否是默认的键盘。 等于nil的话，说明就是默认的键盘
        if textView.inputView == nil {
            //切换输入视图
            textView.inputView = emoticonsVC.view
            
        }else {
            textView.inputView = nil
        }
        //设置处于编辑状态
          textView.becomeFirstResponder()
    }
    
    ///  退出发送页面
    @IBAction func backBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    ///  发送微博
    @IBAction func publicMessage(sender: AnyObject) {
        println("发布微博")
        //退出第一响应者
        textView.resignFirstResponder()
        
        let urlString = "https://api.weibo.com/2/statuses/update.json"
        
        if let token = AccessTokenModel.loadAccessToken()?.access_token {
            
            let params = ["access_token":token,"status":textView.text!]
            //MARK: 重点提示：params中一定都要确保有值，否则会提示 .POST 不正确！
            NetWorkManager.instance.requestJSON(HTTPMethod.POST, urlString, params) { (result, error) -> () in
                if result != nil {
                    SVProgressHUD.showInfoWithStatus("微博发送成功")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    //TODO 其实这里应该调用刷新用户数据
                    
                }
            }
        }
        
    }
}


//文本框代理
extension ComposeController : UITextViewDelegate {
    //这个方法能够在用户输入之前进行判断，根据返回值来决定是否允许用户能够输入
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
       /**
        textView.text： 文本框已经输入的文字
        text: 用户新输入的文字
        Bool返回值： 是否允许用户可以输入到文本框上
        */
        
        //删除或者其他的功能键如何判断？
        //最新输入的文本为空，则是删除
//        if text.isEmpty {
//            println("正在删除...")
//            return true
//        }
        
        // 在 textView 控件中，没有代理方法监听回车键！
        // 以下代码是在 textView 中拦截回车键的办法
        if text == "\n"{
            println("回车键")
        }
    
        //限制微博发文字符为140字以内
        let wordNumber = textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) +
        text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        
        if wordNumber >= 140 {
            return false
        }
        
        return true
    }
    
    ///  文本框变化完成的方法，这个方法中可以监听文本框的输入
    func textViewDidChange(textView: UITextView) {
//        println("\(textView.text)")
        //提示输入语
        placeHolderLabel.hidden = !textView.text.isEmpty
        //发送按钮可用
        sendBtn.enabled = !textView.text.isEmpty
    }
    
    
    
    ///  当上下拖拽textView时候，键盘退下
    //MARK: 这里需要可开启textView中scrolView的拖拽功能才可以 / 注意在调用频率比较少来调用
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
    
}



