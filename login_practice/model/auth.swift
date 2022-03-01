//
//  auth.swift
//  login_practice
//
//  Created by 박정태 on 2022/03/01.
//

import Foundation

struct Auth: Codable {
    var accessToken: String
    var name: String
    
    init (accessToken: String, name: String) {
        self.accessToken = accessToken
        self.name = name
    }
}

protocol AuthViewModelProtocol {
    init ()
}
