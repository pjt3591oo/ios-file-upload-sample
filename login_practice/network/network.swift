//
//  network.swift
//  login_practice
//
//  Created by 박정태 on 2022/03/02.
//

import UIKit

class Network {
    let baseUrl: String = "http://localhost:3000"
    
    func postRequest(path: String, body: Dictionary<String, Any>, success: @escaping () -> Void, fail: @escaping () -> Void) {
        let urlComponents = URLComponents(string: self.makeUrl(self.baseUrl, path))
        let payload = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        var requestURL = URLRequest(url: (urlComponents?.url)!)
        requestURL.httpMethod = "POST"
        requestURL.httpBody = payload
        requestURL.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 201 || statusCode == 200{
                    success()
                } else if statusCode == 401 || statusCode == 400 {
                    fail()
                } else {
                    fail()
                }
            }
        }
        
        task.resume()
    }
    
    func getRequest(path: String, queryString: Dictionary<String, Any>, completion: @escaping (_ data: Data?,_ response: URLResponse?, _ error:Error?) -> Void) {
        let urlComponents = URLComponents(string: self.makeUrl(self.baseUrl, path))
        
        var requestURL = URLRequest(url: (urlComponents?.url)!)
        requestURL.httpMethod = "GET"
        requestURL.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: requestURL, completionHandler: completion)
        
        task.resume()
    }
    
}

extension Network {
    func makeUrl(_ baseUrl: String, _ path: String ) -> String {
        return "\(baseUrl)\(path)"
    }
}

extension Network {
    func fileUpload(path: String, imgs: Array<UIImage>, payload: Array<Dictionary<String, Any>>, completion: @escaping (_ data: Data?,_ response: URLResponse?, _ error:Error?) -> Void) {
        print("이미지 업로드를 수행합니다.")
        let urlComponents = URLComponents(string: self.makeUrl(self.baseUrl, path))

        var requestURL = URLRequest(url: (urlComponents?.url)!)
        requestURL.httpMethod = "POST" // POST
        
        let boundary = "Boundary-\(UUID().uuidString)"
        requestURL.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = NSMutableData()
                
        // ImageView라면 다음과 같이 이미지 정보를 가져올 수 있다.
        // self.ImageView?.image?.pngData()
      
        for img in imgs{
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
        }
        
        
        httpBody.appendString("--\(boundary)--")
        requestURL.httpBody = httpBody as Data
        
        let task = URLSession.shared.dataTask(with: requestURL, completionHandler: completion)
        
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
