//
//  Emoji.swift
//  ReviewAnalyzer
//
//  Created by nabilla on 14/01/24.
//

import Foundation

enum Emoji: String {
    case positive
    case negative
    case neutral
    
    var image: String {
        switch self {
        case .positive:
            return "like"
        case .negative:
            return "dislike"
        default:
            return "neutral"
        }
    }
}
