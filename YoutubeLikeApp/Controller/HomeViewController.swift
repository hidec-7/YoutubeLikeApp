//
//  HomeViewController.swift
//  YoutubeLikeApp
//
//  Created by hideto c. on 2021/05/22.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController {
    
    // MARK: Propeties
    private var prevContentOffset: CGPoint = .init(x: 0, y: 0)
    private let headerMoveHeight: CGFloat = 5
    
    private let cellId = "cellId"
    private let atentionCellId = "atentionCellId"
    private var videoItems = [Item]()
    var selectedItem: Item?

    // MARK: IBOutlets
    @IBOutlet private weak var videoListCollectionView: UICollectionView!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomVideoImageView: UIImageView!
    @IBOutlet private weak var bottomVideoView: UIView!
    @IBOutlet private weak var searchButton: UIButton!
    
    // bottomImageViewの制約
    @IBOutlet private weak var bottomVideoViewTrailing: NSLayoutConstraint!
    @IBOutlet private weak var bottomVideoViewLeading: NSLayoutConstraint!
    @IBOutlet private weak var bottomVideoViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var bottomVideoViewBottom: NSLayoutConstraint!
    @IBOutlet private weak var bottomVideoImageWidth: NSLayoutConstraint!
    @IBOutlet private weak var bottomVideoImageHeight: NSLayoutConstraint!
    @IBOutlet private weak var bottomSubscribeView: UIView!
    @IBOutlet private weak var bottomCloseButton: UIButton!
    @IBOutlet private weak var bottomVideoTitleLabel: UILabel!
    @IBOutlet private weak var bottomVideoDescribeLabel: UILabel!
    
    // MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupViews()
        fetchYoutubeSerachInfo()
        setupGestureRecognizer()
        setupNotification()
    }
    
    // MARK: Methods
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(showThumbnailImage), name: .init("thumbnailImage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSearchedItem), name: .init("searchedItem"), object: nil)
    }
    
    @objc private func showThumbnailImage(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: Any],
              let image = userInfo["image"] as? UIImage,
              let videoImageMinY = userInfo["videoImageMinY"] as? CGFloat else { return }
        let diffBottomConstant = videoImageMinY - self.bottomVideoView.frame.minY
        
        bottomVideoViewBottom.constant -= diffBottomConstant
        bottomSubscribeView.isHidden = false
        bottomVideoView.isHidden = false
        bottomVideoImageView.image = image
        bottomVideoTitleLabel.text = self.selectedItem?.snippet.title
        bottomVideoDescribeLabel.text = self.selectedItem?.snippet.description
    }
    
    @objc private func showSearchedItem() {
        let videoViewController = UIStoryboard(name: "Video", bundle: nil).instantiateViewController(identifier: "VideoViewController") as VideoViewController
        
        videoViewController.selectedItem = self.selectedItem
        
        bottomVideoView.isHidden = true
        self.present(videoViewController, animated: true, completion: nil)
    }
    
    private func setupViews() {
        videoListCollectionView.delegate = self
        videoListCollectionView.dataSource = self
        
        videoListCollectionView.register(AttentionCell.self, forCellWithReuseIdentifier: atentionCellId)
        videoListCollectionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
        profileImageView.layer.cornerRadius = 20
        
        view.bringSubviewToFront(bottomVideoView)
        bottomVideoView.isHidden = true
        
        bottomCloseButton.addTarget(self, action: #selector(tappedCottomCloseButton), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(tappedSearchButton), for: .touchUpInside)
    }
    
    @objc private func tappedCottomCloseButton() {
        UIView.animate(withDuration: 0.2) {
            self.bottomVideoViewBottom.constant = -150
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.bottomVideoView.isHidden = true
            self.selectedItem = nil
        }
    }
    
    @objc private func tappedSearchButton() {
        let searchController = SearchViewController()
        let nav = UINavigationController(rootViewController: searchController)
        self.present(nav, animated: true, completion: nil)
    }
}

// MARK: API通信
extension HomeViewController {
     
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

// MARK: - ScrollViewのDelegateメソッド
extension HomeViewController {
    
    // scrollViewがscrollした時に呼ばれるメソッド
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerAnimation(scrollView: scrollView)
    }
    
    private func headerAnimation(scrollView: UIScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.prevContentOffset = scrollView.contentOffset
        }
        guard let presentIndexPath = videoListCollectionView.indexPathForItem(at: scrollView.contentOffset) else { return }
        if scrollView.contentOffset.y < 0 { return }
        if presentIndexPath.row >= videoItems.count - 2 { return }
        
        let alphaRatio = 1 / headerHeightConstraint.constant
        
        if self.prevContentOffset.y < scrollView.contentOffset.y {
            if headerTopConstraint.constant <= -headerHeightConstraint.constant { return }
            headerTopConstraint.constant -= headerMoveHeight
            headerView.alpha -= alphaRatio * headerMoveHeight
        } else if self.prevContentOffset.y > scrollView.contentOffset.y {
            if headerTopConstraint.constant >= 0 { return }
            headerTopConstraint.constant += headerMoveHeight
            headerView.alpha += alphaRatio * headerMoveHeight
        }
    }
    
    // scrollViewのscrollがピタッと止まった時に呼ばれる
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            headerViewEndAnimation()
        }
    }
    
    // scrollViewが止まった時に呼ばれる
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        headerViewEndAnimation()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoViewController = UIStoryboard(name: "Video", bundle: nil).instantiateViewController(identifier: "VideoViewController") as VideoViewController
        
        if videoItems.count == 0 {
            videoViewController.selectedItem = nil
            self.selectedItem = nil
        } else {
            let item = indexPath.row > 2 ? videoItems[indexPath.row - 1] : videoItems[indexPath.row]
            videoViewController.selectedItem = item
            self.selectedItem = item
        }
        
        bottomVideoView.isHidden = true
        self.present(videoViewController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        
        if indexPath.row == 2 {
            return .init(width: width, height: 200)
        } else {
            return .init(width: width, height: width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoItems.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 2 {
            let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: atentionCellId, for: indexPath) as! AttentionCell
            cell.videoItems = self.videoItems
            
            return cell
        } else {
            let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! VideoListCell
            
            if self.videoItems.count == 0 { return cell }
            
            if indexPath.row > 2 {
                cell.videoItem = videoItems[indexPath.row - 1]
            } else {
                cell.videoItem = videoItems[indexPath.row]
            }
            
            return cell
        }
    }
}

// MARK: Animation関連
extension HomeViewController {
    
    private func setupGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panBottomVideoView))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBottomVideoView))
        bottomVideoView.addGestureRecognizer(panGesture)
        bottomVideoView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func panBottomVideoView(sender: UIPanGestureRecognizer) {
        let move = sender.translation(in: view)
        
        guard let imageView = sender.view else { return }
        
        if sender.state == .changed {
            imageView.transform = CGAffineTransform(translationX: 0, y: move.y)
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
                imageView.transform = .identity
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func tapBottomVideoView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
            self.bottomSubscribeView.isHidden = true
            self.bottomVideViewExpandAnimation()
        } completion: { _ in
            let videoViewController = UIStoryboard(name: "Video", bundle: nil).instantiateViewController(identifier: "VideoViewController") as VideoViewController
            videoViewController.selectedItem = self.selectedItem
            
            self.present(videoViewController, animated: false) {
                self.bottomVideoViewbackToIdentity()
            }
        }
    }
    
    private func bottomVideViewExpandAnimation() {
        let topSafeArea = self.view.safeAreaInsets.top
        let bottomSafeArea = self.view.safeAreaInsets.bottom
        
        // bottomVideoView
        bottomVideoViewLeading.constant = 0
        bottomVideoViewTrailing.constant = 0
        bottomVideoViewBottom.constant = -bottomSafeArea
        bottomVideoViewHeight.constant = view.frame.height - topSafeArea
        
        // bottomVideoImageView
        bottomVideoImageWidth.constant = view.frame.width
        bottomVideoImageHeight.constant = 280
        
        tabBarController?.tabBar.isHidden = true
        
        self.view.layoutIfNeeded()
    }
    
    private func bottomVideoViewbackToIdentity() {
        // bottomVideoView
        bottomVideoViewLeading.constant = 12
        bottomVideoViewTrailing.constant = 12
        bottomVideoViewBottom.constant = 20
        bottomVideoViewHeight.constant = 70
        
        // bottomVideoImageView
        bottomVideoImageWidth.constant = 150
        bottomVideoImageHeight.constant = 70
        
        bottomVideoView.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    private func headerViewEndAnimation() {
        if headerTopConstraint.constant < -headerHeightConstraint.constant / 2 {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: []) {
                self.headerTopConstraint.constant = -self.headerHeightConstraint.constant
                self.headerView.alpha = 0
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: []) {
                self.headerTopConstraint.constant = 0
                self.headerView.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }
}
