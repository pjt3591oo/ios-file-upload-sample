//
//  imageViewModel.swift
//  login_practice
//
//  Created by 박정태 on 2022/03/01.
//

import UIKit

class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}

class ImageViewModel: ImageViewModelProtocol {
    var images: Array<Image> = []
    
    var network: Network = Network()
    
    required init() { }
    
    func getImageByNetwork(idx: Int, success: (_ data: UIImage) -> Void, fail: () -> Void) {
        
        let filePath: String = self.images[idx].path
        // 캐시에 사용될 Key 값
        let cacheKey = NSString(string: filePath)
        
        // 캐시확인
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) { // 해당 Key 에 캐시이미지가 저장되어 있으면 이미지를 사용
            success(cachedImage)
            return
        }
        
        do {
            // background
            if let data = try? Data(contentsOf: URL(string: "http://127.0.0.1:3000/\(filePath)")!) {
                // main tread
                if let image = UIImage(data: data) {
                    // 캐시저장
                    ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                    success(image)
                }
                fail()
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

