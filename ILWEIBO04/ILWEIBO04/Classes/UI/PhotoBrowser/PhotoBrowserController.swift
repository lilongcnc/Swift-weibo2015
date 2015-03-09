//
//  PhotoBrowserController.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/8.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit

class PhotoBrowserController: UIViewController {
    /// 图片的 URL 数组
    var urls: [String]?
    /// 选中照片的索引
    var selectedIndex: Int = 0
    
    //图片浏览器
    @IBOutlet weak var photoView: UICollectionView!
    //
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    /// 快速创建 图片浏览视图
    class func photoBrowserController() -> PhotoBrowserController{
        let  PhotoBrowserSB = UIStoryboard(name: "PhotoBrowser", bundle: nil)
        return PhotoBrowserSB.instantiateInitialViewController() as! PhotoBrowserController
    }
    
    override func viewWillLayoutSubviews() {
        //MARK : swift,直接省略self.view.
        println("\(__FUNCTION__) \(view.frame)")
        //设置collectionViewcell的 布局
        layout.itemSize = view.frame.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        //设置浏览视图分页
        photoView.pagingEnabled = true
    }
    
    
    
    @IBAction func backBtnOnClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    @IBAction func savePhotoBtnOnClick(sender: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        println("\(urls)---------\(selectedIndex)")
        
    }
    
}


extension PhotoBrowserController :UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return urls?.count ?? 0
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCell
        
        // 设置当前cell 的 urlString
        cell.urlString = urls![indexPath.item]
        cell.backgroundColor = UIColor(red: random(), green: random(), blue: random(), alpha: 1.0)

        
        return cell
    }
    
    func random() -> CGFloat {
        return CGFloat(arc4random_uniform(256)) / 255
    }
}


class PhotoCell : UICollectionViewCell,UIScrollViewDelegate {
    
    /**
    MARK: 纯代码搭架,图片缩放结构：
    collectionViewCell中放ScrollView，scrollView中放UIImageView
    */
    ///  单张图片缩放的视图
    var scrollView : UIScrollView?
    
    ///  显示图像的UIimageView
    var iconView : UIImageView?
    
    //返回要缩放的视图
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return iconView!
    }
    
    
    // 定义图像的url ，并且下载
    var urlString : String? {
        didSet{
            //下载图像，并且显示
             NetWorkManager.instance.requestImage(urlString!) { (result, error) -> () in
                if result != nil {
                    
                var img = result as! UIImage
                    
                 //设置图像
                 self.iconView?.image = img
                 
                // 计算设置图像的大小
                self.self.calcImageSize(img.size)
                }
                
            }
        }
        
    }
    
    ///  计算图像大小
    func calcImageSize(size: CGSize) {
        // 0. 计算图像的宽高比
        
        // 1. 计算图像和屏幕的宽高比
        var wScale = size.width / self.bounds.size.width
        var hScale = size.height / self.bounds.size.height
        
        // 2. 宽度和高度
        //        var w = self.bounds.size.width
        //        var h = self.bounds.size.height
        var w = size.width
        var h = size.height
        
        iconView!.frame = bounds
        if (h / w) > 2 {
            //设置图像的 内容填充模式
            iconView!.contentMode = UIViewContentMode.ScaleAspectFill
            //设置可视的范围
            scrollView!.contentSize = size
        } else {
            iconView!.contentMode = .ScaleAspectFit
        }
        
    }
    

    override func awakeFromNib() {//在这个方法中： cell 的大小是 50 * 50，完全没有设置
        //创建界面元素
        scrollView = UIScrollView()
        self.addSubview(scrollView!)
        //设置scrollView的代理
        scrollView!.delegate = self
        //设置缩放的尺寸
        scrollView!.maximumZoomScale = 2.0
        scrollView!.minimumZoomScale = 1
        
        //图像视图
        iconView = UIImageView()
        scrollView?.addSubview(iconView!)
    }
    
    //这个方法执行的时候，视图frame已经定型了
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置滚动视图的大小
        scrollView!.frame = self.bounds
//        scrollView?.backgroundColor = UIColor.redColor()
    }
    
}