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
    let refreshControl = UIRefreshControl()
    let imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var ImageTableView: UITableView!

    var imageViewModel: ImageViewModel!
    var imgPhoto: UIImageView?
    var images: Array<Dictionary<String, Any>>?

    
    @IBAction func onClickUploadButtonHandler(_ sender: Any) {
            self.checkAlbumPermission()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Home 페이지 입니다.")
        self.imageViewModel = ImageViewModel()
        ImageTableView.delegate = self
        ImageTableView.dataSource = self
        
        // cell 내부에 따라 height를 유동적으로 바꿔줌
        ImageTableView.rowHeight = UITableView.automaticDimension
        
        self.initRefresh()
        
        if #available(iOS 10.0, *) {
            ImageTableView.refreshControl = refreshControl
        } else {
            ImageTableView.addSubview(refreshControl)
        }
        
        imagePickerController.delegate = self
        
        PHPhotoLibrary.requestAuthorization { status in }
        AVCaptureDevice.requestAccess(for: .video) { granted in }
        
        self.getLoadData()
    }
}

// 리프레시 컨트롤
extension HomeViewController {
    func initRefresh() {
        self.refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        self.refreshStyle()
        self.ImageTableView.refreshControl = self.refreshControl
    }
    
    func refreshStyle() {
        self.refreshControl.backgroundColor = UIColor.clear

        self.refreshControl.attributedTitle = NSAttributedString(string: "Loading Images",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        let originCount: Int = self.imageViewModel.images.count
        
        if self.refreshControl.isRefreshing == true {
            self.imageViewModel.loadData(success:{() -> Void in
                DispatchQueue.main.async { // main thread에서 동작하도록 함
                    self.ImageTableView.reloadData()
                    let count: Int = self.imageViewModel.images.count
                    print("origin count: \(originCount), new count\(count)")
                    if originCount == count {
                        refresh.endRefreshing()
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() ) { [weak self] in
                            refresh.endRefreshing()
                        }
                    }
                    
                }
            }, fail: {() -> Void in
                
            })
        }
    }
 
    //MARK: - UIRefreshControl of ScrollView
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(velocity.y < -0.1) {
            self.refreshTable(refresh: self.refreshControl)
        }
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
                    self.ImageTableView.reloadData()
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
        
        self.imageViewModel.getImageByNetwork(idx: indexPath.row, resizeWidth: self.ImageTableView.frame.width, success: {(image: UIImage) -> Void in
            cell.imageSrc.image = image
            cell.message.text = "\(Int(image.size.width)) * \(Int(image.size.height))"
        }, fail: {() -> Void in
            
        })
        
        return cell
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
