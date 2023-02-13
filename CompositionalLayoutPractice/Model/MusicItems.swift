//
//  MusicItems.swift
//  CompositionalLayoutPractice
//
//  Created by Ryo Mashima on 2023/02/16.
//

import Foundation
import UIKit

protocol MusicItem: Identifiable {
    var name: String { get }
    var description: String? { get }
    var symbolImage: UIImage? { get }
}

struct Album: MusicItem {
    let id: UUID = UUID()
    let name: String
    let artist: Artist
    let songs: [Song]
    let symbolImage: UIImage? = .init(systemName: "square.stack")
    var description: String? { artist.name }
}

struct Artist {
    let name: String
}

struct Playlist: MusicItem {
    let id: UUID = UUID()
    let name: String
    let description: String?
    let symbolImage: UIImage? = .init(systemName: "music.note.list")
}

struct Song: Identifiable {
    let id: UUID = UUID()
    let name: String
    let artist: Artist
}


