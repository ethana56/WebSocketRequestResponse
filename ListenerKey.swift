//
//  ListenerKey.swift
//  CaptureTheFlag
//
//  Created by Ethan Abrams on 5/17/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import Foundation
struct ListenerKey {
    let command: String
    let key: UUID
    init(command: String, key: UUID) {
        self.command = command
        self.key = key
    }
}
