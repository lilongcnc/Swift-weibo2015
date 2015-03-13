//
//  Emoticons.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/12.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import Foundation

/**
这个模型类，我们不用字典转模型。因为嵌套的比较深，我们用字典转模型的话，会比自己手动赋值多写。刀哥验证的，我自己没验证

这里要注意，emoji表情和浪小花表情是不一样的，一个是图片，一个是字符串
*/


//表情分组类  emtioncons.plist
class EmoticonsSection {
    //如果我们在构造函数当中给对象属性设置初始值，属性就不用 ？
    
    //分组名称
    var name : String
    var type : String
    var path : String
    /// 表情符号的数组(每一个 section中应该包含21个表情符号，这样界面处理是最方便的)
    /// 然后21个表情符号中，最后一个删除(就不能使用plist中的数据)
    var emoticons : [Emoticon]
/**
    使用字典实例化对象
    构造函数，能够给对象直接设置初始数值，凡事设置过的属性，都可以是必选项
    在构造函数中，不需要 super，直接给属性分配空间&初始化
    */
    init(dict : NSDictionary) {
        //使用字典
        name = dict["emoticon_group_name"] as! String
        type = dict["emoticon_group_type"] as! String
        path = dict["emoticon_group_path"] as! String
        
        //初始化符号数组
        emoticons = [Emoticon]()
    }
    
    
    class func loadEmoticons() -> [EmoticonsSection]{
        //1.获取路径,创建数组
        let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Emoticons/emoticons.plist")
        let path1 = NSBundle.mainBundle().pathForResource("emoticons.plist", ofType: nil)
        var array = NSArray(contentsOfFile: path)!
        
        //2.按照type,对数组进行排序，返回新的数组
        array = array.sortedArrayUsingComparator({ (dict1, dict2) -> NSComparisonResult in
            //获取比较的数据
            let type1 = dict1["emoticon_group_type"] as! String
            let type2 = dict2["emoticon_group_type"] as! String
            
            //返回比较的结果
            return type1.compare(type2)
        })
        
        //3.遍历array模型数组，把array指代的具体的模型数据拆开赋值
        var result = [EmoticonsSection]()
        for dict in array as! [NSDictionary] {
            //MARK: 进入 group_path 对应的目录进一步加载数据
            result += loadEmoticons(dict)
        }
        
        return result
    }
    
    //从info.plist 中的字典中获取 表情符号数组
    class func loadEmoticons(dict : NSDictionary) -> [EmoticonsSection]{
         // 1. 根据 dict 中的 group_path 加载不同目录中的 info.plist
        let group_path = dict["emoticon_group_path"] as! String
        let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Emoticons/\(group_path)/info.plist")
        
        // 2. 加载info.plist
        var infoDict = NSDictionary(contentsOfFile: path)!
        
        // 3. 从 infoDict 的 emoticon_group_emoticons 中提取表情符号数组
        let list = infoDict["emoticon_group_emoticons"] as! NSArray
        
        // 4. 遍历 list 数组，加载具体的表情符号
        var result = loadEmoticons(list, dict)
        
        return result
    }
    
    ///  从 info.plist 的表情数组中，加载真正的具体的表情数据
    // 从 emoticon_group_emoticons 返回表情数组的数组，每一个数组 都 包含 21 个表情(最后一个是空的)
    class func loadEmoticons(list : NSArray, _ dict : NSDictionary) -> [EmoticonsSection]{
        // 1.生成EmoticonsSection 对象数组，每20个就生成一个EmoticonsSection 对象
        let emoticonCount = 20
        // 2. 计算总共需要多个 [EmoticonsSection]
        let objCount = (list.count - 1) / emoticonCount + 1
        println("对象个数\(objCount)")
        
        //记录存储结果的中间数组
        var result = [EmoticonsSection]()
        //3. 循环遍历所有的对象，利用双重for循环，达到20个就存到[EmoticonsSection]中的一个数组中
        for i in 0..<objCount {
            //3.1 MARK: 创建表情数组对象！！！！！！！！！！！！！！！！！
            var emoticon = EmoticonsSection(dict: dict)
            
            // 3.2 填充对象内部的表情符号数据
            // 遍历数组，把80个数据按照 0~19, 20~39, 40~69....填充到第 i 个 数组表情对象中
            for count in 0..<20 { //20个
                // 1.数组中下标序号
                let j = count + i * emoticonCount

                // 2. 向数组中添加元素，如果内，那么
                // MARK: 特别注意，最后不够20个一组的，不够的部分也要赋值为nil
                var tempDict : NSDictionary? = nil
                if j < list.count {
                    //在list范围内就 实例化表情符号对象
                    tempDict = list[j] as? NSDictionary
                }
                
                //初始化 一个 表情符号元素
                let em = Emoticon(dict: tempDict, path: emoticon.path)
                //添加到表情数组对象中的emoticons数组属性中
                emoticon.emoticons.append(em)
            }
            
            //MARK: 这里添加第21个删除按钮
            let em = Emoticon(dict: nil, path: nil)
            //添加标示符，判定该位置是删除按钮
            em.isDeleteButton = true
            //添加到表情数组对象中的emoticons数组属性中
            emoticon.emoticons.append(em)
            
            //把完整数组加入到结果集
            result.append(emoticon)
        }
        return result
    }
    
}


//表情符号类
class Emoticon {
   
    /// emoji 的16进制字符串
    var code: String?
    /// emoji 字符串
    var emoji: String?
    
    /// 类型
    var type: String?
    
    /// 表情符号的文本 - 发送给服务器的文本
    var chs: String?
    
    /// 表情符号的图片 - 本地做图文混排使用的图片
    var png: String?
    
    /// 图像的完整路径
    var imagePath: String?
    
    ///  删除按钮的属性
    var isDeleteButton = false
    
    //构造函数初始时候给属性赋值
    init(dict: NSDictionary?, path : String?) {
        code = dict?["code"] as? String
        type = dict?["type"] as? String
        chs = dict?["chs"] as? String
        png = dict?["png"] as? String
        
        if path != nil && png != nil {
            imagePath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Emoticons/\(path!)/\(png!)")
        }
        
        //计算emoji
        //把16进制的emoji字符串 转化为字符串可以显示,固定写法
        if code != nil {
            let scnner = NSScanner(string: code!)
            var value : UInt32 = 0 //传递指针，用var,不要用let
            scnner.scanHexInt(&value)
            emoji = "\(Character(UnicodeScalar(value)))"
        }
        
    }
    
    
}
