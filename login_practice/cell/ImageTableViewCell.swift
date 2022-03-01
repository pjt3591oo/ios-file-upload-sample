//
//  ImageTableViewCell.swift
//  login_practice
//
//  Created by 박정태 on 2022/02/26.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    @IBOutlet weak var imageSrc: UIImageView!
    @IBOutlet weak var message: UILabel!
}

extension ImageTableViewCell {
    func getImageSize() -> Array<Double> {
        if let image = self.imageSrc.image {
            return [
                image.size.width, image.size.height
            ]
        } else {
            return [0.0, 0.0]
        }
        
    }
}
