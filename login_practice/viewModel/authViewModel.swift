//
//  authViewModel.swift
//  login_practice
//
//  Created by 박정태 on 2022/03/01.
//

import Foundation

class AuthViewModel: AuthViewModelProtocol {
    var auth: Auth?
    var network: Network = Network()
    
    required init () {}
    
    func signin(id: String, pw: String, success: @escaping () -> Void, fail: @escaping () -> Void) {
        
        let body: Dictionary<String, Any> = ["id": id, "pw": pw]
        self.network.postRequest(path: "/auth/jwt", body: body, success: {() -> Void in
            success()
        }, fail: {() -> Void in
            fail()
        })
    }
}
