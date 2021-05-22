//
//  VideoListCell.swift
//  YoutubeLikeApp
//
//  Created by hideto c. on 2021/05/22.
//

import UIKit

class VideoListCell: UICollectionViewCell {
  
    @IBOutlet weak var channelImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        channelImageView.layer.cornerRadius = 40 / 2
    }
}
