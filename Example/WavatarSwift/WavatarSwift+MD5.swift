//
//  WavatarSwift+MD5.swift
//  WavatarSwift_Example
//
//  Created by anton.serebryakov on 30/09/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import WavatarSwift
import SwiftHash

extension WavatarSwift: WavatarSwiftMD5 {
    
    public class func md5(_ string: String) -> String {
        return MD5(string)
    }
    
}
