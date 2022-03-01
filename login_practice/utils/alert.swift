//
//  alert.swift
//  login_practice
//
//  Created by 박정태 on 2022/03/01.
//

import UIKit

func TowButtonNotification (target: UIViewController, title: String, desc: String, confirmHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) {
    // preferredStyle: .alert
    // preferredStyle: .actionSheet 하단에서 나옴
    let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
    let confirmActionBtn = UIAlertAction(title: "확인", style: .default) { (_) in
       //  여기에 실행할 코드
        confirmHandler()
    }
    let cancelActionBtn = UIAlertAction(title: "취소", style: .default) { (_) in
       //  여기에 실행할 코드
        cancelHandler()
    }
    
    alert.addAction(cancelActionBtn)
    alert.addAction(confirmActionBtn)
    target.present(alert, animated: true, completion: nil)
}
