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



extension EmoticonsViewController : UICollectionViewDataSource,UICollectionViewDelegate{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 3
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return 21
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("emoticonsCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        if indexPath.section % 2 == 0 {
            cell.backgroundColor = UIColor.redColor()
        }else{
            cell.backgroundColor = UIColor.orangeColor()
        }
        
        return cell
    }
    
    
    
    
}
