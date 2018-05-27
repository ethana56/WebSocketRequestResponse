//
//  Message.swift
//  CaptureTheFlag
//
//  Created by Ethan Abrams on 5/12/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import Foundation
internal struct Message {
    let command: String?
    let key : String?
    let data: [String: Any]?
    let error : String?
    init(command: String?, key: String?, data: [String : Any]?, error: String?) {
        self.command = command
        self.key = key
        self.data = data
        self.error = error
    }
}

