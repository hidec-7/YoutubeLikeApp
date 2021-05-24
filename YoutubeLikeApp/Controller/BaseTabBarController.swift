//
//  BaseTabBarController.swift
//  YoutubeLikeApp
//
//  Created by hideto c. on 2021/05/24.
//

import UIKit

class BaseTabBarController: UITabBarController {
    
    enum ControllerName: Int {
        case home, search, plus, channel, library
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        viewControllers?.enumerated().forEach({ (index, viewController) in
            if let name = ControllerName.init(rawValue: index) {
                switch name {
                case .home:
                    setTabBarInfo(viewController, selectedImageName: "home", unSlectedImageName: "home-1", title: "ホーム")
                case .search:
                    setTabBarInfo(viewController, selectedImageName: "search-bar", unSlectedImageName: "search-bar-1", title: "検索")
                case .plus:
                    setTabBarInfo(viewController, selectedImageName: "plus", unSlectedImageName: "plus-1", title: "")
                case .channel:
                    setTabBarInfo(viewController, selectedImageName: "channel", unSlectedImageName: "channel-1", title: "登録チャンネル")
                case .library:
                    setTabBarInfo(viewController, selectedImageName: "library", unSlectedImageName: "library-1", title: "ライブラリ")
                }
            }
        })
    }
    
    private func setTabBarInfo(_ viewController: UIViewController, selectedImageName: String, unSlectedImageName: String, title: String) {
        viewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.resize(size: .init(width: 20, height: 20))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.image = UIImage(named: unSlectedImageName)?.resize(size: .init(width: 20, height: 20))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.title = title
    }
}
