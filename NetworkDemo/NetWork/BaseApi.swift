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
    
    public var downloadPath: URL {
        let documentsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return  documentsURL.appendingPathComponent("file")
    }
    
    
}
