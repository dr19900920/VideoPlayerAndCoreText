//
//  DDCoreTextLine.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/10.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit

class DDCoreTextLine: NSObject {
    
    var ctLine: CTLine?
    var ascent: CGFloat = 0
    var descent: CGFloat = 0
    var leading: CGFloat = 0
    var lineHeight: CGFloat = 0
    var frame: CGRect = .zero
    /// 每一段的偏移量
    var locationOffset: Int = 0
    /// 相对于整体的位置信息
    var location: Int = 0
    var length: Int = 0
    var content: String = ""
    
    // 将点击的位置转换成字符串的偏移量
    func stringIndexBy(_ position: CGPoint) -> Int {
        var adjustPosition = position
        adjustPosition.x -= frame.minX
        adjustPosition.y -= frame.minY
        let index = CTLineGetStringIndexForPosition(ctLine!, adjustPosition)
        return index + locationOffset
    }
    
    func stringOffsetBy(_ index: Int) -> CGFloat {
        return CTLineGetOffsetForStringIndex(ctLine!, index - locationOffset, nil)
    }
    
    /// 判断当前行上是否假包含这个点(左闭右闭区间)
    func isContain(_ index: Int) -> Bool {
        return index >= location && index <= location + length
    }
    
    /// 判断当前行上是否真包含这个点(左闭右开区间)
    func isRealContain(_ index: Int) -> Bool {
        return index >= location && index < location + length
    }
    
}
