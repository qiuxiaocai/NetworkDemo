//
//  BaseResponse.swift
//  NetworkDemo
//
//  Created by qiuxiaocai on 2019/5/31.
//  Copyright © 2019 Bella. All rights reserved.
//

import Foundation
import CCNetwork

/// 根据返回code 定义通用返回状态
public enum ResponseStatus {
    case success
    case unknown
    
    static func statusWith(code: Int?) -> ResponseStatus {
        guard let code = code else {
            return .unknown
        }
        switch code {
        case 0:
            return .success
        default:
            return .unknown
        }
    }
}

public class BaseResponse: ResponseFormatter {
    
    public var status: ResponseStatus?
    public var message: String?
    
    required init() { }
    
    /// 子类override，接收对应的dict
    func receive(dict: [String : Any]?) { }
    
    /// 子类override，接收对应的array
    func receive(array: [Any]?) { }
    
    /// 子类override，接收对应的string
    func receive(string: String?) { }
    
    public static func preprocess(data: Any?) -> Self {
        let object = self.init()
        if let dict = data as? [String: Any] {
            let code = dict["code"] as? Int
            let message = dict["message"] as? String
            let data = dict["data"] as? [String: Any]
            object.status = ResponseStatus.statusWith(code: code)
            object.message = message
            object.receive(dict: data)
        }
        return object
    }
    
}

extension JSONDecoder {
    /// 同原方法区别: 1.静态方法 2.from改成with 3.返回类型改为可选
    /// 只在当前api子工程可访问
    static func decode<T>(_ type: T.Type, with data: Any?) -> T? where T: Decodable {
        guard let data = data else {
            return nil
        }
        
        if JSONSerialization.isValidJSONObject(data) == false {
            print("传入的data不是一个有效的jsonObject")
            return nil
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) {
            if let decodableObject = try? JSONDecoder().decode(type, from: jsonData) {
                return decodableObject
            }
        }
        return nil
    }
}
