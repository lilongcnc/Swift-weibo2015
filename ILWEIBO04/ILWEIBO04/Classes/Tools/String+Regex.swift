//
//  String+Regex.swift
//  HMWeibo04
//
//  Created by apple on 15/3/12.
//  Copyright (c) 2015年 heima. All rights reserved.
//

import Foundation

/// 字符串正则的扩展
extension String {
    
    /// 删除字符串中 href 的引用
    //MARK: 返回String，用 xxx.text接收
    func removeHref() -> String? {
        
        // 0. pattern 匹配方案 - 要过滤字符串最重要的依据
        // <a href="http://www.xxx.com/abc">XXX软件</a>
        // () 是要提取的匹配内容，不使用括号，就是要忽略的内容
        let pattern = "<a.*?>(.*?)</a>"
        
        // 1. 定义正则表达式
        // DotMatchesLineSeparators 使用 . 可以匹配换行符
        // CaseInsensitive 忽略大小写
        let regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive | NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)!
        
        // 2. 匹配文字
        // firstMatchInString 在字符串中查找第一个匹配的内容
        // rangeAtIndex 函数是使用正则最重要的函数 -> 从 result 中获取到匹配文字的 range
        // index == 0，取出与 pattern 刚好匹配的内容
        // index == 1，取出第一个()中要匹配的内容
        // index 可以依次递增，对于复杂字符串过滤，可以使用多几个 ()
        let text = self as NSString
        let length = text.length
        // 提示：不要直接使用 String.length，包含UNICODE的编码长度，会出现数组越界
//        let length = self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        
        if let result = regex.firstMatchInString(self, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, length)) {
            // 匹配到内容
            
            println(result.rangeAtIndex(0))
            println(text.substringWithRange(result.rangeAtIndex(0)))
            
            println(result.rangeAtIndex(1))
            println(text.substringWithRange(result.rangeAtIndex(1)))
            
            return text.substringWithRange(result.rangeAtIndex(1))
        }
        
        return nil
    }
    
    /// 过滤表情字符串，生成属性字符串
    /**
        1. 匹配所有的 [xxx] 的内容
        2. 准备结果属性字符串
    
        3. 倒着遍历查询到的匹配结果
            3.1 用查找到的字符串，去表情数组中查找对应的表情对象
            3.2 用表情对象生成属性文本
            3.3 使用 图片 attachment 替换结果字符串中 range 对应的 文本
    
        4. 返回结果
    */

    //MARK: 返回NSAttributedString，用 xxx.attributedText接收
    func emoticonString() -> NSAttributedString? {
        //
        let pattern = "\\[(.*?)\\]"
        
        let regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive | NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)!
        
        //多个匹配查询，返回任意格式 数组 [AnyObjects]
        let text = self as NSString
        let checkingResultsArr = regex.matchesInString(self, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, text.length))
        
        
        //把当前的字符串 转化成 属性文本，方便下边直接替换
        var attributeString = NSMutableAttributedString(string: self)
        
        //反着遍历，匹配结果
        for var i = checkingResultsArr.count-1; i >= 0; i-- {
            
            let result = checkingResultsArr[i] as! NSTextCheckingResult
            
            //获取匹配到的结果：表情图像对应的匹配的结果 [xxx]
            let str = text.substringWithRange(result.rangeAtIndex(0))
            //获取到[xxx] 在 模型 中对应的模型数据
            let e = searchEmoticon(str)
            
            //xxx.png不为空的话
            if e?.png != nil {
                //生成图像附件，替换属性文本
                let attString = EmoteTextAttachment.attributeString(e!, 18)
                
                //生成的属性文本 替换 当前的字符串属性文本
                attributeString.replaceCharactersInRange(result.rangeAtIndex(0), withAttributedString: attString)
            }
        }
        //返回替换好的 属性文本
        return attributeString
    }

    
    //在表情列表中 查找 对应的表情图像对象
    private func searchEmoticon(str : String) -> Emoticon? {
        //从模型类中获取全部的表情对象数据
        let emoticons = EmoticonList.sharedEmoticonList.emoticons
        
        //遍历数据
        var emoti : Emoticon?
        
        for e in emoticons {
            // 判断 str 和 数组中的 emoticon.chs 是否匹配
            if e.chs == str {
                emoti = e
                break
            }
        }
        return emoti
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
