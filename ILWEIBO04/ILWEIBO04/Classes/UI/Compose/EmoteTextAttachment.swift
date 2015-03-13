//
//  EmoteTextAttachment.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/13.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit

///  图文混排 -  自定义NSTextAttachment
///  快速获取一个带图像的的属性文本，增加属性emoticonString用来记录表情在模型中对应的字符串

class EmoteTextAttachment: NSTextAttachment {
   //用来记录表情在模型中对应的字符串
    var emoticonString : String?
    
    //返回一个 属性字符串
    class func attributeString(emoticon : Emoticon, _ height : CGFloat) -> NSAttributedString{
        //定义附件，相当于一个独立字符，可以使用删除按钮直接删除
        //设置图像附件
        var attachment = EmoteTextAttachment()
        attachment.image = UIImage(contentsOfFile: emoticon.imagePath!)
        
        //记录对应的文本符号
        attachment.emoticonString = emoticon.chs
        
        //设置附件的大小
        attachment.bounds = CGRectMake(0, -5, height, height)
        
        //创建属性文本，把图像添加到该文本中
        return NSAttributedString(attachment: attachment)
        
    }
    
    
}
