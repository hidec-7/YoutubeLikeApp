//
//  VideoListCell.swift
//  YoutubeLikeApp
//
//  Created by hideto c. on 2021/05/22.
//

import UIKit
import Nuke

class VideoListCell: UICollectionViewCell {
    
    var videoItem: Item? {
        didSet {
            if let url = URL(string: videoItem?.snippet.thumbnails.medium.url ?? "") {
                Nuke.loadImage(with: url, into: thumbnailImageView)
            }
            if let channelUrl = URL(string: videoItem?.channel?.items[0].snippet.thumbnails.medium.url ?? "") {
                Nuke.loadImage(with: channelUrl, into: channelImageView)
            }
            
            titleLabel.text = videoItem?.snippet.title
            descriptionLabel.text = videoItem?.snippet.description
        }
    }
  
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var channelImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        channelImageView.layer.cornerRadius = 40 / 2
    }
}
