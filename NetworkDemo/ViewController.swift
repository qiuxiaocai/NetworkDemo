//
//  ViewController.swift
//  NetworkDemo
//
//  Created by qiuxiaocai on 2019/5/27.
//  Copyright © 2019 Bella. All rights reserved.
//

import UIKit
import NetWorkApi

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func requestButtonClicked(_ sender: Any) {
        let api = VersionUpdateApi.init()
        api.progressHandler = { progress in
            print(progress.localizedDescription ?? "")
        }
        api.completionHandler = { result in
            switch result {
            case .success(let response):
                if response.status == ResponseStatus.success {
                    print(response.versionInfo.debugDescription)
                    print(response.versionInfomation.debugDescription)
                }
            case .failure(let error):
                print("request failure error = \(error)")
            }
        }
        api.start(in: .javaEngine)
    }
    
    @IBAction func uploadButtonClicked(_ sender: Any) {
        let api = UploadImageApi.init(image: #imageLiteral(resourceName: "IMG_9152"), app: "mobile", key: "239fjkf342fwv342")
        api.progressHandler = { progress in
            print(progress.localizedDescription ?? "")
        }
        api.completionHandler = { result in
            switch result {
            case .success(let response):
                if response.status == ResponseStatus.success {
                    print("imageUrl == \(response.imageUrl ?? "")")
                } else {
                    print(response.message ?? "未知错误")
                }
            case .failure(let error):
                print(error)
            }
        }
        api.start(in: .imageEngine)
    }
    
    @IBAction func DownloadButtonClicked(_ sender: Any) {
        let api = DownloadLogoApi()
//        api.completionHandler = { (result) in
//            switch result {
//            case .success(let response):
//                if response.status == .success {
//                    print("parse success")
//                    let image = UIImage.init(data: response.value ?? Data())
//                    print(String(describing: image))
//                } else {
//                    print("parse error")
//                }
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
        
        api.progressHandler = { (progress) in
            print(progress.localizedDescription ?? "")
        }
        api.destinationUrlHandler = { (destinationURL) in
            print("destinationURL = \(destinationURL?.absoluteString ?? "获取目的url失败")")
        }
        api.start(in: .hanggeEngine)
    }
    
    
}

