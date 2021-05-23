//
//  BaseTabBarController.swift
//  YoutubeLikeApp
//
//  Created by hideto c. on 2021/05/24.
//

import UIKit

class BaseTabBarController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers?.enumerated().forEach({ (index, viewController) in
            switch index {
            case 0:
                setTabBarInfo(viewController, selectedImageName: "home", unSlectedImageName: "home-1", title: "ホーム")
            case 1:
                setTabBarInfo(viewController, selectedImageName: "search-bar", unSlectedImageName: "search-bar-1", title: "検索")
            case 2:
                setTabBarInfo(viewController, selectedImageName: "plus", unSlectedImageName: "plus-1", title: "")
            case 3:
                setTabBarInfo(viewController, selectedImageName: "channel", unSlectedImageName: "channel-1", title: "登録チャンネル")
            case 4:
                setTabBarInfo(viewController, selectedImageName: "library", unSlectedImageName: "library-1", title: "ライブラリ")
            default:
                break
            }
        })
    }
    
    private func setTabBarInfo(_ viewController: UIViewController, selectedImageName: String, unSlectedImageName: String, title: String) {
        viewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.resize(size: .init(width: 20, height: 20))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.image = UIImage(named: unSlectedImageName)?.resize(size: .init(width: 20, height: 20))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.title = title
    }
}
