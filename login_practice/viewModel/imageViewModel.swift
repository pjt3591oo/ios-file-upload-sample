//
//  imageViewModel.swift
//  login_practice
//
//  Created by 박정태 on 2022/03/01.
//

import UIKit

class ImageViewModel: ImageViewModelProtocol {
    var images: Array<Image> = []
    
    var network: Network = Network()
    
    required init() { }
    
    func getImageByNetwork(idx: Int, success: (_ data: Data) -> Void, fail: () -> Void) {
        do {
            // background
            if let data = try? Data(contentsOf: URL(string: "http://127.0.0.1:3000/\(self.images[idx].path)")!) {
                // main tread
                success(data)
            }
        } catch {
            fail()
        }
    }
    
    func loadData(success:  @escaping () -> Void, fail:  @escaping () -> Void) {
        let queryString: Dictionary<String, Any> = [:]
        
        self.network.getRequest(path: "/file", queryString: queryString, completion: {(_ data: Data?, _ response: URLResponse?, _ error:Error?) -> Void in
            do {
                if let jsonData = data {
                    let images = try JSONDecoder().decode(Array<Image>.self, from: jsonData)
                    self.images = images
                }
                success()
            } catch let error as NSError{
                fail()
            }
        })
    }
    
    func upload(img: UIImage, success: @escaping () -> Void, fail: @escaping () -> Void) {
        self.network.fileUpload(path: "/file", imgs: [img], payload: [[:]], completion: {(_ data: Data?, _ response: URLResponse?, _ error:Error?) -> Void in
            do {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                   if statusCode == 201 {
                       success()
                   } else if statusCode == 401 {
                       fail()
                   }
               }
            } catch let error as NSError{
                fail()
            }
        })
      
    }
    
}

