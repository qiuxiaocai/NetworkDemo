//
//  Result.swift
//  CCNetwork
//
//  Created by qiuxiaocai on 2019/5/29.
//  Copyright © 2019 Bella. All rights reserved.
//

import Foundation

/// 一个api的请求结果,封装成功和失败的状态并关联相关数据,类似Alamofire.Result

public enum ApiResult<DateType> {
    case success(DateType)
    case failure(Error)
    
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
    
    public var isFailure: Bool {
        return !isSuccess
    }
    
    public var value: DateType? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
    
}
