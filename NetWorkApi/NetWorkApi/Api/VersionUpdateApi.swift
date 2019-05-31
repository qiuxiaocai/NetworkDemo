//
//  VersionUpdateApi.swift
//  NetWorkApi
//
//  Created by qiuxiaocai on 2019/5/31.
//  Copyright © 2019 Bella. All rights reserved.
//

import Foundation

public class VersionUpdateApi: BaseApi<VersionUpdateResponse> {
    public var apiPath: String {
        return "appLaunchVersion/getAppLaunchVersion"
    }
    
    public var params: [String : Any] {
        let pramDict = ["mobileType": "ios"]
        
        var reqStr: String?
        if let jsonData = try? JSONSerialization.data(withJSONObject: pramDict, options: .prettyPrinted) {
            reqStr = String(data: jsonData, encoding: .utf8)
        }
        return ["req" : reqStr ?? ""]
    }
}

public class VersionUpdateResponse: BaseResponse {
    public var versionInfo: VersionInfo?
    public var versionInfomation: VersionInfomation?
    
    override func receive(dict: [String : Any]?) {
        versionInfo = JSONDecoder.decode(VersionInfo.self, with: dict)
        versionInfomation = JSONDecoder.decode(VersionInfomation.self, with: dict)
    }
}

/// Model里的命名和返回的json内的字段一模一样
public struct VersionInfo: Decodable {
    public var mobileType: String?
    public var createTime: Int?
    public var id: Int?
    public var versionId: String?
    public var isForceUpdate: Int   //1 强制更新 2建议更新s
}

extension VersionInfo :CustomDebugStringConvertible {
    public var debugDescription: String {
        let idString = String(describing: id)
        let isForceUpdateForString = String(describing: isForceUpdate)
        let createTimeString = String(describing: createTime)
        return "id = \(idString)\n" + "versionId = \(versionId ?? "")\n" + "isForceUpdate = \(isForceUpdateForString)\n" + "mobileType = \(mobileType ?? "")\n" + "createTime = \(createTimeString)\n"
    }
}

/// Model里的命名自定义
public struct VersionInfomation: Decodable {
    public var mobile: String?
    public var create: Int?
    public var xxxid: Int?
    public var versionNum: String?
    public var isForceUpdate: Int   //1 强制更新 2建议更新
    
    enum CodingKeys: String, CodingKey {
        case mobile = "mobileType"
        case create = "createTime"
        case xxxid = "id"
        case versionNum = "versionId"
        case isForceUpdate
    }
}

