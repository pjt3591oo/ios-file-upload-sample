//
//  ViewController.swift
//  login_practice
//
//  Created by 박정태 on 2022/02/26.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var idFiled: UITextField!
    @IBOutlet weak var pwField: UITextField!
    
    @IBOutlet weak var SigninBtn: UIButton!
    @IBOutlet weak var SignupBtn: UIButton!
    
    let radius = 16
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("로그인 페이지 입니다.")
        SigninBtn.layer.cornerRadius = CGFloat(radius)
        SignupBtn.layer.cornerRadius = CGFloat(radius)
        
        idFiled.layer.cornerRadius = CGFloat(radius)
        pwField.layer.cornerRadius = CGFloat(radius)
    }

    @IBAction func onClickSigninHandler(_ sender: Any) {
        if let id = idFiled.text, let pw = pwField.text {
            print("\(id), \(pw)")
            self.login(id: id, pw: pw)
        } else {
            self.failNoti(title: "로그인 실패", desc: "아이디와 비밀번호를 다시 확인해주세요")
        }
    }
    
    @IBAction func onClickSignupHandler(_ sender: Any) {
        self.moveToSignupPage()
    }
    
    func login(id: String, pw: String) {
        let urlComponents = URLComponents(string: "http://127.0.0.1:3000/auth/jwt")
        let dicData = ["id": id, "pw":pw] as Dictionary<String, Any>?
        let jsonData = try! JSONSerialization.data(withJSONObject: dicData!, options: [])
        
        var requestURL = URLRequest(url: (urlComponents?.url)!)
        requestURL.httpMethod = "POST"
        requestURL.httpBody = jsonData
        requestURL.addValue("application/json", forHTTPHeaderField: "Content-Type") // POST
        
        let task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                DispatchQueue.main.async { // main thread에서 동작하도록 함
                    if statusCode == 201 {
                        self.moveToHomePage()
                    } else if statusCode == 401 {
                        self.failNoti(title: "로그인 실패", desc: "아이디와 비밀번호가 일치하지 않습니다.")
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func failNoti(title: String, desc: String) {
        // preferredStyle: .alert
        // preferredStyle: .actionSheet 하단에서 나옴
        let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
        let confirmActionBtn = UIAlertAction(title: "확인", style: .default) { (_) in
           //  여기에 실행할 코드
        }
        let cancelActionBtn = UIAlertAction(title: "취소", style: .default) { (_) in
           //  여기에 실행할 코드
        }
        
        alert.addAction(cancelActionBtn)
        alert.addAction(confirmActionBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
    func moveToSignupPage() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "SignupViewController") as SignupViewController
        controller.modalPresentationStyle = .fullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        // showDetailViewController(controller, sender: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func moveToHomePage() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "HomeViewController") as HomeViewController
        
        // showDetailViewController(controller, sender: nil)
        self.navigationController?.setViewControllers([controller], animated: true)
    }
}

