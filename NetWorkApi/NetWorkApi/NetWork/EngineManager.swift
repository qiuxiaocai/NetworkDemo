//
//  EngineManager.swift
//  NetWorkApi
//
//  Created by qiuxiaocai on 2019/5/31.
//  Copyright © 2019 Bella. All rights reserved.
//

import Foundation
import CCNetwork

enum ApiHostType {
    case imageHost
    case javaHost
    
    /// 是否生产环境
    func isProduction() -> Bool {
        return false
    }
    
    func hostUrl() -> String {
        switch self {
        case .imageHost:
            return isProduction() ? "http://up.youxinpai.com/" : "http://up.youxinpai.com/"
        case .javaHost:
            return isProduction() ? "https://webserver.youxinpai.com" : "https://webserver-app.youxinpai.com"
        }
    }
    
}

extension Engine {
    public static let imageEngine = Engine.init(hostUrl: ApiHostType.imageHost.hostUrl())
    public static let javaEngine = Engine.init(hostUrl: ApiHostType.javaHost.hostUrl())
}


