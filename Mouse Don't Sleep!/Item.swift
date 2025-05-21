//
//  Item.swift
//  Mouse Don't Sleep!
//
//  Created by Tk on 2025/5/21.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
