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
    
    func getImageByNetwork(idx: Int, resizeWidth: CGFloat, success: (_ data: UIImage) -> Void, fail: () -> Void) {
        
        let filePath: String = self.images[idx].path
        // 캐시에 사용될 Key 값
        let cacheKey = NSString(string: filePath)
        
        // 캐시확인
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) { // 해당 Key 에
            success(cachedImage)
            return
        }
        
        do {
            if let data = try? Data(contentsOf: URL(string: "http://127.0.0.1:3000/\(filePath)")!) {
                // main tread
                if var image = UIImage(data: data) {
                    // 리사이즈
                    if resizeWidth > 0 {
                        let cellImgWidth:CGFloat = CGFloat(image.size.width)
                        let cellImgHeight:CGFloat = CGFloat(image.size.height)
                        let rate:CGFloat = resizeWidth / cellImgWidth
                        image = image.resizeTopAlignedToFill(newWidth: resizeWidth, newHeight: cellImgHeight * rate)
                    }
                    
                    ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                    success(image)
                    return
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
            } catch {
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
            } catch {
                fail()
            }
        })
      
    }
    
}

// 이미지 리사이즈
extension UIImage {
    func resizeTopAlignedToFill(newWidth: CGFloat, newHeight: CGFloat) -> UIImage {

        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
