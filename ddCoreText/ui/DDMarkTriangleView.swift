//
//  DDMarkTriangleView.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/17.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit

enum DDTriangleDirection {
    case top
    case bottom
}

class DDMarkTriangleView: UIView {
    
    class func creatTriangleView(with direction: DDTriangleDirection) -> DDMarkTriangleView {
        let triangle = DDMarkTriangleView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        triangle.direction = direction
        triangle.backgroundColor = UIColor.clear
        return triangle
    }
    
    var direction: DDTriangleDirection = .bottom
    
    override func draw(_ rect: CGRect) {
        drawTriangle()
    }
    
    fileprivate func drawTriangle() {
        let path = UIBezierPath()
        UIColor.black.set()
        if direction == .bottom {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: frame.width, y: 0))
            path.addLine(to: CGPoint(x: frame.width * 0.5, y: frame.height * 0.5))
        } else {
            path.move(to: CGPoint(x: 0, y: frame.height))
            path.addLine(to: CGPoint(x: frame.width, y: frame.height))
            path.addLine(to: CGPoint(x: frame.width * 0.5, y: frame.height * 0.5))
        }
        path.close()
        path.fill()
    }
}
