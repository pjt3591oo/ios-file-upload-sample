//
//  network.swift
//  login_practice
//
//  Created by 박정태 on 2022/03/02.
//

import UIKit
import Alamofire

class Network {
    let baseUrl: String = "http://localhost:3000"
    
}

// utils method
extension Network {
    func makeUrl(_ baseUrl: String, _ path: String ) -> String {
        return "\(baseUrl)\(path)"
    }
}

// basic request
extension Network {
    func postRequest(path: String, body: Dictionary<String, Any>, success: @escaping () -> Void, fail: @escaping () -> Void) {
            
            AF
            .request(
                self.makeUrl(self.baseUrl, path),
                method: .post,
                parameters: body,
                encoding: JSONEncoding.default
            )
            .validate(statusCode: 200..<300)
            .responseJSON{response  in
                switch response.result {
                 case .success:
                    success()
                 case .failure(let error):
                    print("[NETWORK ERROR] post request")
                    print(error)
                    fail()
                 }
            }
    }
    
    func getRequest(path: String, queryString: Dictionary<String, Any>, completion: @escaping (_ data: Any?) -> Void) {
        AF
            .request(
                self.makeUrl(self.baseUrl, path),
                method: .get,
                parameters: queryString,
                encoding: URLEncoding.default,
                headers: ["Content-Type":"application/json", "Accept":"application/json"]
            )
            .validate(statusCode: 200..<300)
            .responseJSON{ response in
                switch response.result {
                case .success(_) :
                    completion(response.data)
                case .failure(_) :
                    print("[NETWORK ERROR] get request")
                }
                
            }
    }
}

// multi form
extension Network {
    func fileUpload(path: String, img: UIImage, payload: Array<Dictionary<String, Any>>, completion: @escaping (_ isSuccess: Bool) -> Void) {
        if let data = img.pngData() {
            AF
                .upload(
                    multipartFormData: {multiPart in
                        multiPart.append(data, withName: "file", fileName: "test_logo.png", mimeType: "image/jpeg")
                    },
                    to: "http://localhost:3000/file"
                )
                .validate(statusCode: 200..<300)
                .uploadProgress(queue: .main, closure: { progress in
                    if progress.fractionCompleted < 1.0 {
                        print("업로드 중: \(progress.fractionCompleted)")
                    } else {
                        print("업로드 완료")
                    }
                })
                .responseJSON { (response) in
                    switch response.result {
                    case .success(_) :
                        completion(true)
                    case .failure(_):
                        completion(false)
                    }
                    
                }
        }
            
    }
}

