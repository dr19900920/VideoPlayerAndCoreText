//
//  DDAchorImageView.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/14.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit
/// 图片的圆球直径
private let kImageCircleDiameter: CGFloat = 22.0
/// 实际的圆球直径
let kCircleDiameter: CGFloat = kImageCircleDiameter * 0.5
private let kAnchorWidth: CGFloat = 8.0

enum DDAnchorDirection {
    case top
    case bottom
}

class DDAnchorImageView: UIImageView {

    var fontHeight: CGFloat = 0
    fileprivate var direction: DDAnchorDirection?
    
    class func createSelectionAnchor(with direction: DDAnchorDirection, height: CGFloat) -> DDAnchorImageView {
        let image = cursorBy(direction, height: height)
        let imageView = DDAnchorImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: kImageCircleDiameter * 0.5, height: height)
        imageView.direction = direction
        imageView.fontHeight = height
        return imageView
    }
    
    /// 绘制选中状态的左右标记图案
    fileprivate class func cursorBy(_ direction: DDAnchorDirection, height: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: kImageCircleDiameter, height: height * 2)
        let color = UIColor(hex: "#1c6bca")!
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        if direction == .top {
            context?.addEllipse(in: CGRect(x: 0, y: 0, width: kImageCircleDiameter, height: kImageCircleDiameter))
        } else {
            context?.addEllipse(in: CGRect(x: 0, y: height * 2 - kImageCircleDiameter, width: kImageCircleDiameter, height: kImageCircleDiameter))
        }
        context?.setFillColor(color.cgColor)
        context?.fillPath()
        /// draw line
        color.set()
        context?.setLineWidth(kAnchorWidth)
        context?.move(to: CGPoint(x: kImageCircleDiameter * 0.5, y:  kImageCircleDiameter))
        context?.addLine(to: CGPoint(x: kImageCircleDiameter * 0.5 ,y: height * 2 - kImageCircleDiameter))
        context?.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

}
