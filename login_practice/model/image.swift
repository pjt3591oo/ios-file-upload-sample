//
//  image.swift
//  login_practice
//
//  Created by 박정태 on 2022/03/01.
//

import Foundation

struct Image:Codable {
    var path: String
    var name: String
    var id: Int
    
    init (path: String, name: String, id: Int) {
        self.path = path
        self.name = name
        self.id = id
    }
}

extension Encodable {
    var toDictionary : [String: Any]? {
        guard let object = try? JSONEncoder().encode(self) else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: object, options: []) as? [String:Any] else { return nil }
        return dictionary
    }
}
 

protocol ImageViewModelProtocol {
    init ()
}
