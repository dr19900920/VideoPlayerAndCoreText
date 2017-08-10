//
//  DDCoreTextScrollView.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/10.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit

let kDDCoreTextMargin: CGFloat = 12.0

class DDCoreTextScrollView: UIScrollView {

    private var coreTextView: DDCoreTextView?
    var coreTextLayouter: DDCoreTextLayouter? {
        didSet {
            setupUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupUI() {
        coreTextView = DDCoreTextView(frame: CGRect(x: kDDCoreTextMargin, y: 0, width: frame.width -  2 * kDDCoreTextMargin, height: 0))
        coreTextView?.coreTextLayouter = coreTextLayouter
        coreTextView?.height = (coreTextLayouter?.ddHeight)!
        coreTextView?.backgroundColor = UIColor.white
        contentSize = CGSize(width: SizeStyle.screenWidth - 2 * kDDCoreTextMargin, height: (coreTextLayouter?.ddHeight)!
        )
        addSubview(coreTextView!)
    }
}
