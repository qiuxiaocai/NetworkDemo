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
        let api = UploadImageApi.init(image: #imageLiteral(resourceName: "emission_carmodel_tips"), app: "mobile", key: "239fjkf342fwv342")
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
    
    
}

