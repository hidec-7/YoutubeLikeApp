//
//  HomeViewController.swift
//  YoutubeLikeApp
//
//  Created by hideto c. on 2021/05/22.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController {
    
    private let cellId = "cellId"
    private var videoItems = [Item]()

    @IBOutlet private weak var videoListCollectionView: UICollectionView!
    @IBOutlet private weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        videoListCollectionView.delegate = self
        videoListCollectionView.dataSource = self
        
        videoListCollectionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
        profileImageView.layer.cornerRadius = 20
        
        fetchYoutubeSerachInfo()
    }

    private func fetchYoutubeSerachInfo() {
        let params = ["q": "iOSAcademy"]
        API.shared.request(path: .search, params: params, type: VideoModel.self) { (video) in
            self.videoItems = video.items
            let id = self.videoItems[0].snippet.channelId
            self.fetchYoutubeChannelInfo(id: id)
        }
    }
    
    private func fetchYoutubeChannelInfo(id: String) {
        let params = ["id": id]
        API.shared.request(path: .channels, params: params, type: ChannelModel.self) { (channel) in
            self.videoItems.forEach { (item) in
                item.channel = channel
            }
            self.videoListCollectionView.reloadData()
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        return .init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! VideoListCell
        cell.videoItem = videoItems[indexPath.row]
        
        return cell
    }
}
