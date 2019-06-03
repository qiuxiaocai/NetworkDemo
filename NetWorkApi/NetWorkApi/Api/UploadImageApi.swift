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
    
    var image: UIImage
    var app: String
    var key: String
    
    public init(image: UIImage, app: String, key: String) {
        self.image = image
        self.app = app
        self.key = key
    }
    
    public var apiPath: String {
        return "upload.php"
    }
    
    public var formData: [FormData] {
        let formDataPic = FormData.file(data: image.jpegData(compressionQuality: 0.5) ?? Data(), name: "pic", fileName: "file", mineType: nil)
        let formDataApp = FormData.param(data: app.data(using: .utf8) ?? Data(), name: "app")
        let formDataKey = FormData.param(data: key.data(using: .utf8) ?? Data(), name: "key")
        return [formDataApp, formDataKey, formDataPic]
    }
    
    public var requestType: RequestType {
        return .uploadFormData
    }
    
}

public class UploadImageResponse: BaseResponse {
    
    public var imageUrl: String?
    
    override var adaptorType: AdaptorType {
        return .common
    }
    override func receive(dict: [String : Any]?) {
        if let dict = dict {
            let code = dict["code"] as? Int
            status = statusWithCode(code: code)
            message = dict["msg"] as? String
            imageUrl = dict["pic"] as? String
        }
    }
    
    private func statusWithCode(code: Int?) -> ResponseStatus {
        switch code {
        case 1:
            return .success
        default:
            return .unknown
        }
    }
    
}
