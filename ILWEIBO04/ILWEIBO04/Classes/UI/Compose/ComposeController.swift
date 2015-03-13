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
    @IBOutlet weak var textView: ComposeTextView!
    //底部工具条的 底部视图
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 注册通知
        registerNotification()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //MARK: 获取焦点，键盘弹起。（放到这里比放到viewDidLoad中更合适，视图完全显示完后再弹出键盘）
        textView.becomeFirstResponder()
    }
    
    
    deinit {
        //相当于是removeAll .移除当前控制器上的所有观察者
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //注册text监听
    func registerNotification(){
        //注册键盘通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardFrameChange:", name: UIKeyboardWillChangeFrameNotification, object:nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardFrameChange:", name: UIKeyboardWillHideNotification, object:nil)
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
            toolBarBottomConstraint.constant = height
            
            //刷新控件显示
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            
        }else{
             toolBarBottomConstraint.constant = height
        }
        
       
    }


    //懒加载表情视图控制器
    lazy var emoticonsVC : EmoticonsViewController = {
        let sb = UIStoryboard(name: "Emoticons", bundle: nil)
        let vc =  sb.instantiateInitialViewController() as! EmoticonsViewController
        //MARK : 设置代理
        vc.delegate = self
        
        return vc
    }()
    
    ///  发送表情按钮点击
    @IBAction func emoticonsOnClick() {
        //MARK：切换文本框的输入视图的时候，我们必须保证文本框当前没有处于编辑状态
        //解除文本框编辑状态
        self.textView.resignFirstResponder()
        
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
        //1.退出键盘
        self.textView.resignFirstResponder()
        
        //2.销毁当前控制器
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    ///  发送微博
    @IBAction func publicMessage(sender: AnyObject) {
        println("发布微博")
        //退出第一响应者
        textView.resignFirstResponder()
        
        let urlString = "https://api.weibo.com/2/statuses/update.json"
        
        if let token = AccessTokenModel.loadAccessToken()?.access_token {
            
            let params = ["access_token":token,"status":textView.fullTextWithImage()]
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


//  遵守EmoticonsViewControllerDelegate协议, (通过 extension)并且实现方法！
extension ComposeController : EmoticonsViewControllerDelegate {
 
    func emoticonsViewControllerDidSelectEmoticon(emoticonsVC: EmoticonsViewController, emoticon: Emoticon) {
//        println("\(emoticon.chs)")
        
        //判断是否点击了删除按钮
        if emoticon.isDeleteButton {
            //MARK: 手动代码，删除后添加的一个文字
            textView.deleteBackward()
        }
        
        //TODO 下边的一段代码也可以优化到模型中，进行判断
        var str : String?
        if emoticon.chs != nil {
            str = emoticon.chs
         } else if emoticon.emoji != nil {
            str = emoticon.emoji
        }
        
        if str == nil {
            return
        }
        
        // 手动调用代理方法 - 判断是否超出了规定长度，还能够能够插入文本
        if textView(textView, shouldChangeTextInRange: textView.selectedRange, replacementText: str!){
            if emoticon.chs != nil {
                //MARK : 添加非emoji表情图片和文字
                
                // 确保选择的表情图片可以显示到textView上
                textView.setTextEmoticon(emoticon)
                
                //手动调用 didChange
                textViewDidChange(textView)
                
            } else if emoticon.emoji != nil {
                //MARK : 添加 emoji表情
                // 会调用 didChange - text 会变化
                // 不会调用 shouldChangeTextInRange - 判断是否需要修改 range 中的内容
                // 应该在用户光标位置“插入”表情文本
                textView.replaceRange(textView.selectedTextRange!, withText: emoticon.emoji!)
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
        //注意1： 这里用lengthOfBytesUsingEncoding(NSUTF8StringEncoding) 来计算长度，不准确
        //注意2： 这textView.text上并没有表情符号的内容
        let len1 = (self.textView.fullTextWithImage() as NSString).length
        let len2 = (text as NSString).length
        if (len1 + len2) >= 140 {
            return false
        }
        
        return true
    }
    
    ///  文本框变化完成的方法，这个方法中可以监听文本框的输入
    func textViewDidChange(textView: UITextView) {
        //TODO 可以进行优化，fullTextWithImage()是一个方法，我们可以让其只运行一次，结果保存到一个属性中。
        
        let fullText = self.textView.fullTextWithImage()
        //提示输入语
        self.textView.placeHolderLabel.hidden = !fullText.isEmpty
        //发送按钮可用
        sendBtn.enabled = !fullText.isEmpty
    }
    
    
    
    ///  当上下拖拽textView时候，键盘退下
    //MARK: 这里需要可开启textView中scrolView的拖拽功能才可以 / 注意在调用频率比较少来调用
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
    
}






/**
表情图片部分早期代码，后边已改动很多。
//定义附件，相当于一个独立字符，可以使用删除按钮直接删除
//设置图像附件
var attachment = NSTextAttachment()
attachment.image = UIImage(named: emoticon.imagePath!)
//设置附件的大小
let height = textView.font.lineHeight
attachment.bounds = CGRectMake(0, -5, height, height)

//创建属性文本，把图像添加到该文本中
var attributeString = NSAttributedString(attachment: attachment)

//创建可变的属性文本
var strM = NSMutableAttributedString(attributedString: textView.attributedText)
//TODO ??????
strM.replaceCharactersInRange(textView.selectedRange, withAttributedString:attributeString)

//因为上边设置完文本属性之后，字体会发生变化，所以这里要设置整个textVIew文本上字符串的文本属性
let range = NSMakeRange(0, strM.length)
strM.addAttribute(NSFontAttributeName, value: textView.font, range: range)

// 记录当前text光标位置（location 对应光标的位置）
var loction = textView.selectedRange.location
//TODO ??????
// 替换整个textView上的文本（结果会导致光标移动到文本末尾）
textView.attributedText = strM

//重新设置光标的位置
textView.selectedRange = NSMakeRange(loction + 1, 0)

println(textView.text)
*/



