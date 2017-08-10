//
//  DDMarkColorButton.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/16.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit

/// 圆球的状态
///
/// - normal: 正常状态
/// - select: 选中状态
enum MarkColorRoundState {
    case normal
    case selected
}

private let kRoundLineWidth: CGFloat = 5

class DDMarkColorButton: UIButton {
    
    var fillColor: UIColor!
    
    class func createMarkColorButtonBy(frame: CGRect,fillColor: UIColor) -> DDMarkColorButton {
        let markBtn = DDMarkColorButton(frame: frame)
        markBtn.fillColor = fillColor
        let radius = frame.width * 0.5
        let normalImage = DDMarkColorButton.roundBy(radius, fillColor: fillColor)
        let selectImage = DDMarkColorButton.roundBy(radius, fillColor: fillColor, state: .selected)
        markBtn.setImage(normalImage, for: .normal)
        markBtn.setImage(selectImage, for: .selected)
        return markBtn
    }
    
    fileprivate class func roundBy(_ radius: CGFloat, fillColor: UIColor, state: MarkColorRoundState = .normal) -> UIImage {
        let circleRadius = state == .normal ? radius : radius - kRoundLineWidth * 0.5
        let rect = CGRect(x: 0, y: 0, width: radius * 4, height: radius * 4)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: radius * 2, y: radius * 2) , radius: circleRadius * 2, startAngle: 0, endAngle: 180, clockwise: true)
        if state == .selected {
            path.lineWidth = kRoundLineWidth * 2
            UIColor.white.setStroke()
            path.stroke()
        }
        fillColor.setFill()
        path.fill()
        context?.addPath(path.cgPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

}
