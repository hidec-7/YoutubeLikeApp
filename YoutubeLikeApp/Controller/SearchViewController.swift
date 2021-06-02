//
//  SearchViewController.swift
//  YoutubeLikeApp
//
//  Created by hideto c. on 2021/06/02.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let videoCellId = "cellId"
    var video: VideoModel?
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Youtubuを検索"
        sb.delegate = self
        
        return sb
    }()
    
    lazy var videoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.titleView = searchBar
        navigationItem.titleView?.frame = searchBar.frame
        
        videoCollectionView.frame = self.view.frame
        self.view.addSubview(videoCollectionView)
        videoCollectionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: videoCellId)
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
        // TODO: API通信
        let  searchText = searchBar.text ?? ""
        fetchYoutubeSerachInfo(searchText: searchText)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let prevController = self.presentingViewController as! BaseTabBarController
        let videoList = prevController.viewControllers?[0] as! HomeViewController
        videoList.selectedItem = video?.items[indexPath.row]
        
        dismiss(animated: true) {
            NotificationCenter.default.post(name: .init("searchedItem"), object: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        
        return .init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return video?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = videoCollectionView.dequeueReusableCell(withReuseIdentifier: videoCellId, for: indexPath) as! VideoListCell
        cell.videoItem = video?.items[indexPath.row]
        
        return cell
    }
}

// API通信
extension SearchViewController {
    
    private func fetchYoutubeSerachInfo(searchText: String) {
        let params = ["q": searchText]
        API.shared.request(path: .search, params: params, type: VideoModel.self) { (video) in
            self.video = video
            self.fetchYoutubeChannelInfo()
        }
    }
    
    private func fetchYoutubeChannelInfo() {
        guard let video = self.video else { return }
        
        for (index, item) in video.items.enumerated() {
            let params = ["id": item.snippet.channelId]
            API.shared.request(path: .channels, params: params, type: ChannelModel.self) { (channel) in
                self.video?.items[index].channel = channel
                self.videoCollectionView.reloadData()
            }
        }
    }
}
