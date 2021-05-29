//
//  VideoViewController.swift
//  YoutubeLikeApp
//
//  Created by hideto c. on 2021/05/28.
//

import UIKit
import Nuke

class VideoViewController: UIViewController {
    
    var selectedItem: Item?

    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var baseBackGroundView: UIView!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var videoImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoImageViewTrainlingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.baseBackGroundView.alpha = 1
        }
    }
    
    private func setupViews() {
        channelImageView.layer.cornerRadius = 45 / 2

        if let url = URL(string: selectedItem?.snippet.thumbnails.medium.url ?? "") {
            Nuke.loadImage(with: url, into: videoImageView)
        }
        if let channelUrl = URL(string: selectedItem?.channel?.items[0].snippet.thumbnails.medium.url ?? "") {
            Nuke.loadImage(with: channelUrl, into: channelImageView)
        }
        
        videoTitleLabel.text = selectedItem?.snippet.title
        channelTitleLabel.text = selectedItem?.channel?.items[0].snippet.title
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panVideoImageView))
        videoImageView.addGestureRecognizer(panGesture)
    }
    
    @objc private func panVideoImageView(gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view else { return }
        let move = gesture.translation(in: imageView)
        
        if gesture.state == .changed {
            imageView.transform = CGAffineTransform(translationX: 0, y: move.y)
            // 左右のpadding設定
            let movingConstant = move.y / 30
            
            if videoImageLeadingConstraint.constant <= 12 {
                videoImageViewTrainlingConstraint.constant -= movingConstant
                videoImageLeadingConstraint.constant += movingConstant
            }
            
            // imageViewの高さの動き
            // 280(最大値) - 70(最小値) = 210
            let parantViewHeight = self.view.frame.height
            let heightRatio = 210 / (parantViewHeight - (parantViewHeight / 6))
            let moveHeight = move.y * heightRatio
            
            videoImageViewHeightConstraint.constant = 280 - moveHeight
            // imageViewの横幅の動き 150(最小値)
            let originalWidth  = self.view.frame.width
            let minimumImageViewTrailingConstant = -(originalWidth - (150 + 12))
            let constant = originalWidth - move.y
            if minimumImageViewTrailingConstant > constant {
                videoImageViewTrainlingConstraint.constant = minimumImageViewTrailingConstant
                return
            }
            if constant < -12 {
                videoImageViewTrainlingConstraint.constant = constant            }
            
        } else if gesture.state == .ended {
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: []) {
                self.backToIdentityAllViews(imageView: imageView as! UIImageView)
            }
        }
    }
    
    private func backToIdentityAllViews(imageView: UIImageView) {
        imageView.transform = .identity
        self.videoImageViewHeightConstraint.constant = 280
        self.videoImageLeadingConstraint.constant = 0
        self.videoImageViewTrainlingConstraint.constant = 0
        
        self.view.layoutIfNeeded()
    }

}
