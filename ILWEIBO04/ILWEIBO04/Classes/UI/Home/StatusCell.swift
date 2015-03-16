//
//  StatusCell.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/7.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit

class StatusCell: UITableViewCell {
    /// 头像
    @IBOutlet weak var iconImage: UIImageView!
    /// 姓名
    @IBOutlet weak var nameLabel: UILabel!
    /// 会员图标
    @IBOutlet weak var memberIcon: UIImageView!
    /// 认证图标
    @IBOutlet weak var vipIcon: UIImageView!
    /// 时间
    @IBOutlet weak var timeLabel: UILabel!
    /// 来源
    @IBOutlet weak var sourceLabel: UILabel!
    /// 微博正文
    @IBOutlet weak var contentLabel: UILabel!
    
    
    /// 微博正文配图 - UICollectionView
    /// 配图视图
    @IBOutlet weak var pictureView: UICollectionView!
    /// 配图视图宽度
    @IBOutlet weak var pictureViewWidth: NSLayoutConstraint!
    /// 配图视图高度
    @IBOutlet weak var pictureViewHeight: NSLayoutConstraint!
    /// 配图视图布局
    @IBOutlet weak var pictureViewLayout: UICollectionViewFlowLayout!
    
    /// 底部工具视图
    @IBOutlet weak var bottomToolView: UIView!
    /// 转发微博文本
    @IBOutlet weak var forwardLabel: UILabel!

    
    //选中cell的闭包
    // 定义照片被选择的闭包（参数：选中的微博数据&照片索引）
    var photoDidSelected: ((status: StatusModel, photoIndex: Int)->())?
    
    
    /// 微博数据 － 设置 cell 内容
    var status: StatusModel? {
        didSet {
            nameLabel.text = status!.user!.name
            timeLabel.text = status!.created_at
            
            //sourceStr调用的方法是返回String的，UILabel也要用 xxx.text接收
            sourceLabel.text = status!.sourceStr
            
//            contentLabel.text = status!.text
//             返回NSAttributedString，UILabel也要用 xxx.attributedText接收
            contentLabel.attributedText = status!.text!.emoticonString() ?? NSAttributedString(string: status!.text!)
            
            
            // 头像
            if let imageURL  = status!.user!.profile_image_url {
                NetWorkManager.instance.requestImage(imageURL) { (result, error) -> () in
                    //判断是否有头像
                    if let faceImage = result as? UIImage {
                        self.iconImage.image = faceImage
                    }
                }
            }
            
            // 认证图标
            vipIcon.image = status?.user?.verifiedImage
            // 会员图标
            memberIcon.image = status?.user?.mbImage
            
            //MARK: 设置配图视图的大小
            let pSize = calcPictureViewSize()
            pictureViewWidth.constant = pSize.viewSize.width
            pictureViewHeight.constant = pSize.viewSize.height
            pictureViewLayout.itemSize = pSize.itemSize
            
            
            // 重新刷新配图视图 － 强制数据源方法重新执行
            pictureView.reloadData()
            
            // 设置转发微博文字
            if status!.retweeted_status != nil {
               forwardLabel.text = status!.retweeted_status!.user!.name! + ":" + status!.retweeted_status!.text!
            }
        }
    }
    
    ///要获得准备的cell高度，需要知道准确的对应的模型数据
    func getCellHeight(status : StatusModel) -> CGFloat{
        
        //重新设置当前cell的模型数据，确保模型数据的和cell对应，这样计算出的cell高度才精准
        self.status = status
        
        //刷新cell
        layoutIfNeeded()
        
        return CGRectGetMaxY(bottomToolView.frame)
    }
    
///  返回可重用的cell标示符
    //根据数据模型来判断标识符
    //MARK : 注意想直接调用，要变成类方法
    class func cellIdentifier(status : StatusModel) -> String? {
        // status.retweeted_status不为空，则说明是转发微博；为空则是原创微博
        if status.retweeted_status != nil {
            return "HomeCell2"
        }else{
            return "HomeCell"
        }
    }
    
    
    ///  真正开始创建表格Cell的时候，才会被调用，从 storyboard 加载, bounds/frame都还没有设置,为0
    override func awakeFromNib() {
        //MARK: 代码设置微博正文UILabel换行
        contentLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 30
        //MARK: 这里forwardLabel不加?问号的话，会奔溃。加上才执行，没有就不执行了
        forwardLabel?.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 30
    }
}




extension StatusCell : UICollectionViewDataSource,UICollectionViewDelegate {
    
    // 配图的数量
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return status?.pictureUrls?.count ?? 0
    }
    
    //  配图Cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pictureCell", forIndexPath: indexPath) as! PictureCell
        
        // 设置配图的图像路径
        cell.urlString = status!.pictureUrls![indexPath.item].thumbnail_pic
        
        return cell
    }
    
    
    //获取选中的图片
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println(indexPath.item)
        //MARK: 判断闭包是否实现
        if self.photoDidSelected != nil {
            //传递选中的模型和 选中的item数目
            self.photoDidSelected!(status: status!, photoIndex: indexPath.item)
        }
    }
    
    
    //设置配图视图的大小
    func calcPictureViewSize() -> (itemSize: CGSize, viewSize: CGSize) {
        //设置每一个cell的大小
        let s :CGFloat = 90
        var itemSize = CGSizeMake(s, s)
        
        //初始化 配图视图的size
        var viewSize = CGSizeZero
        
        //0. 获取配图 图像的个数，有就返回个数，没有就是 0
        let count = status?.pictureUrls?.count ?? 0
        //        println("有配图 -\(count) 张")
        
        
        // 1. 如果没有图像
        if count == 0 {
            return (itemSize, viewSize)
        }
        
        // 2. 配图个数为1
        if count == 1{
            //获取被缓存图像的路径，然后实例化对象
            let path = NetWorkManager.instance.fullImageCachePath(status!.pictureUrls![0].thumbnail_pic!)
            
            //实例化图像，有可能失败
            if let image = UIImage(contentsOfFile: path) {
                //MARK： 获取图片的大小 设置 cell的大小
                return (image.size,image.size)
            }else{
                return (itemSize, viewSize)
            }
        }
        
        // 3. 配图个数为多张
        //间距
        let m: CGFloat = 10
        //个数为4
        if count == 4 {
            viewSize = CGSizeMake(s * 2 + m, s * 2 + m)
            //个数为其他
        } else {
            /**
            新浪服务器端规定好了图片最多就是9张
            1,2,3 = 1
            5,6 = 2
            7,8,9 = 3
            */
            let row = (count - 1) / 3
//            println("------------- row:    \(row)")
            //            let row = count / 3 + 1
            viewSize = CGSizeMake(3 * s + 2 * m, (CGFloat(row) + 1) * s + CGFloat(row) * m)
        }
        return (itemSize, viewSize)
    }

    

    
}




class PictureCell: UICollectionViewCell {
    @IBOutlet weak var pictureIconView: UIImageView!
    
    var urlString : String? {
        didSet{
            let path = NetWorkManager.instance.fullImageCachePath(urlString!)
            // 2. 实例化图像
            let image = UIImage(contentsOfFile: path)
            
            pictureIconView.image = image
        }
    }
}

