//
//  HomeViewController.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/6.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {

    //定义微博数据
    var statusesModel : StatusesModel?
    
    //行高缓存
    lazy var rowHeightCache : NSCache? = {
       return NSCache()
    }()
    
    //上拉加载视图
    lazy var pullupView: RefreshView = {
        return RefreshView.refreshView(isLoading: true)
    }()
    
    
    deinit{
        print("HomwViewController释放")
        //主动释放刷新视图对tableView的引用
        tableView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //获取模型数据
        loadData()
        //上拉加载更多数据
         setupPullupView()
    }

    
    //添加上拉加载更多视图
    //MARK: 加上底部视图之后，待刷新界面就成白色的？？不加的话，是表格
    func setupPullupView() {
        tableView.tableFooterView = pullupView
        weak var weakSelf = self
        pullupView.addPullupOberserver(tableView, pullupLoadData: { () -> () in
            
            //             weakSelf!.pullupView.isPullupLoading = false
            // 获取到 上次一组数据中的最后的一个数据的maxId
            if let maxId = self.statusesModel?.statuses?.last?.id {
                // 加载 maxId 之前的数据
                weakSelf?.loadData(maxId - 1)
            }
        })
    }
    
    
    @IBAction func loadData() {
        loadData(0)
    }
    
///  获取 模型中的数据
    /**
  MARK : 这里函数中如果直接在函数形参数中赋初始值，loadData(maxId : Int = 0)，那么调用的时候就和“loadData()“函数区分不开。我们不在函数形参中赋值“loadData(maxId : Int)”，就可以区别开
*/
     func loadData(maxId : Int) {
        //调用下拉刷新数据
        refreshControl?.beginRefreshing()
        weak var weakSelf = self
        
        //获取模型的数据
        StatusesModel.loadStatusesModel(maxId : maxId) { (data, error) -> () in
            
            //处理错误
            if error != nil {
                println("HomeViewController 出错误了: \(error)")
                SVProgressHUD.showInfoWithStatus("你的网络不给力！！！")
                return
            }
            
            weakSelf!.refreshControl?.endRefreshing()
            
            //处理数据
            if data != nil {
                // 如果maxId = 0，执行刷新数据功能。默认刷新 20条数据。用来做下来刷新
                
                if maxId == 0 {
                    
                    // 获取当前模型 赋值数据
                    //MARK: 在闭包当中，需要self
                    weakSelf!.statusesModel = data
                    weakSelf!.tableView.reloadData()
                }else{
                    //在这里加载更多的新数据
                        println("加载到了新数据！")
                        // 拼接数据，数组的拼接
                        let list = weakSelf!.statusesModel!.statuses! + data!.statuses!
                        weakSelf!.statusesModel?.statuses = list
                        weakSelf?.tableView.reloadData()
                        // 重新设置刷新视图的属性
                        weakSelf?.pullupView.pullupFinished()
                }
            }
        }
    }
    
}


extension HomeViewController : UITableViewDataSource,UITableViewDelegate{
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //不一定有，这里加问号
        return statusesModel?.statuses?.count ?? 0
    }
    
    
    func cellInfos(myIndexPath : NSIndexPath) -> (cellID : String, status : StatusModel){
        //获取具体微博数据模型
        //MARK: 这个得加两个 ! ! --- 出现这种带问号的东西，很可能就是是 ！ ？的错误
        let statusModel = statusesModel!.statuses![myIndexPath.row]
        //返回cell标示符
        // 调用的是类方法
        let cellID = StatusCell.cellIdentifier(statusModel)
        
        return (cellID!, statusModel)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellInfo = cellInfos(indexPath)

        let cell = tableView.dequeueReusableCellWithIdentifier(cellInfo.cellID) as! StatusCell
        
        //向cell赋值
        cell.status =  cellInfo.status
        
        //判断表格的闭包是否被实现
        if cell.photoDidSelected == nil {
            
            weak var weakSelf = self
            cell.photoDidSelected = {(status: StatusModel, photoIndex: Int)->() in
                
                let PhotoBrowserVC = PhotoBrowserController.photoBrowserController()
                
                //传递数据
                PhotoBrowserVC.urls = status.large_pic_Urls
                PhotoBrowserVC.selectedIndex = photoIndex
                
                //弹出 图片浏览视图控制器
                weakSelf!.presentViewController(PhotoBrowserVC, animated: true, completion: nil)
            }
        }
        
        return cell
    }
    
    
    //MARK:设置cell的高度 要根据模型数据来设置
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //获取cell模型数据
        let cellInfo = cellInfos(indexPath)
        
        //MARK : 判断是否已经缓存了行高
        if let h = rowHeightCache?.objectForKey("\(cellInfo.status.id)") as? NSNumber {
            return CGFloat(h.floatValue)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellInfo.cellID) as! StatusCell
            let height = cell.getCellHeight(cellInfo.status)
            
            // 将行高添加到缓存 - swift 中向 NSCache/NSArray/NSDictrionary 中添加数值不需要包装
            rowHeightCache!.setObject(height, forKey: "\(cellInfo.status.id)")
            
            return cell.getCellHeight(cellInfo.status)
        }
    }
    
    
    
    //MARK: 预设值cell的高度，可以提高性能
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
}