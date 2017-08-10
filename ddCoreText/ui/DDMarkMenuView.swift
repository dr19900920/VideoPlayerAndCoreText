//
//  DDMarkMenuView.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/16.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit

private let kMarkBtnLeftMargin: CGFloat = 20.0
private let kMarkBtnMargin: CGFloat = (SizeStyle.screenWidth - 25 - kMarkBtnWidth - 2 * kMarkBtnLeftMargin) * 0.25
private let kMarkBtnWidth: CGFloat = 26.0
private let kMarkColors = [DDMarkColor.orange, DDMarkColor.green, DDMarkColor.blue, DDMarkColor.purple, UIColor.white]
private let kBtnsTitle = ["复制", "想法"]

protocol DDMarkMenuViewDelegate: NSObjectProtocol {
    
    func ddMarkMenuViewDraw(_ color: UIColor)
    
    func ddMarkMenuViewRemove()
    
    func ddMarkMenuViewAddNote()
}

class DDMarkMenuView: UIView {
    
    weak var delegate: DDMarkMenuViewDelegate?
    var selectedBtn: DDMarkColorButton!
    var selection: DDCoreTextSelectionInfo!
    var deleteBtn: DDMarkColorButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(with selectionInfo: DDCoreTextSelectionInfo?, isNote: Bool = false) {
        if let selectionInfo = selectionInfo {
            deleteBtn.isEnabled = isNote
            selection = selectionInfo
            superview?.bringSubview(toFront: self)
            let window = UIApplication.shared.windows.last
            let startPosition = superview?.convert(selectionInfo.startPosition, to: window)
            let endPosision = superview?.convert(selectionInfo.endPosition, to: window)
            /// 三角形的x坐标
            let x = (SizeStyle.screenWidth - 20) * 0.5 - kDDCoreTextMargin
            var y: CGFloat = 0
            /// 1.如果第一行上方有足够的空间
            if startPosition!.y - height - kCircleDiameter - SizeStyle.navBarH - 10 > 0 {
                y = selectionInfo.startPosition.y - height * 0.5 - 10
                
                topTriangleView.isHidden = true
                bottomTriangleView.isHidden = false
                bottomTriangleView.frame.origin = CGPoint(x: x, y: y + height * 0.5 - 1)
            }
                /// 2.如果最后一行下方有足够的空间
            else if SizeStyle.screenHeight - endPosision!.y - height - kCircleDiameter * 2 - selectionInfo.endLineHeight - SizeStyle.tabBarH - 10 > 0 {
                y = selectionInfo.endPosition.y + height * 0.5 + kCircleDiameter * 2 + selectionInfo.endLineHeight + 10
                
                bottomTriangleView.isHidden = true
                topTriangleView.isHidden = false
                topTriangleView.frame.origin = CGPoint(x: x, y: y - height * 0.5 - 19)
            }
                /// 3.都没有足够的空间
            else {
                y = (selectionInfo.endPosition.y + kCircleDiameter * 2 + selectionInfo.endLineHeight - selectionInfo.startPosition.y) * 0.5 + selectionInfo.startPosition.y - height * 0.5 - 10
                
                topTriangleView.isHidden = true
                bottomTriangleView.isHidden = false
                bottomTriangleView.frame.origin = CGPoint(x: x, y: y + height * 0.5 - 1)
            }
            center.y = y
            isHidden = false
        }
    }
    
    func hide() {
        isHidden = true
        topTriangleView.isHidden = true
        bottomTriangleView.isHidden = true
    }
    
    fileprivate func setupUI() {
        backgroundColor = UIColor.black
        isHidden = true
        maskRadius()
        setupBtns()
    }
    
    /// 切圆角
    fileprivate func maskRadius() {
        let maskPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    
    /// 初始化颜色标记颜色按钮 - 最后一个白色按钮暂时作为移除按钮
    fileprivate func setupBtns() {
        for i in 0..<kMarkColors.count {
            let btn = DDMarkColorButton.createMarkColorButtonBy(frame: CGRect(x: kMarkBtnMargin * CGFloat(i) + kMarkBtnLeftMargin, y: 25, width: kMarkBtnWidth, height: kMarkBtnWidth), fillColor: kMarkColors[i]!)
            btn.tag = 10000 + i
            btn.addTarget(self, action: #selector(fillText(sender:)), for: .touchUpInside)
            if i == 0 {
                btn.isSelected = true
                selectedBtn = btn
            }
            if i == kMarkColors.count - 1 {
                deleteBtn = btn
            }
            addSubview(btn)
        }
        
        for i in 0..<kBtnsTitle.count {
            let btn = UIButton(frame: CGRect(x: kMarkBtnLeftMargin + CGFloat(i) * 80, y: 25 * 2 + kMarkBtnWidth, width: 60, height: 30))
            btn.setTitle(kBtnsTitle[i], for: .normal)
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.borderColor = UIColor.white
            btn.borderWidth = 1
            btn.clipsToBounds = true
            btn.addTarget(self, action: #selector(clickBtns(sender:)), for: .touchUpInside)
            btn.tag = 10000 + kMarkColors.count + i
            addSubview(btn)
        }
    }
    
    @objc fileprivate func fillText(sender: DDMarkColorButton) {
        if sender.tag == 10000 + kMarkColors.count - 1 {
            if let delegate = delegate {
                delegate.ddMarkMenuViewRemove()
            }
        } else {
            (sender.isSelected, selectedBtn!.isSelected) = (selectedBtn!.isSelected, sender.isSelected)
            selectedBtn = sender
            if let delegate = delegate {
                delegate.ddMarkMenuViewDraw(selectedBtn!.fillColor)
            }
        }
    }
    
    @objc fileprivate func clickBtns(sender: DDMarkColorButton) {
        /// TO DO: 想法逻辑
        if sender.tag == 10000 + kMarkColors.count {
            let pab = UIPasteboard.general
            pab.string = selection.content
            hide()
        } else {
            if let delegate = delegate {
                delegate.ddMarkMenuViewAddNote()
            }
        }
    }
    
    /// 顶部三角
    fileprivate lazy var topTriangleView: DDMarkTriangleView = {
        let top = DDMarkTriangleView.creatTriangleView(with: .top)
        top.isHidden = true
        self.superview!.addSubview(top)
        return top
    }()
    
    /// 底部三角
    fileprivate lazy var bottomTriangleView: DDMarkTriangleView = {
        let bottom = DDMarkTriangleView.creatTriangleView(with: .bottom)
        bottom.isHidden = true
        self.superview!.addSubview(bottom)
        return bottom
    }()
}
