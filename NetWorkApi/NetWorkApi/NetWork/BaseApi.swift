//
//  BaseApi.swift
//  NetworkDemo
//
//  Created by qiuxiaocai on 2019/5/30.
//  Copyright © 2019 Bella. All rights reserved.
//

import Foundation
import CCNetwork

public typealias BaseApi<T> = Api<T> & ApiConfig where T: ResponseFormatter

/// 提供一些默认实现
extension ApiConfig {
    /// 请求头
    public var headers: [String : String] {
        return [:]
    }
    
    /// 默认超时时间
    public var timeout: TimeInterval {
        return 5
    }
    
    /// 请求方式
    public var requestType: RequestType {
        return .postData
    }
    
    /// response类型 默认json
    public var responseType: ResponseType {
        return .json(readingOptions: .allowFragments)
    }

    /// 默认下载地址
    public var downloadPath: URL? {
        let documentsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent("Test")
    }
    
}
