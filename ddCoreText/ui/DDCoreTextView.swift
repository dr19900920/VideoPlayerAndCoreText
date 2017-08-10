//
//  DDAttributedTextContentView.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/9.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit

/// 完成操作通知
let kNotificationDDAddNote = "kNotificationDDAddNote"
/// 移除操作的通知
let kNotificationDDRemoveNote = "kNotificationDDRemoveNote"

enum DDCoreTextViewState {
    /// 普通状态
    case normal
    /// 正在按下,需要弹出放大镜
    case touching
    /// 选中了一些文本,需要弹出标记菜单
    case selecting
}

/// 标记当前拖动的Anchor
private var kAnchorTargetTag = 1

private var kAnchorHeight: CGFloat = 45

class DDCoreTextView: UIView {
    
    var coreTextLayouter: DDCoreTextLayouter?
    /// 交互状态
    var state: DDCoreTextViewState = .normal {
        didSet {
            switch state {
            case .normal:
                /// 恢复正常状态
                markTag = -1
                selectionStartIndex = -1
                selectionEndIndex = -1
                removeSelectionAnchors()
                removeMagnifierView()
                menuView.hide()
            case .touching:
                setupSelectionAnchorsBy(kAnchorHeight)
            case .selecting:
                setupSelectionAnchorsBy(kAnchorHeight)
                if leftSelectionAnchor!.tag != kAnchorTargetTag && rightSelectionAnchor!.tag != kAnchorTargetTag {
                    removeMagnifierView()
                    menuView.hide()
                }
            }
            setNeedsDisplay()
        }
    }
    /// 选中框的开始/结束下标
    var selectionStartIndex: Int = -1
    var selectionEndIndex: Int = -1
    /// 当前选中的下标
    var selectionCurrentIndex: Int = 0
    /// 选中左标记图案
    var leftSelectionAnchor: DDAnchorImageView?
    /// 选中右标记图案
    var rightSelectionAnchor: DDAnchorImageView?
    /// 放大镜
    var magnifierView: DDMagnifierView?
    /// 选中内容的信息
    var selectionInfo: DDCoreTextSelectionInfo?
    /// 点击的是不是笔记部分
    var isNote: Bool = false
    /// 笔记的标记
    var markTag: Int = -1
    /// 笔记在数组中的下标
    var markIndex: Int = -1
    
    override var height: CGFloat {
        didSet {
            noteView.frame = bounds
            noteView.coreTextLayouter = coreTextLayouter
        }
    }
    
    override class var layerClass: Swift.AnyClass {
        return CATiledLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
        setupEvent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        /// 坐标系翻转
        context?.textMatrix = .identity
        context?.translateBy(x: 0, y: self.bounds.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        for ddFrame in (coreTextLayouter?.ddFrames)! {
            CTFrameDraw(ddFrame.ctFrame!, context!)
        }
        
        /// 绘制图片
        for ddImage in (coreTextLayouter?.ddImages)! {
            let image = UIImage(named: ddImage.imageName)
            if let img = image {
                context?.draw(img.cgImage!, in: ddImage.imagePosition)
            }
        }
        
        if state == .touching || state == .selecting {
            drawSelection()
            drawSelectionAnchors()
        }
    }
    
    fileprivate func setupLayer() {
        if layer.isKind(of: CATiledLayer.self) {
            (layer as! CATiledLayer).tileSize = CGSize(width: SizeStyle.screenWidth, height: SizeStyle.screenHeight)
        }
    }
    
    /// 添加手势
    fileprivate func setupEvent() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(userTapGestureDetected(recognizer:)))
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(userLongPressedGuestureDetected(recognizer:)))
        longPressRecognizer.delegate = self
        addGestureRecognizer(longPressRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(userPanGuestureDetected(recognizer:)))
        panRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)
    }
    
    /// 点击的手势
    @objc
    fileprivate func userTapGestureDetected(recognizer: UIGestureRecognizer) {
        let point = recognizer.location(in: self)
        if state == .normal {
            /// 图片点击
            for imageData in (coreTextLayouter?.ddImages)! {
                if imageData.frame.contains(point) {
                    print("点击了图片")
                    cv.images = [imageData.imageName]
                    cv.show(animation: true)
                    return
                }
            }
            
            /// 笔记点击
            let index = DDCoreTextUtils.touchContentIndex(at: point, ddLayouter: coreTextLayouter!)
            if let marks = coreTextLayouter?.marks {
                isNote = false
                for i in 0..<marks.count {
                    let mark = marks[i]
                    if index <= mark.end && index >= mark.start {
                        selectionInfo = DDCoreTextUtils.getSelectionBy((mark.start, mark.end), ddLayouter: coreTextLayouter!)
                        isNote = true
                        markTag = mark.id
                        markIndex = i
                        break
                    }
                }
                if isNote {
                    menuView.show(with: selectionInfo, isNote: true)
                } else {
                    markTag = -1 
                    menuView.hide()
                }
            }
        } else {
            state = .normal
        }
    }
    
    /// 长按手势
    @objc
    fileprivate func userLongPressedGuestureDetected(recognizer: UIGestureRecognizer) {
        let point = recognizer.location(in: self)
        switch recognizer.state {
        case .began, .changed:
            let index = DDCoreTextUtils.touchContentIndex(at: point, ddLayouter: coreTextLayouter!)
            if index != -1 && index < coreTextLayouter!.maxLength {
                /// 处理首尾区间的逻辑
                if selectionStartIndex == -1 && selectionEndIndex == -1 {
                    selectionStartIndex = index
                    selectionEndIndex = index + 1
                    selectionCurrentIndex = index
                }
                
                if index < selectionCurrentIndex {
                    selectionStartIndex = index
                    selectionEndIndex = selectionCurrentIndex
                }
                
                if index > selectionCurrentIndex {
                    selectionStartIndex = selectionCurrentIndex
                    selectionEndIndex = index
                }
            }
            state = .touching
            showMagnifierViewBy(point)
        default:
            if selectionStartIndex >= 0 && selectionEndIndex <= coreTextLayouter!.maxLength {
                state = .selecting
                menuView.show(with: selectionInfo)
            } else {
                state = .normal
            }
            break
        }
        
    }
    
    /// 拖拽手势
    @objc
    fileprivate func userPanGuestureDetected(recognizer: UIGestureRecognizer) {
        let point = recognizer.location(in: self)
        switch recognizer.state {
        case .began:
            /// 判断拖动的是左图案还是右图案
            if let leftSelectAnchor = leftSelectionAnchor, leftSelectAnchor.frame.insetBy(dx: -25, dy: -6).contains(point) {
                leftSelectionAnchor?.tag = kAnchorTargetTag
                menuView.hide()
            }
            if let rightSelectAnchor = rightSelectionAnchor, rightSelectAnchor.frame.insetBy(dx: -25, dy: -6).contains(point) {
                rightSelectionAnchor?.tag = kAnchorTargetTag
                menuView.hide()
            }
        case .changed:
            let index = DDCoreTextUtils.touchContentIndex(at: point, ddLayouter: coreTextLayouter!)
            if index == -1 {return}
            if leftSelectionAnchor?.tag == kAnchorTargetTag && index < selectionEndIndex {
                selectionStartIndex = index
                magnifierView?.touchPoint = point
                menuView.hide()
            } else if rightSelectionAnchor?.tag == kAnchorTargetTag && index > selectionStartIndex {
                selectionEndIndex = index
                magnifierView?.touchPoint = point
                menuView.hide()
            }
        default:
            leftSelectionAnchor?.tag = 0
            rightSelectionAnchor?.tag = 0
            removeMagnifierView()
            if selectionStartIndex >= 0 && selectionEndIndex <= coreTextLayouter!.maxLength {
                menuView.show(with: selectionInfo)
            }
        }
        setNeedsDisplay()
    }
    
    /// 初始化左右标记图案
    fileprivate func setupSelectionAnchorsBy(_ height: CGFloat) {
        if leftSelectionAnchor == nil && rightSelectionAnchor == nil {
            leftSelectionAnchor = DDAnchorImageView.createSelectionAnchor(with: .top, height: height)
            leftSelectionAnchor?.frame.origin = CGPoint(x: -100, y: -100)
            rightSelectionAnchor = DDAnchorImageView.createSelectionAnchor(with: .bottom, height: height)
            rightSelectionAnchor?.frame.origin = CGPoint(x: -100, y: -100)
            addSubview(leftSelectionAnchor!)
            addSubview(rightSelectionAnchor!)
        }
    }
    
    /// 绘制选中部分左右标记
    fileprivate func drawSelectionAnchors() {
        if selectionStartIndex < 0 || selectionEndIndex > coreTextLayouter!.maxLength {
            return
        }
        let selection = DDCoreTextUtils.getSelectionBy((selectionStartIndex, selectionEndIndex), ddLayouter: coreTextLayouter!)
        leftSelectionAnchor?.frame.origin = selection.startPosition
        leftSelectionAnchor?.height = selection.startLineHeight + kCircleDiameter * 2
        rightSelectionAnchor?.frame.origin = selection.endPosition
        rightSelectionAnchor?.height = selection.endLineHeight + kCircleDiameter * 2
        selectionInfo = selection
    }
    
    /// 绘制选中部分
    fileprivate func drawSelection(_ bgColor: UIColor = UIColor(hex: "#1c6bde").withAlphaComponent(0.1)) {
        _ = DDCoreTextUtils.drawSelection((selectionStartIndex ,selectionEndIndex), ddLayouter: coreTextLayouter!, height: self.bounds.height, isTransform: true)
    }
    
    /// 移除左右标记图案
    fileprivate func removeSelectionAnchors() {
        leftSelectionAnchor?.removeFromSuperview()
        leftSelectionAnchor = nil
        rightSelectionAnchor?.removeFromSuperview()
        rightSelectionAnchor = nil
    }
    
    /// 显示放大镜
    fileprivate func showMagnifierViewBy(_ touchPoint: CGPoint) {
        if magnifierView == nil {
            magnifierView = DDMagnifierView()
            magnifierView?.viewToMagnifier = self
            layer.addSublayer(magnifierView!.layer)
        }
        magnifierView?.touchPoint = touchPoint
    }
    
    /// 获取当前控制器
    fileprivate func getCurrentViewController() -> UIViewController {
        var vc = next
        while !vc!.isKind(of: UIViewController.self) {
            vc = vc?.next
        }
        return vc as! UIViewController
    }
    
    /// 移除放大镜
    fileprivate func removeMagnifierView() {
        magnifierView?.removeFromSuperview()
        magnifierView = nil
        self.layer.insertSublayer(noteView.layer, at: 0)
    }
    
    /// 笔记的视图
    fileprivate lazy var noteView: DDCoreTextNoteView = {
        let noteView = DDCoreTextNoteView()
        self.addSubview(noteView)
        return noteView
    }()
    
    /// 标记菜单
    fileprivate lazy var menuView: DDMarkMenuView = {
        let menuView = DDMarkMenuView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 126))
        menuView.delegate = self
        self.addSubview(menuView)
        return menuView
    }()
    
    fileprivate lazy var cv: YRPreviewImageCollectionView = YRPreviewImageCollectionView(placeholderImage: "nav")
    
    fileprivate lazy var noteListView: DDNoteListView = DDNoteListView()
}

// MARK: - UIGestureRecognizerDelegate
extension DDCoreTextView: UIGestureRecognizerDelegate {
    /// 避免和scrollView的手势冲突
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (otherGestureRecognizer.view?.isKind(of: UIScrollView.self))! && self.state == .normal {
            return true
        }
        return false
    }
}

// MARK: - DDMarkMenuViewDelegate
extension DDCoreTextView: DDMarkMenuViewDelegate {
    /// 渲染笔记的代理
    func ddMarkMenuViewDraw(_ color: UIColor) {
        if markTag > 0 {
            noteView.changeColorBy(markTag, color: color.withAlphaComponent(0.2))
        } else {
            let id = Int(arc4random() % 100)
            
            noteView.addNoteBy(start: selectionStartIndex, end: selectionEndIndex, color: color.withAlphaComponent(0.2), markTag: id)
            
            let mark = NEOMarkPartModel()
            mark.start = selectionStartIndex
            mark.end = selectionEndIndex
            mark.id = id
            
            state = .normal
            let sb = UIStoryboard.init(name: "ddAddNote", bundle: nil)
            let addNoteVC = sb.instantiateInitialViewController() as! DDAddNoteController
            addNoteVC.mark = mark
            let currentVC = getCurrentViewController()
            currentVC.present(addNoteVC, animated: true, completion: nil)
        }
    }
    
    /// 移除笔记的逻辑
    func ddMarkMenuViewRemove() {
        if markTag > 0 {
            noteView.removeNoteBy(markTag)
            state = .normal
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationDDRemoveNote), object: nil, userInfo: ["markIndex": markIndex])
        }
    }
    
    /// 查看想法
    func ddMarkMenuViewAddNote() {
        state = .normal
        let note = coreTextLayouter!.marks![markIndex].note
        if note == "" {
            debugLog("没有想法")
        } else {
            noteListView.notes = [note]
            noteListView.show()
        }
    }
}
