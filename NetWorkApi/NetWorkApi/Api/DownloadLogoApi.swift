//
//  DownloadLogoApi.swift
//  NetWorkApi
//
//  Created by qiuxiaocai on 2019/6/4.
//  Copyright © 2019 Bella. All rights reserved.
//

import Foundation
import CCNetwork

///
public class DownloadLogoApi: BaseApi<DownloadLogoResponse> {
    
    public var apiPath: String {
        ///http://www.hangge.com/blog/images/logo.png
        return "blog/images/logo.png"
    }
    
    public var requestType: RequestType {
        return .downloadData
    }
    
    public var responseType: ResponseType {
        return .data
    }
    
//    public var downloadStoredName: String? {
//        return "mylogo.png"
//    }
    
}

public class DownloadLogoResponse: BaseResponse {
    
    public var value: Data?
    
    override var adaptorType: AdaptorType {
        return .common
    }
    override func receive(data: Data?) {

        if data != nil {
            status = .success
            value = data
        } else {
            status = .unknown
        }
    }

}



