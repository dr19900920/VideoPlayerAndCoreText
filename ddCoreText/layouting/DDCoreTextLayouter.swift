//
//  DDCoreTextLayouter.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/10.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit
import RealmSwift
/// 通过属性字符串用CTFramesetter构建(DDCoreTextFrame)CTFrame数组
class DDCoreTextLayouter: NSObject {

    var marks: List<NEOMarkPartModel>?
    var ddFrames = [DDCoreTextFrame]()
    var ddImages = [DDCoreTextImageData]()
    var ddHeight: CGFloat = 0
    var ddLines = [DDCoreTextLine]()
    /// 最大偏移量
    var maxLength: Int = 0
    /// 文稿内容
    var content: String = ""
    /// 每一段的坐标垂直偏移量
    fileprivate var paragraphOffset: CGFloat = 0
    
    /// 构建ddFrame数组
    func parse(_ ddAttrs: [DDAttributedString], width: CGFloat) {
        var tempFrames = [DDCoreTextFrame]()
        ddImages.removeAll()
        for ddAttr in ddAttrs {
            let attributedString = ddAttr.attributedString!
            let config = ddAttr.config ?? DDCoreTextParserConfig()
            content = content + attributedString.string
            let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
            let restrictSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
            let coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil)
            let textHeight = coreTextSize.height + config.paragraphSpaceBefore
            ddHeight = ddHeight + textHeight
            let coreTextFrame = DDCoreTextFrame()
            coreTextFrame.ctFramesetter = framesetter
            coreTextFrame.size = coreTextSize
            coreTextFrame.height = textHeight
            coreTextFrame.attributedString = attributedString
            tempFrames.append(coreTextFrame)
        }
        transform(frames: tempFrames)
    }
    
    /// 转换ctFrame的坐标系
    fileprivate func transform(frames: [DDCoreTextFrame]) {
        var tempHeight: CGFloat = 0
        for ddFrame in frames {
            tempHeight = tempHeight + ddFrame.height
            let ctFrame = creatCtFrame(with: ddFrame.ctFramesetter!, frame: CGRect(origin: CGPoint(x: 0, y: ddHeight - tempHeight), size: ddFrame.size))
            ddFrame.ctFrame = ctFrame
            buildLines(by: ddFrame)
            ddFrames.append(ddFrame)
        }
    }
    
    /// 通过ctframesetter构建ctframe
    fileprivate func creatCtFrame(with framesetter: CTFramesetter, frame: CGRect) -> CTFrame {
        let path = CGMutablePath()
        path.addRect(frame)
        let ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        return ctFrame
    }
    
    /// 通过每一段的偏移量计算每一行的位置
    fileprivate func buildLines(by ddFrame: DDCoreTextFrame) {
        let ctFrame = ddFrame.ctFrame!
        let lines = CTFrameGetLines(ctFrame) as Array
        var originsArray = [CGPoint](repeating: CGPoint.zero, count: lines.count)
        let range: CFRange = CFRangeMake(0, 0)
        CTFrameGetLineOrigins(ctFrame, range, &originsArray)
        var tempOffset: Int = 0
        for i in 0..<lines.count {
            let ddline = DDCoreTextLine()
            //遍历每一行CTLine
            let ctline = lines[i]
            let ctlinePoint = originsArray[i]
            var lineAscent: CGFloat = 0
            var lineDescent: CGFloat = 0
            var lineLeading: CGFloat = 0
            /// 记录每一段的下标偏移量
            let stringRange = CTLineGetStringRange(ctline as! CTLine)
            tempOffset = tempOffset + stringRange.length
            //该函数除了会设置好ascent,descent,leading之外，还会返回这行的宽度
            let lineWidth = CTLineGetTypographicBounds(ctline as! CTLine, &lineAscent, &lineDescent, &lineLeading)
            ddline.ctLine = ctline as! CTLine
            ddline.ascent = lineAscent
            ddline.descent = lineDescent
            ddline.leading = lineLeading
            ddline.lineHeight = lineAscent + lineDescent
            ddline.locationOffset = maxLength
            ddline.location = ddline.locationOffset + stringRange.location
            ddline.length = stringRange.length
            let str = ddFrame.attributedString!.string
            ddline.content = str[stringRange.location..<(stringRange.location + stringRange.length)]
            /// 转换坐标系
            var transform =  CGAffineTransform(translationX: 0, y: ddFrame.height)
            transform = transform.scaledBy(x: 1, y: -1)
            let flippedRect = CGRect(x: ctlinePoint.x, y: ctlinePoint.y - lineDescent, width: CGFloat(lineWidth), height: ddline.lineHeight)
            var lineRect = flippedRect.applying(transform)
            lineRect.origin.y = lineRect.origin.y + paragraphOffset
            ddline.frame = lineRect
            fillImagePosition(by: ctline as! CTLine, ctFrame: ctFrame, lineOrigin: ctlinePoint, lineRect: lineRect)
            ddLines.append(ddline)
        }
        /// 累加每一段的垂直坐标偏移量
        paragraphOffset = paragraphOffset + ddFrame.height
        /// 累加每一段的下标偏移量
        maxLength = maxLength + tempOffset
    }
    
    fileprivate func fillImagePosition(by ctLine: CTLine,ctFrame: CTFrame, lineOrigin: CGPoint, lineRect: CGRect) {
        let runs = CTLineGetGlyphRuns(ctLine) as Array
        for run in runs {
            let runAttr = CTRunGetAttributes(run as! CTRun) as! [String: Any]
            let delegate = runAttr[kCTRunDelegateAttributeName as String]
            guard delegate != nil else {
                continue
            }
            let imageData = DDCoreTextImageData()
            imageData.imageName = runAttr["imageName"] as! String
            var runBounds = CGRect.zero
            var runAscent: CGFloat = 0
            var runDescent: CGFloat = 0
            var runLeading: CGFloat = 0
            runBounds.size.width = CGFloat(CTRunGetTypographicBounds(run as! CTRun, CFRangeMake(0, 0), &runAscent, &runDescent, &runLeading))
            runBounds.size.height = runAscent + runDescent
            
            let xOffset = CTLineGetOffsetForStringIndex(ctLine, CTRunGetStringRange(run as! CTRun).location, nil)
            runBounds.origin.x = lineOrigin.x + xOffset;
            runBounds.origin.y = lineOrigin.y;
            runBounds.origin.y -= runDescent;
            
            let pathRef = CTFrameGetPath(ctFrame);
            let colRect = pathRef.boundingBox
            let delegateBounds = runBounds.offsetBy(dx: colRect.origin.x, dy: colRect.origin.y)
            imageData.imagePosition = delegateBounds
            imageData.frame = lineRect
            ddImages.append(imageData)
        }
    }
}
