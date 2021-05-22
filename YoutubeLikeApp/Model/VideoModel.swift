//
//  VideoModel.swift
//  YoutubeLikeApp
//
//  Created by hideto c. on 2021/05/22.
//

import Foundation

class VideoModel: Decodable {
    
    let kind: String
    let items: [Item]
}

class Item: Decodable {
    
    var channel: ChannelModel?
    let snippet: Snippet
}

class Snippet: Decodable {
    
    let publishedAt: String
    let channelId: String
    let title: String
    let description: String
    let thumbnails: Thumbnail
}

class Thumbnail: Decodable {
    
    let medium: ThumbnailInfo
    let high: ThumbnailInfo
}

class ThumbnailInfo: Decodable {
    
    let url: String
    let width: Int?
    let height: Int?
}
