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
    
    
    /**
    1. loadView -> 创建视图层次结构，纯代码开发替代 storyboard & xib
    2. viewDidLoad -> 视图加载完成，只是把视图元件加载完成，还没有开始布局
    不要设置关于 frame 之类的属性！
    3. viewWillAppear -> 视图将要出现
    4. viewWillLayoutSubviews —> 视图将要布局子视图，苹果建议设置界面布局属性
    5. view 的 layoutSubviews 方法，视图和所有子视图布局
    6. viewDidLayoutSubviews -> 视图&所有子视图布局完成
    7. viewDidAppear -> 视图已经出现
    */
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
    
    //设置显示 用户选择到的图片
    override func viewDidLayoutSubviews() {
        /**
        viewWillAppear 执行是在数据源方法执行之前就调用了，滚动视图是无法滚动的
        ** viewWillLayoutSubviews - 这两个方法，在使用的时候，一定要仔细测试，涉及到和子视图数据联动的关系
        ** viewDidLayoutSubviews  - 能够通知子视图直接切换界面
        数据源
        awakeFromNib - 加载 cell，开始下载图像 - 直接下载第0张图片
        cell - layoutSubviews
        viewDidAppear - collectionView 滚动，就会出现图片切换的效果！
        */
        let indexPath = NSIndexPath(forItem: selectedIndex, inSection: 0)
        photoView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
    }
    
    
    
    @IBAction func backBtnOnClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    ///  保存网络图片到手机相册
    @IBAction func savePhotoBtnOnClick(sender: AnyObject) {
        //获取当前collectionView页面停留的 下标号
        if let indexPath = photoView.indexPathsForVisibleItems().last as? NSIndexPath {
            println("\(indexPath.row)")
            
            //获取保存的cell 
            let cell = photoView.cellForItemAtIndexPath(indexPath) as! PhotoCell
            
            //从cell中获取图片
            if  let image = cell.iconView?.image {
                //保存到手机
                UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
            }
        }
    }
    
    // 保存到相册的回调
    // - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            SVProgressHUD.showInfoWithStatus("保存出错")
        } else {
            SVProgressHUD.showInfoWithStatus("保存成功")
        }
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
    
    
    /**
        下载显示图像方式二
    */
    // 定义图像的url ，并且下载
    var urlString : String? {
        didSet{
            //下载图像，并且显示
            NetWorkManager.instance.requestImage(urlString!) { (result, error) -> () in
                if let image = result as? UIImage {
                    self.iconView!.image = image
                    // 计算设置图像的大小
                    self.self.setupImageView(image)
                }
                
            }
        }
        
    }
    /// 是否是短图的标记
    var isShortImage = false
    
    func setupImageView(image: UIImage) {
        // collectionViewCell的cell重用，导致cell其中scrollView重用参数变化的问题
        scrollView?.contentOffset = CGPointZero
        scrollView?.contentSize = CGSizeZero
        scrollView?.contentInset = UIEdgeInsetsZero
        
        let imageSize = image.size
        let screenSize = self.bounds.size
        
        //获取图片宽度和屏幕宽度一样之后，图片的高度: h
        //如果 h > 屏幕高度，说明就是长图，反之则是短图
        let h = screenSize.width / imageSize.width * imageSize.height
        
        //设置 图像显示
        iconView?.image = image
        //设置 图像的尺寸
        //这里设置图片位置(0,0)，然后用contentInset压到中间位置，这样做，可以保证图片放大缩小始终居中，不会再被手机随意拖动留出很大的空白空间，新浪就是这么做的
        let rect = CGRectMake(0, 0, screenSize.width, h)
        iconView?.frame = rect
        scrollView?.frame = self.bounds
    
        //区分长图 和 短图
        if  rect.size.height > screenSize.height{
            //长图需要从上往下显示，所以不设置conetntInset
            //可以查看的范围
            scrollView?.contentSize = rect.size
            
            //不是短图
            isShortImage = false
        }else{
            //为短图
            //设置垂直居中
            let y = (screenSize.height - h) * 0.5
            scrollView?.contentInset = UIEdgeInsetsMake(y, 0, 0, 0)
            isShortImage = true
        }
    }
    
    //当图片缩放滚动操作完成后
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
        if isShortImage {
            let y = (frame.size.height - iconView!.frame.size.height) * 0.5
            scrollView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0)
        }
    }
    
    
    
    
 /**
     ****下载显示图像方式一

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
    
*/
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
        // 在这个房中，动态设置滚动视图的大小
        scrollView!.frame = self.bounds
//        scrollView?.backgroundColor = UIColor.redColor()
    }
    
}