//
//  DDCoreTextNoteView.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/14.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//  专门负责标记的笔记部分

import UIKit

struct DDMarkColor {
    static let orange = UIColor(hex: "#de4603")
    static let green = UIColor(hex: "#20de34")
    static let blue = UIColor(hex: "#1c6bde")
    static let purple = UIColor(hex: "#ab1dde")
}

class DDCoreTextNoteView: UIView {
    
    var coreTextLayouter: DDCoreTextLayouter? {
        didSet {
            setupNotes()
        }
    }
    var shapeLayers = [DDCoreTextNoteLayer]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupNotes() {
        if let marks = coreTextLayouter?.marks {
            for mark in marks {
                shapeLayers.append(contentsOf: DDCoreTextUtils.drawSelection((mark.start ,mark.end), ddLayouter: coreTextLayouter!, bgColor: colorBy(mark.type) ,height: self.bounds.height, isTransform: false, markTag: mark.id))
                if shapeLayers.count > 0 {
                    for shapeLayer in shapeLayers {
                        layer.addSublayer(shapeLayer)
                    }
                }
            }
        }
    }
    
    /// 添加笔记
    func addNoteBy(start: Int, end: Int, color: UIColor, markTag: Int) {
        let layers = DDCoreTextUtils.drawSelection((start, end), ddLayouter: coreTextLayouter!,bgColor: color, height: self.bounds.height, isTransform: false, markTag: markTag)
        shapeLayers.append(contentsOf: layers)
        if layers.count > 0 {
            for shapeLayer in layers {
                layer.addSublayer(shapeLayer)
            }
        }
    }
    
    /// 变换颜色
    func changeColorBy(_ markTag: Int, color: UIColor) {
        for shapeLayer in shapeLayers {
            if shapeLayer.markTag == markTag {
                shapeLayer.fillColor = color.cgColor
            }
        }
    }
    
    /// 通过id移除笔记
    func removeNoteBy(_ markTag: Int) {
        var layers = [DDCoreTextNoteLayer]()
        for shapeLayer in shapeLayers {
            if shapeLayer.markTag == markTag {
                shapeLayer.removeFromSuperlayer()
            } else {
                layers.append(shapeLayer)
            }
        }
        shapeLayers = layers
    }
    
    /// 根据模型配置颜色
    fileprivate func colorBy(_ type: String) -> UIColor {
        var color: UIColor?
        switch type {
        case "bg1":
            color = DDMarkColor.orange
        case "bg2":
            color = DDMarkColor.green
        case "bg3":
            color = DDMarkColor.blue
        case "bg4":
            color = DDMarkColor.purple
        default:
            color = DDMarkColor.green
        }
        return color!.withAlphaComponent(0.2)
    }
    
}
