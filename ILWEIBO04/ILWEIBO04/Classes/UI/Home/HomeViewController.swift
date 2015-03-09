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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //获取模型数据
        loadData()
    }

///  获取 模型中的数据
    func loadData() {
        SVProgressHUD.show()
        //获取模型的数据
        StatusesModel.loadStatusesModel { (data, error) -> () in
            //处理错误
            if error != nil {
                println("HomeViewController 出错误了: \(error)")
                SVProgressHUD.showInfoWithStatus("你的网络不给力！！！")
                return
            }
            
            //没有错误
            SVProgressHUD.dismiss()
            //处理数据
            if data != nil {
                // 获取当前模型 赋值 数据
                //MARK: 在闭包当中，需要self
                self.statusesModel = data
                self.tableView.reloadData()
            }
        }
    }
    
///  弹出图片浏览视图
    
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
            cell.photoDidSelected = {(status: StatusModel, photoIndex: Int)->() in
                
                let PhotoBrowserVC = PhotoBrowserController.photoBrowserController()
                
                //传递数据
                PhotoBrowserVC.urls = status.large_pic_Urls
                PhotoBrowserVC.selectedIndex = photoIndex
                
                //弹出 图片浏览视图控制器
                self.presentViewController(PhotoBrowserVC, animated: true, completion: nil)
                
                
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
            println("从缓存返回 \(h)")
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