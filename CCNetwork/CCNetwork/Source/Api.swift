//
//  Api.swift
//  CCNetwork
//
//  Created by qiuxiaocai on 2019/5/29.
//  Copyright © 2019 Bella. All rights reserved.
//

import Foundation
import Alamofire

/// 是否允许打印log信息，默认false
public var enablePrintLog = false

/// swift自带debugPrint消耗性能
public func debugLog<T>(_ log: T) {
    if enablePrintLog {
        print("\(log)")
    }
}

/// Response类型
public enum ResponseType {
    case data
    case json(readingOptions: JSONSerialization.ReadingOptions)
    case string
    case plist
}

/// 请求方式：对应出HTTPMethod
public enum RequestType {
    /// 请求一般数据 GET
    case getData
    /// 请求一般数据 POST
    case postData
    /// 文件下载等
    case downloadData
    /// form data 上传
    case uploadFormData
    
    public var httpMethod: Alamofire.HTTPMethod {
        switch self {
        case .getData, .downloadData:
            return Alamofire.HTTPMethod.get
        case .uploadFormData, .postData:
            return Alamofire.HTTPMethod.post
        }
    }
}

/// 上传数据格式
public struct FormData {
    var data: Data = Data()
    var name: String = ""
    var fileName: String = ""
    var mineType: String = ""
}

/// api config
public protocol ApiConfig {
    var apiPath: String { get }
    var headers: [String: String] { get }
    var params: [String: Any] { get }
    var timeout: TimeInterval { get }
    var requestType: RequestType { get }
    var formData: [FormData] { get }
    var responseType: ResponseType { get }
    var downloadPath: URL { get }
}

extension ApiConfig {
    /// 通过实现的扩展生成一个urlRequest
    public func urlRequest(hostUrl: String) -> URLRequest? {
        guard let requestURL = URL(string: hostUrl + "/" + apiPath) else {
            return nil
        }
        var urlRequest = URLRequest.init(url: requestURL)
        urlRequest.httpMethod = requestType.httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.timeoutInterval = timeout
        return params.count == 0 ? urlRequest : try? Alamofire.URLEncoding.methodDependent.encode(urlRequest, with: params)
    }
}

public struct ApiTarget: ApiConfig {
    
    public var apiPath: String
    public var headers: [String : String]
    public var params: [String : Any]
    public var timeout: TimeInterval
    public var requestType: RequestType
    public var formData: [FormData]
    public var responseType: ResponseType
    public var downloadPath: URL
    
    public init(api: ApiConfig) {
        apiPath = api.apiPath
        headers = api.headers
        params = api.params
        timeout = api.timeout
        requestType = api.requestType
        formData = api.formData
        responseType = api.responseType
        downloadPath = api.downloadPath
    }
}

open class Api<T> where T: ResponseFormatter  {
    
    public var completionHandler: ((ApiResult<T>) -> Void)?
    public var progressHandler: ((Progress) -> Void)?
    private var task: URLSessionTask?
    public var state: URLSessionTask.State? {
        return task?.state
    }
    public init() {
        guard self is ApiConfig else {
            assert(false, "子类必须实现 ApiType 协议")
            return
        }
    }
    
    public func start(in engine: Engine) {
        if state == .running {
            return
        }
        guard let api = self as? ApiConfig else {
            return
        }
        
        func handle<DataType>(response: DataResponse<DataType>) {
            switch response.result {
            case .success(let data):
                let data = T.preprocess(data: data)
                completionHandler?(ApiResult.success(data))
            case .failure(let error):
                completionHandler?(ApiResult.failure(error))
            }
        }
        
        func handleDownload<DataType>(response: DownloadResponse<DataType>) {
            switch response.result {
            case .success(let data):
                let data = T.preprocess(data: data)
                completionHandler?(ApiResult.success(data))
            case .failure(let error):
                completionHandler?(ApiResult.failure(error))
            }
        }
        
        engine.loadRequest(api: api, progressHandler: progressHandler, completionHandler: { response in
            if let res = response as? DataResponse<Any> {
                handle(response: res)
            }
            else if let res = response as? DownloadResponse<Any> {
                handleDownload(response: res)
            }
        }) { task in
            self.task = task
        }
    }
    
    public func cancel() {
        task?.cancel()
        task = nil
    }
    
}
