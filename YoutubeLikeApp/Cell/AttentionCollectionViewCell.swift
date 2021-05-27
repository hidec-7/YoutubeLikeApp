//
//  AttentionCollectionViewCell.swift
//  YoutubeLikeApp
//
//  Created by hideto c. on 2021/05/28.
//

import UIKit

class AttentionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .purple
    }
}
