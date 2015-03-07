//
//  TabBar.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/6.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit

class TabBar: UITabBar {


    //MARK: 创建回调到视图控制器中的闭包
    var composedButtonClicked: (() -> ())?

    
    override func awakeFromNib() {
        self.addSubview(Composebutton!)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var index  = 0
        
        let num = self.subviews.count
        let h = self.bounds.size.height
        let w = self.bounds.size.width / CGFloat(count)
        
        for view in self.subviews as! [UIView]{
            //判断只是基础控件： view is UIControl
            if view is UIControl && !(view is UIButton){
                
                //设置控件的frame
                let x = CGFloat(index) * w
                view.frame = CGRectMake(x, 0, w, h)
                self.addSubview(view)
                
                index++
                if index == 2 {
                    index++ //给加号空出一个位置
                }
            }
        }
        
        //设置中间按钮的frame
        Composebutton!.frame = CGRectMake(2 * w, 0, w, h)
    }
    
    
    
    let count = 5
    
    //懒加载中间的 加号图片
    lazy var Composebutton : UIButton? = {
        
        let btn = UIButton()
        btn.setImage(UIImage(named: "tabbar_compose_icon_add"), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), forState: UIControlState.Highlighted)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button"), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), forState: UIControlState.Highlighted)
        //我们在懒加载中self.addSubview 这个方法不智能提示，是swift要求我们创建 在awakeFromNib中添加，各个方法更加的职责明确
        
        //添加监听
        btn.addTarget(self, action:  "clickCompose", forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
    
    
    //点击方法
    func clickCompose() {
        //判断闭包是否设置了数值
        if composedButtonClicked != nil{
            
            composedButtonClicked!()
        }
    }
    
}
