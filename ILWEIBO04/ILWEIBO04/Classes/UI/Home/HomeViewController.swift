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
                println(error)
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
                
                println(self.statusesModel)
                self.tableView.reloadData()
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
        
        return cell
    }
    
    //MARK:设置cell的高度 要根据模型数据来设置
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellInfo = cellInfos(indexPath)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellInfo.cellID) as! StatusCell

        return cell.getCellHeight(cellInfo.status)!
    }
    
    //MARK: 预设值cell的高度，可以提高性能
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
}