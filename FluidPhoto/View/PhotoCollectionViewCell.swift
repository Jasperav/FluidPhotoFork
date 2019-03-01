//
//  PhotoCollectionViewCell.swift
//  FluidPhoto
//
//  Created by UetaMasamichi on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    override func layoutSubviews() {
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.bounds.height / 2
    }
}
