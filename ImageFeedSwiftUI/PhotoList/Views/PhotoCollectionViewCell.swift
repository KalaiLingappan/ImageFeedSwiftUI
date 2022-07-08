//
//  PhotoCollectionViewCell.swift
//  ImageFeed
//
//  Created by Kalaiprabbha L on 15/02/22.
//

import UIKit
import SDWebImage

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImgView: UIImageView!
    @IBOutlet weak var author: UILabel!

    private var cellModel: PhotoCellViewModel?

    func setImageFor(_ photo: Photo) {
        cellModel = PhotoCellViewModel(photo)
        author.text = photo.author
        
        photoImgView?.sd_setImage(with: cellModel?.url, placeholderImage: UIImage(named: "placeholder"), options: .progressiveDownload, completed: nil)
    }
}



