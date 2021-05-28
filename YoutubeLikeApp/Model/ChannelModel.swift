//
//  ChannelModel.swift
//  YoutubeLikeApp
//
//  Created by hideto c. on 2021/05/22.
//

import Foundation

class ChannelModel: Decodable {
    
    let items: [ChannelItem]
}

class ChannelItem: Decodable {
    
    let snippet: ChannelSnippet
}

class ChannelSnippet: Decodable {
    
    let title: String
    let thumbnails: Thumbnail
}
