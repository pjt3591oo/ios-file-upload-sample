//
//  HomeViewController.swift
//  login_practice
//
//  Created by 박정태 on 2022/02/26.
//

import UIKit
import Photos

// deletegate, datasource 프로토콜을 채택한 extension 영역은 어느 레이어에서 관리를해야할 까

class HomeViewController: UIViewController {
    let imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var ImageTableView: UITableView!
    
    var imageViewModel: ImageViewModel!
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
        self.imageViewModel = ImageViewModel()
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
        self.imageViewModel.upload(img: img, success: {() -> Void in
            DispatchQueue.main.async { // main thread에서 동작하도록 함
                TowButtonNotification(target: self, title: "업로드 완료", desc: "이미지 업로드를 성공적으로 마쳤습니다.", confirmHandler: {() -> Void in
                    self.getLoadData()
                }, cancelHandler: {() -> Void in
                    self.getLoadData()
                })
            }
        }, fail: {() -> Void in
            DispatchQueue.main.async { // main thread에서 동작하도록 함x
            }
        })
    }
    
}

// 앨범
// TODO: 어느 레이어에서 관리를 해야하나...
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
// TODO: 어느 레이어에서 관리를 해야하나...
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func getLoadData() {
        self.imageViewModel.loadData(success:{() -> Void in
            DispatchQueue.main.async { // main thread에서 동작하도록 함
                self.ImageTableView.reloadData()
            }
        }, fail: {() -> Void in
            
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.imageViewModel.images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ImageTableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for:indexPath) as! ImageTableViewCell
        
        self.imageViewModel.getImageByNetwork(idx: indexPath.row, success: {(data: Data) -> Void in 
            DispatchQueue.main.async {
                cell.imageSrc.image = UIImage(data: data)
                let cellImgSize: Array<Double> = cell.getImageSize() // 0: width, 1: height
                cell.message.text = "\(cellImgSize[0]) * \(cellImgSize[1])"
            }
        }, fail: {() -> Void in
            
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.ImageTableView.frame.width
    }
}

extension HomeViewController {
    func getImageViewSize () -> Any {
        return [
            self.ImageTableView.frame.width,
            self.ImageTableView.frame.height
        ]
    }
}