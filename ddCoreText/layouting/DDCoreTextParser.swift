//
//  DDCoreTextParser.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/10.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit
import RealmSwift

/// 通过后台返回的对象数组把对象数组解析成对应的属性字符串
class DDCoreTextParser: NSObject {
    
    /// 获取一组对象的属性字符串
    class func parseAttributedString(by document: List<NEODocumentPartModel>) -> [DDAttributedString]? {
        var result = [DDAttributedString]()
        var i = 0
        for part in document {
            var ddAttr: DDAttributedString?
            if part.type == "image" {
                ddAttr = parseAttributedImgageString(by: part)!
            } else {
                ddAttr = parseAttributedString(by: part)!
            }
            i += 1
            if i == 1 {
                ddAttr?.config!.paragraphSpaceBefore = 0
            }
            result.append(ddAttr!)
        }
        return result
    }
    
    /// 获取一个对象的属性字符串
    fileprivate class func parseAttributedString(by part: NEODocumentPartModel) -> DDAttributedString? {
        let ddAttr = DDAttributedString()
        let config = DDCoreTextParserConfig.config(by: part)
        let attributes = config.attrbutes()
        var content = part.context.replacingOccurrences(of: "&ldquo;", with: "\"")
        content = content.replacingOccurrences(of: "&rdquo;", with: "\"")
        ddAttr.config = config
        ddAttr.attributedString = NSAttributedString(string: content, attributes: attributes)
        return ddAttr
    }
    
    /// Allocates uninitialized memory for the specified number of instances of
    /// type `Pointee`.
    ///
    /// The resulting pointer references a region of memory that is bound to
    /// `Pointee` and is `count * MemoryLayout<Pointee>.stride` bytes in size.
    /// You must eventually deallocate the memory referenced by the returned
    /// pointer.
    ///
    /// The following example allocates enough new memory to store four `Int`
    /// instances and then initializes that memory with the elements of a range.
    ///
    ///     let intPointer = UnsafeMutablePointer<Int>.allocate(capacity: 4)
    ///     intPointer.initialize(from: 1...4)
    ///     print(intPointer.pointee)
    ///     // Prints "1"
    ///
    /// When you allocate memory, always remember to deallocate once you're
    /// finished.
    ///
    ///     intPointer.deallocate(capacity: 4)
    ///
    /// - Parameter count: The amount of memory to allocate, counted in instances
    ///   of `Pointee`.

    
    
    /// 获取一个带图片对象的属性字符串
    class func parseAttributedImgageString(by part: NEODocumentPartModel) -> DDAttributedString? {
        /// 为图片设置CTRunDelegate,delegate决定留给图片的空间大小
        let imageName = part.imageName
        let extentBuffer = UnsafeMutablePointer<NEODocumentPartModel>.allocate(capacity: 1)
        extentBuffer.initialize(to: part)
        var imageCallbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { (refCon) in
            print("RunDelegate dealloc")
        }, getAscent: { (refCon) -> CGFloat in
            let e = refCon.assumingMemoryBound(to: NEODocumentPartModel.self)
            let o = e.pointee
            let img = UIImage(named: o.imageName)
            e.deallocate(capacity: 1)
            return (img?.size.height)! / (img?.size.width)! * (UIScreen.main.bounds.size.width - 20)
        }, getDescent: { (refCon) -> CGFloat in
            return 0
        }) { (refCon) -> CGFloat in
            return UIScreen.main.bounds.size.width - 20
        }
        
        let runDelegate = CTRunDelegateCreate(&imageCallbacks, extentBuffer)
        
//        CTRunDelegateCreate(<#T##callbacks: UnsafePointer<CTRunDelegateCallbacks>##UnsafePointer<CTRunDelegateCallbacks>#>, UnsafeMutableRawPointer?)
        
        let imageAttributedString = NSMutableAttributedString(string: " ")
        imageAttributedString.addAttribute(kCTRunDelegateAttributeName as String, value: runDelegate!, range: NSMakeRange(0, 1))
        // 添加属性，在CTRun中可以识别出这个字符是图片
        imageAttributedString.addAttribute("imageName", value: imageName, range: NSMakeRange(0, 1))
        let ddAttr = DDAttributedString()
        ddAttr.attributedString = imageAttributedString
        return ddAttr
    }
}

