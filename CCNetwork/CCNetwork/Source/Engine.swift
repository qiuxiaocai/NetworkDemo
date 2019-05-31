//
//  Engine.swift
//  CCNetwork
//
//  Created by qiuxiaocai on 2019/5/29.
//  Copyright © 2019 Bella. All rights reserved.
//

import Foundation
import Alamofire

/// 负责相应 host下 api 的请求以及对请求任务的管理

public class Engine {
    
    /// 是否启用https认证,默认yes
    public let enableCerSSLPinning: Bool
    
    /// 是否允许无效证书（也就是自建的证书），默认为NO
    /// 通过- init(hostName:enableCerSSLPinning:)初始化，值为YES
    public let allowInvalidCertificates: Bool
    
    /// 是否需要验证域名，默认为YES；
  //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    // 如置为NO，建议自己添加对应域名的校验逻辑。
    public let validatesDomainName: Bool

    /// 域名
    public let hostUrl: String
    
    private let sessionConfig = URLSessionConfiguration.default
    
    private lazy var afSessionManager: Alamofire.SessionManager = {
        let manager = SessionManager(configuration: sessionConfig, delegate: SessionDelegate(), serverTrustPolicyManager: stpManager)
        manager.startRequestsImmediately = false
        return manager
    }()
    
    private lazy var stpManager: ServerTrustPolicyManager = {
        var hostNameWithoutScheme = ""
        if validatesDomainName, let host = URL(string: hostUrl)?.host {
            hostNameWithoutScheme = host
        }
        
        var policy = ServerTrustPolicy.disableEvaluation
        if enableCerSSLPinning {
            policy = ServerTrustPolicy.pinCertificates(certificates: Alamofire.ServerTrustPolicy.certificates(), validateCertificateChain: allowInvalidCertificates, validateHost: validatesDomainName)
        }
        
        return ServerTrustPolicyManager(policies: [hostNameWithoutScheme : policy])
    }()
    
    public convenience init(hostUrl: String) {
        self.init(hostUrl: hostUrl, enableCerSSLPinning: false)
    }
    
    //是否启用SSL Pinning认证，参考http://www.jianshu.com/p/f44a50a200fa, hostName需要完整的scheme:host
    public init(hostUrl: String, enableCerSSLPinning: Bool = false, allowInvalidCertificates: Bool = true, validatesDomainName: Bool = false) {
        self.enableCerSSLPinning = enableCerSSLPinning
        self.allowInvalidCertificates = allowInvalidCertificates
        self.validatesDomainName = validatesDomainName
        self.hostUrl = hostUrl
    }
    
    public func loadRequest(api: ApiConfig, progressHandler: ((Progress) -> Void)? = nil, completionHandler: @escaping (Any) -> Void, onTask: @escaping (URLSessionTask?) -> Void) {
        var apiTarget = ApiTarget.init(api: api)
        guard let urlRequest = apiTarget.urlRequest(hostUrl: hostUrl) else {
            return
        }
        
        func start(request: Request) {
            
            func parseResponse<T: DataResponseSerializerProtocol>(request: DataRequest, responseSerializer: T) {
                request.response(responseSerializer: responseSerializer, completionHandler: completionHandler)
            }
            
            func parseDownloadReponse<T: DownloadResponseSerializerProtocol>(request: DownloadRequest, responseSerializer: T) {
                request.response(responseSerializer: responseSerializer, completionHandler: completionHandler)
            }
            
            if let dataRequest = request as? DataRequest {
                switch apiTarget.responseType {
                case .data:
                    parseResponse(request: dataRequest, responseSerializer: DataRequest.dataResponseSerializer())
                case .json(readingOptions: let readingOptions):
                    parseResponse(request: dataRequest, responseSerializer: DataRequest.jsonResponseSerializer(options: readingOptions))
                case .string:
                    parseResponse(request: dataRequest, responseSerializer: DataRequest.stringResponseSerializer())
                case .plist:
                    parseResponse(request: dataRequest, responseSerializer: DataRequest.propertyListResponseSerializer())
                }
            } else if let downloadRequest = request as? DownloadRequest {
                switch apiTarget.responseType {
                case .data:
                    parseDownloadReponse(request: downloadRequest, responseSerializer: DownloadRequest.dataResponseSerializer())
                case .json(readingOptions: let readingOptions):
                    parseDownloadReponse(request: downloadRequest, responseSerializer: DownloadRequest.jsonResponseSerializer(options: readingOptions))
                case .string:
                    parseDownloadReponse(request: downloadRequest, responseSerializer: DownloadRequest.stringResponseSerializer())
                case .plist:
                    parseDownloadReponse(request: downloadRequest, responseSerializer: DownloadRequest.propertyListResponseSerializer())
                }
            }

            request.resume()
        }
        
        func progress(request: Request) {
            if let progressHandler = progressHandler {
                switch request {
                case let request as DownloadRequest:
                    request.downloadProgress(queue: .main, closure: progressHandler)
                case let request as UploadRequest:
                    request.uploadProgress(queue: .main , closure: progressHandler)
                case let request as DataRequest:
                    request.downloadProgress(queue: .main, closure: progressHandler)
                default:
                    assert(false, "unsupported request type")
                }
            }
            
            switch apiTarget.requestType {
            case .getData, .postData:
                let afRequest = afSessionManager.request(urlRequest)
                progress(request: afRequest)
                start(request: afRequest)
            case .uploadFormData:
                afSessionManager.upload(multipartFormData: { (multipartFormData) in
                    for data in apiTarget.formData {
                        multipartFormData.append(data.data, withName: data.name, fileName: data.fileName, mimeType: data.mineType)
                    }
                }, with: urlRequest) { (result) in
                    switch result {
                    case .success(let request, _, _):
                        start(request: request)
                        progress(request: request)
                        onTask(request.task)
                    case .failure(_):
                        break
                    }
                }
            case .downloadData:
                let afRequest = afSessionManager.download(urlRequest) { _, _ -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                    return (apiTarget.downloadPath, [.createIntermediateDirectories, .removePreviousFile])
                }
                progress(request: afRequest)
                start(request: afRequest)
//                Request.serializeResponseData(response: HTTPURLResponse?, data: Data?, error: Error?)
            }
        }
    }
    
    
}
