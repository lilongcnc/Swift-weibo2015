//
//  RefreshViewController.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/10.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit

class RefreshViewController: UIRefreshControl {
    //加载xib下来刷新视图,通过视图自身的加载顺序方法进行
    lazy var refreshView : RefreshView = {
       return RefreshView.refreshView(isLoading: false)
    }()

    
    
// MARK: ---- 下拉刷新部分代码
    //设置 下拉刷新大图的大小
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        
        //设置下拉刷新视图的大小
        refreshView.frame = self.bounds
    }
    
    override func awakeFromNib() {
        //把下拉刷新视图替换到stpryBoard中的 UIRefreshControl控件中
        self.addSubview(refreshView)
        
        //MARK: 利用kvo来观察控件自身位置的变化(注意销毁观察者)
        self.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    deinit{
        println("刷新视图1 被释放了")
        
        //销毁观察者
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    //正在现实加载的动画
    var isLoading = false
    //旋转提示图标标记
    var isRotateTip = false
    
    //KVO 观察控件位置变化
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        println("\(self) ----- \(change)  ----- \(self.frame)")

        //向下拉的时候，self.frame.origin.y是小于0的
        //当向上滚表格的时候
        if self.frame.origin.y > 0 {
            return
        }
        
        if !isLoading && refreshing{ //MARK： refreshing 正在刷新
            //正在刷新
            //显示刷新视图时候动画旋转效果
            refreshView.showLoading()
        
            isLoading = true
            
            return
        }
        
        if self.frame.origin.y < -50 && !isRotateTip {
            //此时箭头向下，需改为向上
            isRotateTip = true
            refreshView.rotationTipIcon(isRotateTip)
        }else if self.frame.origin.y > -50 && isRotateTip {
            //此时箭头向上，需改为箭头向下
            isRotateTip = false
            refreshView.rotationTipIcon(isRotateTip)
        }
    }
    
    
    //重写父类停止刷新方法
    override func endRefreshing() {
        //调用父类的方法，保证其功能正常执行
        super.endRefreshing()
        
        //停止动画
        refreshView.stopLoading()
        
        isLoading = false
    }
    
}


class RefreshView : UIView {
///  提醒视图图片
    @IBOutlet weak var tipImageView: UIImageView!
///  提醒视图
    @IBOutlet weak var tipView: UIView!
///  加载视图
    @IBOutlet weak var loadView: UIView!
///  加载视图图片
    @IBOutlet weak var loadImageView: UIImageView!
    
    //丛xib中加载刷新视图
    class func refreshView(isLoading: Bool = false) -> RefreshView {
        let view = NSBundle.mainBundle().loadNibNamed("RefreshViewController", owner: nil, options: nil).last as! RefreshView
        //利用isLoading参数更便捷的控制下拉和上拉视图的现实
         view.tipView.hidden = isLoading
         view.loadView.hidden = !isLoading
        
        return view
    }

    //刷新视图动画效果
    func showLoading() {
        tipView.hidden = true
        loadView.hidden = false
        
        //添加动画
        loadingAnimation()
    }

    //动画旋转的实现代码
    /**
    核心动画 - 属性动画 =>
    - 基础动画： fromValue toValue
    - 关键帧动画：values, path
    * MARK： 将动画添加到图层
    */
    func loadingAnimation() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        anim.toValue = 2 * M_PI
        anim.repeatCount = MAXFLOAT //OC中是  MAX_FLOAT
        anim.duration = 0.5
        
        //将动画添加到图层
        loadImageView.layer.addAnimation(anim, forKey: nil)
    }
    

    //箭头图片的转向和返回的动画效果实现
    func rotationTipIcon(clockWise : Bool) {

        var angel = CGFloat(M_PI - 0.01)
        if clockWise {
            angel = CGFloat(M_PI + 0.01)
        }
        
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            // 旋转提示图标 180
            self.tipImageView.transform = CGAffineTransformRotate(self.tipImageView.transform,angel)
        })
    }
    
    //停止动画
    func stopLoading() {
        //删除动画，恢复视图显示
        loadImageView.layer.removeAllAnimations()
        
        tipView.hidden = false
        loadView.hidden = true
    }
    
   //------------------------------------------------------------
    /**
    parentView默认就强引用，这里会对闭包中的tableView强引用，即其中的控件
    而闭包被外边的视图控件强引用， 造成循环引用
    OC中，代理要使用weak
    */
    
    // MARK: - 上拉加载更多部分代码
   weak var parentView: UITableView?
    
    // 给 parentView 添加观察
    func addPullupOberserver(parentView: UITableView, pullupLoadData: ()->()) {
        
        // 1. 记录要观察的表格视图
        self.parentView = parentView
        
        // 2. 记录上拉加载数据的闭包
        self.pullupLoadData = pullupLoadData
        
        self.parentView!.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    // KVO 的代码
    deinit {
        println("刷新视图2 被释放了")
        
        //释放对象不一定放在deinit中,我们根据具体的情况来定
//        parentView!.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    // 上拉加载数据标记
    var isPullupLoading = false
    // 上拉加载数据闭包
    var pullupLoadData: (()->())?
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        // 1. 如果在 tableView 的顶部，不进行刷新，直接返回
        if self.frame.origin.y == 0 {
            return
        }
        
        if (parentView!.bounds.size.height + parentView!.contentOffset.y) > CGRectGetMaxY(self.frame) {
            // 2. 保证上拉加载数据的判断只有一次是有效的
            if !isPullupLoading {
                println("上拉加载数据！！！")
                isPullupLoading = true
                
                // 播放转轮动画
                showLoading()
                
                // 3. 判断闭包是否存在，如果存在，执行闭包
                if pullupLoadData != nil {
                    pullupLoadData!()
                }
            }
        }
    }
    
    /// 上拉加载完成
    func pullupFinished() {
        // 重新设置刷新视图的属性
        isPullupLoading = false
        
        // 停止动画
        stopLoading()
    }
}