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
    
    var authViewModel: AuthViewModel!
    
    let radius = 16
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("로그인 페이지 입니다.")
        self.authViewModel = AuthViewModel()
        
        SigninBtn.layer.cornerRadius = CGFloat(radius)
        SignupBtn.layer.cornerRadius = CGFloat(radius)
        
        idFiled.layer.cornerRadius = CGFloat(radius)
        pwField.layer.cornerRadius = CGFloat(radius)
    }

    @IBAction func onClickSigninHandler(_ sender: Any) {
               if let id = idFiled?.text, let pw = pwField?.text {
            print("\(id) \(pw)")
            self.authViewModel.signin(id: id, pw: pw, success:{() -> Void in
                DispatchQueue.main.async {
                    self.moveToHomePage()
                }
            }, fail: {() -> Void in
                DispatchQueue.main.async {
                    TowButtonNotification(target: self, title: "로그인 실패", desc: "아이디와 비밀번호가 일치하지 않습니다.", confirmHandler: {() -> Void in }, cancelHandler: {() -> Void in })
                }
            })
        } else {
            print("!")
            TowButtonNotification(target: self, title: "로그인 실패", desc: "아이디와 비밀번호를 다시 확인해주세요", confirmHandler: {() -> Void in }, cancelHandler: {() -> Void in })
        }
    }
    
    @IBAction func onClickSignupHandler(_ sender: Any) {
        self.moveToSignupPage()
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

