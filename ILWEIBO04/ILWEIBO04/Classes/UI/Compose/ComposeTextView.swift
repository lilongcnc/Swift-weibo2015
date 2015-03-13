//
//  ComposeTextView.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/13.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit

class ComposeTextView: UITextView {

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
    
    
    override func awakeFromNib() {
        //添加占位文本
        self.addSubview(placeHolderLabel)
        //让textView有弹簧效果
        alwaysBounceVertical = true
    }

    
    ///  图文混排 - 这个方法确保textView上显示的使我们选择输入的表情图片
    ///  - 设置带图像的属性文本，替换textView的text，能够显示出表情图像，而不是[晕]
    ///
    ///  - 做法：创建带图像属性文本 替换 textView上的文本。 把选择的表情和文字先组合起来，然后替换 textView上的文字。这样把选择的图片和emoji表情可以显示出来
    ///
    func setTextEmoticon(emoticon : Emoticon) {
        
        //获取属性文本，带图像
        let height = font.lineHeight //MARK： 这里就相当于是self.font...可以省略
        
        var attributeString = EmoteTextAttachment.attributeString(emoticon, height)
        
        //创建可变的属性文本
        var strM = NSMutableAttributedString(attributedString: attributedText)
        //TODO ??????
        strM.replaceCharactersInRange(selectedRange, withAttributedString:attributeString)
        
        //因为上边设置完文本属性之后，字体会发生变化，所以这里要设置整个textVIew文本上字符串的文本属性
        //思路： 让 可变的属性文本 的字体 和 textView 的保持一致！设置之后，就不会影响文本框中的文字属性！
        let range = NSMakeRange(0, strM.length)
        strM.addAttribute(NSFontAttributeName, value: font, range: range)
        
        // 记录当前text光标位置（location 对应光标的位置）
        var loction = selectedRange.location
        //TODO ??????
        // 替换整个textView上的文本（结果会导致光标移动到文本末尾）
        attributedText = strM
        
        //重新设置光标的位置
        selectedRange = NSMakeRange(loction + 1, 0)
    }
    
    
    
    /**
        测试：结果显示虽然图像表情虽然显示到了textView上，但是获取textView.text中确没有，也就是说发送微博的时候，表情无法正常发送，只能发送文字。
        //        println(textView.text)
        //        println(textView.attributedText)
        //        println("------------------------")
        
        遍历属性文本，寻找思路！
        1. 如果是文本，字典中没有 ： NSAttachment
        可以利用 range 提取文字?
        2. 如果是图片，字典中有 ： NSAttachment
        说明：是一个图片 -> 如何把图片变成其对应的模型中的字符串
    */
    
    
    /// 这个方法保证 调用这个方法获取textView上 输入的表情图片对应的字符串 和 输入的文字,然后可以直接发送到服务器
    func fullTextWithImage() -> String{
        // attributedText是什么？？
        
        
        var result = String()
        let textRange = NSMakeRange(0, attributedText.length)
        //遍历文本
        self.attributedText.enumerateAttributesInRange(textRange, options: NSAttributedStringEnumerationOptions.allZeros, usingBlock: { (dict, range, _) -> Void in
            //判断表情是图片还是 字符串
            if let attachment = dict["NSAttachment"] as? EmoteTextAttachment{
                //有图片
//                println("表情符号 \(attachment.emoticonString)")
                result += attachment.emoticonString!
            }else{
                //字符串
                let str = (self.attributedText.string as NSString).substringWithRange(range)
                println(str)
                result += str
            }
            println("完整结果 \(result)")
            
        })
        return result
    }
    
    
    
}
