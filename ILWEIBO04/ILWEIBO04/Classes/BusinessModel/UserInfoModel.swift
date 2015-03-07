//
//  UserInfoModel.swift
//  ILWEIBO04
//
//  Created by 李龙 on 15/3/6.
//  Copyright (c) 2015年 Lauren. All rights reserved.
//

import UIKit

//用户信息
class UserInfoModel: NSObject {
   
    ///  用户UID
    var id: Int = 0
    ///  用户昵称
    var screen_name: String?
    ///  友好显示名称
    var name: String?
    ///  用户头像地址（中图），50×50像素
    var profile_image_url: String?
    ///  用户头像地址（大图），180×180像素
    var avatar_large: String?
    ///  用户创建（注册）时间
    var created_at: String?
    ///  是否是微博认证用户，即加V用户，true：是，false：否
    var verified: Bool = false
    
    /// 自定义属性：认证类型图像（UIImage）
    var verifiedImage : UIImage?
    ///  认证类型 -1：没有认证，0，认证用户，2,3,5: 企业认证，220: 草根明星
    var verified_type: Int = -1{
        didSet{
            switch verified_type {
            case 0:     // 大V
                verifiedImage = UIImage(named: "avatar_vip")
            case 2,3,5: // 企业认证
                verifiedImage = UIImage(named: "avatar_enterprise_vip")
            case 220:   // 达人
                verifiedImage = UIImage(named: "avatar_grassroot")
            default:
                verifiedImage = nil

            }
        }
    }
    
    /// 自定义属性: 会员等级图像（UIImage）
    var mbImage : UIImage?
    
    ///  会员等级 0~6
    var mbrank: Int = 0 {
        didSet{
            if mbrank > 0 && mbrank < 7{
                mbImage = UIImage(named: "common_icon_membership_level\(mbrank)")
            }else{
                mbImage = nil
            }
        }
    }
    
}