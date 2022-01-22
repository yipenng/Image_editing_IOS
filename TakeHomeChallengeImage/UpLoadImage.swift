//
//  UpLoadImage.swift
//  TakeHomeChallengeImage
//
//  Created by yipeng li on 1/22/22.
//

import Foundation


struct UpLoadImages : Decodable {
    let imageData: Data
    var creator = "Yipengg@gmail.com"
    let Oldurl: String
}
