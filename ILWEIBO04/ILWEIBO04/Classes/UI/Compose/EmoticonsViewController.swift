//
//  EmoticonsViewController.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/12.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit

class EmoticonsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowlayout: UICollectionViewFlowLayout!


     /// 定义代理对象,代理切记用weak
    weak var delegate : EmoticonsViewControllerDelegate?
    
    //懒加载分组表情数据模型数组
    lazy var allEmoticonSections : [EmoticonsSection]? = {
        return EmoticonsSection.loadEmoticons()
    }()
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        /// 设置界面布局
        setupLayout()
        
    }
    
    /// 设置界面布局
    func setupLayout() {
        // 3 *7 个按钮
        let row : CGFloat = 3
        let col : CGFloat = 7
        //item间距
        let m : CGFloat = 10
        
        //计算item的大小
        let screenSize = self.collectionView.bounds.size
        let w = (screenSize.width - (col + 1) * m)/col
        
        flowlayout.itemSize = CGSizeMake(w, w)
        flowlayout.minimumLineSpacing = m
        flowlayout.minimumInteritemSpacing = m
        
        //每一个分组之间的边距
        flowlayout.sectionInset = UIEdgeInsetsMake(m, m, m, m)
        
        //设置滚动方向和分页
        flowlayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        //分页的实现和分组sction没有任何关系
        collectionView.pagingEnabled = true
    }
    

}


///  定义协议
// 1. 定义协议
/**
在 swift 中，除了类，还有"结构体"以及"枚举"都可以遵守协议！
weak 关键字，是用在 ARC 中管理对象内存属性，weak 关键字只能描述一个对象

也可以使用 @objc，要保证所有的参数，都是 OC 的
*/
protocol EmoticonsViewControllerDelegate : NSObjectProtocol {
    ///  选中某一个表情
    func emoticonsViewControllerDidSelectEmoticon( emoticonsVC: EmoticonsViewController, emoticon : Emoticon)
    
}


extension EmoticonsViewController : UICollectionViewDataSource,UICollectionViewDelegate{
    
    //根据IndexPath返回一个 Emoticon
    func selectEmoticon(indexPath : NSIndexPath) -> Emoticon {
        return allEmoticonSections![indexPath.section].emoticons[indexPath.item]
    }
    
    //选中表情cell
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //判断代理属性是否为空，然后执行
        delegate?.emoticonsViewControllerDidSelectEmoticon(self, emoticon: selectEmoticon(indexPath))
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        
        return allEmoticonSections?.count ?? 0
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return allEmoticonSections?[section].emoticons.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("emoticonsCell", forIndexPath: indexPath) as! EmoticonCell
        
        //给cell上赋值表情
        cell.emoticon = selectEmoticon(indexPath)
        
        return cell
    }
}


class EmoticonCell : UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var emoticonLabel: UILabel!
    
    var emoticon : Emoticon? {
        didSet{
//            println(emoticon?.imagePath)
            
            //给表情设置图片
            if let path = emoticon?.imagePath {
                self.iconView.image = UIImage(contentsOfFile: path)
            }else {
                self.iconView.image = nil
            }
            
            //给删除按钮添加图片
            if emoticon!.isDeleteButton {
                self.iconView.image = UIImage(named: "compose_emotion_delete_highlighted")
            }
            
            //给emoji表情设置值
            emoticonLabel.text = emoticon?.emoji
        }
    }
}
