//
//  DDMagnifierView.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/13.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//  放大镜

import UIKit

class DDMagnifierView: UIView {
    
    /// 放大镜所在的容器
    weak var viewToMagnifier: UIView?
    /// 手指的接触点
    var touchPoint: CGPoint = .zero {
        didSet {
            center = CGPoint(x: touchPoint.x, y: touchPoint.y - 70)
            contentLayer?.setNeedsDisplay()
        }
    }
    
    var contentLayer: CALayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 添加子layer防止到边缘时显示异常的问题
    fileprivate func setupUI() {
        frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        backgroundColor = UIColor.white
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = width * 0.5
        layer.masksToBounds = true
        
        contentLayer = CALayer()
        contentLayer?.frame = bounds
        contentLayer?.delegate = self
        contentLayer?.contentsScale = UIScreen.main.scale
        layer.addSublayer(contentLayer!)
    }
    
    /// addsublayer的时候回调用
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        ctx.translateBy(x: width * 0.5, y: height * 0.5)
        ctx.scaleBy(x: 1.5, y: 1.5)
        ctx.translateBy(x: -1 * touchPoint.x, y: -1 * touchPoint.y)
        viewToMagnifier?.layer.render(in: ctx)
    }
}
