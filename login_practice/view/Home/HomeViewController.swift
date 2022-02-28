//
//  HomeViewController.swift
//  login_practice
//
//  Created by 박정태 on 2022/02/26.
//

import UIKit
import Photos

class HomeViewController: UIViewController {
    let imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var ImageTableView: UITableView!
    
    
    var imgPhoto: UIImageView?
    var images: Array<Dictionary<String, Any>>?

    
    @IBAction func onClickUploadButtonHandler(_ sender: Any) {
                self.checkAlbumPermission()
    }
    
    @IBAction func onClickReloadHandler(_ sender: Any) {
        print("reload?")
        self.getLoadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Home 페이지 입니다.")
        ImageTableView.delegate = self
        ImageTableView.dataSource = self
        
        imagePickerController.delegate = self
        
        PHPhotoLibrary.requestAuthorization { status in }
        AVCaptureDevice.requestAccess(for: .video) { granted in }
        
        self.getLoadData()
    }
}

// 이미지 업로드
extension HomeViewController {
    func imageUpload(img: UIImage) {
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
                    DispatchQueue.main.async { // main thread에서 동작하도록 함
                        self.failNoti(title: "업로드 완료", desc: "이미지 업로드를 성공적으로 마쳤습니다.")
                        
                    }
                    
                } else if statusCode == 401 {
                    DispatchQueue.main.async { // main thread에서 동작하도록 함
                        
                    }
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

// 앨범
extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
       
    // 앨범에서 이미지 선택 시 호출
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imgPhoto?.image = image
            print("이미지 선택완료")
            // 이미지 선택이 완료 되었으면 서버로 전송한다.
            DispatchQueue.main.async {
                self.imageUpload(img: image)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func checkAlbumPermission(){
        PHPhotoLibrary.requestAuthorization( { status in
            switch status{
            case .authorized:
                print("Album: 권한 허용")
                self.openAlbum()
            case .denied:
                print("Album: 권한 거부")
            case .restricted, .notDetermined:
                print("Album: 선택하지 않음")
            default:
                break
            }
        })
    }
    
    private func openAlbum() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            DispatchQueue.main.async {
                self.imagePickerController.sourceType = .photoLibrary;
                self.imagePickerController.allowsEditing = true
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            
        }
    }
}

// 테이블 뷰
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func getLoadData() {
        let urlComponents = URLComponents(string: "http://127.0.0.1:3000/file")
        
        var requestURL = URLRequest(url: (urlComponents?.url)!)
        requestURL.httpMethod = "GET"
        requestURL.addValue("application/json", forHTTPHeaderField: "Content-Type") // POST
        
        let task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let jsonData = data {
                do {
                    let j = try JSONSerialization.jsonObject(with: jsonData, options:[]) as! Array<Dictionary<String, Any>>
                    let images = j as! Array<Dictionary<String, Any>>
                    self.images = images
                    // self.TableViewMain.reloadData() // thread에서 호출이 동작함
                    DispatchQueue.main.async { // main thread에서 동작하도록 함
                        self.ImageTableView.reloadData()
                    }
                } catch{ }
                
            }
        }
        
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let i = images {
            return i.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ImageTableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for:indexPath) as! ImageTableViewCell
        if let images = images {
            let u = images[indexPath.row]
            
            print("\(indexPath.row)")

            do {
                // background
                if let data = try? Data(contentsOf: URL(string: "http://127.0.0.1:3000/\(u["path"]!)")!) {
                    // main tread
                    DispatchQueue.main.async {
                        cell.imageSrc.image = UIImage(data: data)
                        if let image = cell.imageSrc.image {
                            let r = self.ImageTableView.frame.width / image.size.width
                            let calcWidth = image.size.width + (image.size.width * r)
                            let calcHeight = image.size.height + (image.size.height * r)
                            print("확정된 너비: \(calcWidth), 확정된 높이: \(calcHeight)")
                        }
                        
                        cell.message.text = "\(indexPath.row)번째 이미지 입니다."
                    }
                }
            } catch {
                print("error")
            }
        }
        
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.ImageTableView.frame.width
    }
}

extension HomeViewController {
    func failNoti(title: String, desc: String) {
        // preferredStyle: .alert
        // preferredStyle: .actionSheet 하단에서 나옴
        let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
        let confirmActionBtn = UIAlertAction(title: "확인", style: .default) { (_) in
           //  여기에 실행할 코드
            self.getLoadData()
        }
        let cancelActionBtn = UIAlertAction(title: "취소", style: .default) { (_) in
           //  여기에 실행할 코드
            self.getLoadData()
        }
        
        alert.addAction(cancelActionBtn)
        alert.addAction(confirmActionBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
}
