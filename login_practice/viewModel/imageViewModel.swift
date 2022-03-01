//
//  imageViewModel.swift
//  login_practice
//
//  Created by 박정태 on 2022/03/01.
//

import UIKit

class ImageViewModel: ImageViewModelProtocol {
    var images: Array<Image> = []
    
    required init() {
    }
    
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
        let urlComponents = URLComponents(string: "http://127.0.0.1:3000/file")
        
        var requestURL = URLRequest(url: (urlComponents?.url)!)
        requestURL.httpMethod = "GET"
        requestURL.addValue("application/json", forHTTPHeaderField: "Content-Type") // POST
        
        let task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let jsonData = data {
                do {
                    let images = try JSONDecoder().decode(Array<Image>.self, from: jsonData)
                    self.images = images
                    success()
                } catch{
                    fail()
                }
                
            }
        }
        
        task.resume()
    }
    
    func upload(img: UIImage, success: @escaping () -> Void, fail: @escaping () -> Void) {
        print("이미지 업로드를 수행합니다.")
        let urlComponents = URLComponents(string: "http://127.0.0.1:3000/file")

        var requestURL = URLRequest(url: (urlComponents?.url)!)
        requestURL.httpMethod = "POST" // POST
        
        let boundary = "Boundary-\(UUID().uuidString)"
        requestURL.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = NSMutableData()
                
        // ImageView라면 다음과 같이 이미지 정보를 가져올 수 있다.
        // self.ImageView?.image?.pngData()
      
        // 이미지 폼에 추가
        // 만약 이미지가 여러개라면 반복문을 이용
        if let data = img.pngData() {
            print("data")
            httpBody.append(
                convertFileData(
                    fieldName: "file",
                    fileName: "imagename.png",
                    mimeType: "image/png",
                    fileData: data ,
                    using: boundary
                )
            )
        }
        
        httpBody.appendString("--\(boundary)--")
        requestURL.httpBody = httpBody as Data
        
        let task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            
//            let successsRange = 200..<300
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                print(statusCode)
                if statusCode == 201 {
                    success()
                    
                    
                } else if statusCode == 401 {
                    fail()
                }
            }
        }
        
        task.resume()
    }
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
      var fieldString = "--\(boundary)\r\n"
      fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
      fieldString += "\r\n"
      fieldString += "\(value)\r\n"

      return fieldString
    }
    
    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
      let data = NSMutableData()

      // ⭐️ 이미지가 여러 장일 경우 for 문을 이용해 data에 append 해줍니다.
      // (현재는 이미지 파일 한 개를 data에 추가하는 코드)
      data.appendString("--\(boundary)\r\n")
      data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
      data.appendString("Content-Type: \(mimeType)\r\n\r\n")
      data.append(fileData)
      data.appendString("\r\n")

      return data as Data
    }
}

// 이미지 업로드를 위한 인터페이스 확장
extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
