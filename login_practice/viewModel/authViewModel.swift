//
//  authViewModel.swift
//  login_practice
//
//  Created by 박정태 on 2022/03/01.
//

import Foundation

class AuthViewModel: AuthViewModelProtocol {
    var auth: Auth?
    
    required init () {
        
    }
    
    func signin(id: String, pw: String, success: @escaping () -> Void, fail: @escaping () -> Void) {
        let urlComponents = URLComponents(string: "http://127.0.0.1:3000/auth/jwt")
        let dicData = ["id": id, "pw": pw] as Dictionary<String, Any>?
        let jsonData = try! JSONSerialization.data(withJSONObject: dicData!, options: [])
        
        var requestURL = URLRequest(url: (urlComponents?.url)!)
        requestURL.httpMethod = "POST"
        requestURL.httpBody = jsonData
        requestURL.addValue("application/json", forHTTPHeaderField: "Content-Type") // POST
        
        let task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 201 {
                    success()
                } else if statusCode == 401 || statusCode == 400 {
                    fail()
                }
            }
        }
        
        task.resume()
    }
}
