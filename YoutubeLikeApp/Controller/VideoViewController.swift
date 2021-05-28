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
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: []) {
                imageView.transform = .identity
                self.view.layoutIfNeeded()
            }
        }
    }

}
