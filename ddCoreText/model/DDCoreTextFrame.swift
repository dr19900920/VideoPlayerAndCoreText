//
//  DDCoreTextFrame.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/10.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit

class DDCoreTextFrame: NSObject {
    
    var ctFramesetter: CTFramesetter?
    var ctFrame: CTFrame?
    var size: CGSize = .zero
    var height: CGFloat = 0
    var attributedString: NSAttributedString?
    var config: DDCoreTextParserConfig?
}
