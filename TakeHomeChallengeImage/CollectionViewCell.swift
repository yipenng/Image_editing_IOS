//
//  CollectionViewCell.swift
//  TakeHomeChallengeImage
//
//  Created by yipeng li on 1/20/22.
//

import UIKit
import AlamofireImage

class CollectionViewCell: UICollectionViewCell {
    
    var image: Images! {
        didSet {
            guard let url = URL(string: image.url)
            else{
                return
            }
            posterView.af.setImage(withURL: url)
        }
    }
    
    @IBOutlet weak var posterView: UIImageView!
}
