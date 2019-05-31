//
//  Response.swift
//  CCNetwork
//
//  Created by qiuxiaocai on 2019/5/29.
//  Copyright © 2019 Bella. All rights reserved.
//

import Foundation

/// 使api和response达到完全解耦，两个类都面向抽象的协议而不是具体实现
public protocol ResponseFormatter {
    
    /// 对接口返回的的数据进行处理，不同的接口内部使用不同的解析方法
    ///
    /// - Parameter json: 原始数据
    /// - Returns: 处理数据所在的对象
    static func preprocess(data: Any?) -> Self
    
}
