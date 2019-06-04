//
//  BaseResponse.swift
//  NetworkDemo
//
//  Created by qiuxiaocai on 2019/5/31.
//  Copyright © 2019 Bella. All rights reserved.
//

import Foundation
import CCNetwork

/// 适配器 根据不同的接口类型来处理返回原始数据
public enum AdaptorType {
    case java
    case common
}

extension AdaptorType {
    func adaptJava(with dict: [String: Any]) -> (Int?, String?, [String: Any]?) {
        let code = dict["code"] as? Int
        let message = dict["message"] as? String
        let dataDict = dict["data"] as? [String: Any]
        return (code, message, dataDict)
    }
}

/// 根据返回code 定义通用返回状态
public enum ResponseStatus {
    case success
    case unknown
    
    static func statusWith(javaCode: Int?) -> ResponseStatus {
        guard let code = javaCode else {
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
    
    /// 子类override，返回不同的code解析类型
    var adaptorType: AdaptorType {
        return .java
    }
    
    /// 子类override，接收对应的dict
    func receive(dict: [String : Any]?) { }
    
    /// 子类override，接收对应的array
    func receive(array: [Any]?) { }
    
    /// 子类override，接收对应的string
    func receive(string: String?) { }
    
    /// 子类override，接收对应的data
    func receive(data: Data?) {}

    public static func preprocess(data: Any?) -> Self {
        let object = self.init()
        switch object.adaptorType {
        case .java:
            if let dict = data as? [String: Any] {
                debugLog(dict)
                let value: (code: Int?, message: String?, dataDict: Dictionary?) = object.adaptorType.adaptJava(with: dict)
                object.status = ResponseStatus.statusWith(javaCode: value.code)
                object.message = value.message
                object.receive(dict: value.dataDict)
            } else {
                print("解析code error")
            }
        case .common:
            if let dict = data as? [String: Any] {
                object.receive(dict: dict)
            } else if let data = data as? Data {
                object.receive(data: data)
            }
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
