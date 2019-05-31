//
//  UploadImageApi.swift
//  NetWorkApi
//
//  Created by qiuxiaocai on 2019/5/31.
//  Copyright © 2019 Bella. All rights reserved.
//

import Foundation
import CCNetwork

public class UploadImageApi: BaseApi<UploadImageResponse> {
    
    public var apiPath: String {
        return "upload.php"
    }
    
    public var formData: [FormData] {
        return []
    }
    
}

public class UploadImageResponse: BaseResponse {
    
}
