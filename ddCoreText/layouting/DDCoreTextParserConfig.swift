//
//  DDCoreTextParserConfig.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/10.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit

enum PartType: String {
    case h1
    case paragraph
    case img
}

class DDCoreTextParserConfig: NSObject {

    var fontSize: CGFloat = 0
    var lineSpace: CGFloat = 0
    var textColor: UIColor = UIColor.black
    /// 字体
    var fonts: String = "ArialMT"
    /// 对齐方式
    var alignment = CTTextAlignment.justified
    /// 首行缩进
    var firstline: CGFloat = 0
    /// 段头缩进
    var headindent: CGFloat = 0
    /// 段尾缩进
    var tailindent: CGFloat = 0
    /// 段前间距
    var paragraphSpaceBefore: CGFloat = 0
    /// 段尾间距
//    var paragraphSpace: CGFloat = -10.0
    /// 行高
    var lineHeight: CGFloat = 0
    /// 根据类型获取配置,再通过配置获取属性
    class func config(by part: NEODocumentPartModel) -> DDCoreTextParserConfig {
        let config = DDCoreTextParserConfig()
        switch part.type {
        case PartType.h1.rawValue:
            config.textColor = UIColor.red
            config.fontSize = 18
            config.paragraphSpaceBefore = 15
            config.lineSpace = 10
            config.lineHeight = 18
        case PartType.paragraph.rawValue:
            config.textColor = UIColor.black
            config.fontSize = 14
            config.paragraphSpaceBefore = 15
            config.lineSpace = 10
            config.lineHeight = 14
        default:break
        }
        return config
    }
    
    /// 根据配置获取属性
    func attrbutes() -> [String: Any]? {
        let fontRef = CTFontCreateWithName(fonts as CFString, fontSize, nil)
        let kNumberOfSettings = 9
        /// 设置行间距
        let settings = [
//            CTParagraphStyleSetting(spec: .paragraphSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &paragraphSpace),
//            CTParagraphStyleSetting(spec: .paragraphSpacingBefore, valueSize: MemoryLayout<CGFloat>.size, value: &paragraphSpaceBefore),
            CTParagraphStyleSetting(spec: .maximumLineHeight, valueSize: MemoryLayout<CGFloat>.size, value: &lineHeight),
            CTParagraphStyleSetting(spec: .minimumLineHeight, valueSize: MemoryLayout<CGFloat>.size, value: &lineHeight),
            CTParagraphStyleSetting(spec: .lineSpacingAdjustment, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpace),
            CTParagraphStyleSetting(spec: .maximumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpace),
            CTParagraphStyleSetting(spec: .minimumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpace),
            CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout<UInt8>.size, value: &alignment),
            CTParagraphStyleSetting(spec: .firstLineHeadIndent, valueSize: MemoryLayout<CGFloat>.size, value: &firstline),
            CTParagraphStyleSetting(spec: .headIndent, valueSize: MemoryLayout<CGFloat>.size, value: &headindent),
            CTParagraphStyleSetting(spec: .tailIndent, valueSize: MemoryLayout<CGFloat>.size, value: &tailindent),
            ]
        let theParagraphRef = CTParagraphStyleCreate(settings, kNumberOfSettings)
        var dict: [String: Any] = [:]
        dict[kCTForegroundColorAttributeName as String] = textColor.cgColor
        dict[kCTFontAttributeName as String] = fontRef
        dict[kCTParagraphStyleAttributeName as String] = theParagraphRef
        return dict
    }

}
