//
//  DDCoreTextUtils.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/14.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit

class DDCoreTextUtils: NSObject {
    
    /// 获取某点击位置的偏移量如果没有这个点返回-1
    class func touchContentIndex(at point: CGPoint, ddLayouter: DDCoreTextLayouter) -> Int {
        var idx: Int = -1
        for line in ddLayouter.ddLines {
            if line.frame.contains(point) {
                idx = line.stringIndexBy(point)
                break
            }
        }
        return idx
    }
    
    /// 通过首尾下标区间获取首尾坐标及内容
    class func getSelectionBy(_ interval: (Int, Int), ddLayouter: DDCoreTextLayouter) -> DDCoreTextSelectionInfo {
        var selection = DDCoreTextSelectionInfo()
        selection.content = ddLayouter.content[interval.0..<interval.1]
        for line in ddLayouter.ddLines {
            if line.isContain(interval.0) {
                let offset = line.stringOffsetBy(interval.0)
                selection.startPosition = CGPoint(x: line.frame.origin.x + offset - 5, y: line.frame.origin.y - kCircleDiameter)
                selection.startLineHeight = line.lineHeight
            }
            
            if line.isContain(interval.1) {
                let offset = line.stringOffsetBy(interval.1)
                selection.endPosition = CGPoint(x: line.frame.origin.x + offset - 5, y: line.frame.origin.y - kCircleDiameter)
                selection.endLineHeight = line.lineHeight
                break
            }
        }
        return selection
    }
    
    /// 绘制选中/笔记部分
    class func drawSelection(_ interval: (Int, Int), ddLayouter: DDCoreTextLayouter, bgColor: UIColor = UIColor(hex: "#1c6bde").withAlphaComponent(0.1), height: CGFloat, isTransform: Bool, markTag: Int = 0) -> [DDCoreTextNoteLayer] {
        var shapeLayers = [DDCoreTextNoteLayer]()
        let selectionStartIndex = interval.0
        let selectionEndIndex = interval.1
        /// 记录是否开始计算lineRect
        var isBegin: Bool = false
        for line in ddLayouter.ddLines {
            var leftOffset: CGFloat = 0
            var rightOffset: CGFloat = 0
            /// 1.如果是第一行 更新首坐标
            if line.isRealContain(selectionStartIndex) {
                leftOffset = line.stringOffsetBy(selectionStartIndex)
                isBegin = true
            }
            /// 2.如果是最后一行 更新尾部坐标
            if line.isRealContain(selectionEndIndex) {
                rightOffset = line.frame.width - line.stringOffsetBy(selectionEndIndex)
            }
            
            if isBegin {
                let lineRect = CGRect(x: line.frame.origin.x + leftOffset, y: line.frame.origin.y, width:  line.frame.width - rightOffset - leftOffset, height: line.lineHeight)
                
                let shapeLayer = fillIn(lineRect, bgColor: bgColor, height: height, isTransform: isTransform)
                if let shapeLayer = shapeLayer {
                    shapeLayer.markTag = markTag
                    shapeLayers.append(shapeLayer)
                }
            }
            /// 如果最后一行计算完,跳出循环
            if line.isRealContain(selectionEndIndex) {
                break
            }
        }
        return shapeLayers
    }
    
    fileprivate class func fillIn(_ rect: CGRect, bgColor: UIColor, height: CGFloat, isTransform: Bool) -> DDCoreTextNoteLayer? {
        var transformRect = CGRect.zero
        if isTransform {
            var transform = CGAffineTransform(translationX: 0, y: height)
            transform = transform.scaledBy(x: 1, y: -1)
            transformRect = rect.applying(transform)
            bgColor.setFill()
            let path = UIBezierPath(rect: transformRect)
            path.fill()
            return nil
        } else {
            transformRect = rect
            let path = UIBezierPath(rect: transformRect)
            let shapeLayer = DDCoreTextNoteLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = bgColor.cgColor
            return shapeLayer
        }
    }
}
