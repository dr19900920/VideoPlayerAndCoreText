//
//  DDAudioPlayerView.swift
//  EnglishCommunity-swift
//
//  Created by dengrui on 17/2/28.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

class DDAudioPlayerView: UIView {
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timeSlider: DDTimeSlider!
    @IBOutlet weak var accelerateBtn: UIButton!
    @IBOutlet weak var decelerateBtn: UIButton!
    @IBOutlet weak var speedsLabel: UILabel!
    
    class func instanceView() -> DDAudioPlayerView {
        return Bundle.main.loadNibNamed("DDAudioPlayerView", owner: nil, options: nil)?.last as! DDAudioPlayerView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.tintColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6 )
        progressView.trackTintColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3 )
        
        timeSlider.maximumValue = 1.0
        timeSlider.minimumValue = 0.0
        timeSlider.value        = 0.0
        timeSlider.setThumbImage(UIImage(named: "ddaudioplayer_slider_thumb"), for: UIControlState())
        
        timeSlider.maximumTrackTintColor = UIColor.clear
        timeSlider.minimumTrackTintColor = UIColor.white
    }
    
}

/// 时间滑条
open class DDTimeSlider: UISlider {
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let trackHeigt:CGFloat = 2
        let position = CGPoint(x: 0 , y: 14)
        let customBounds = CGRect(origin: position, size: CGSize(width: bounds.size.width, height: trackHeigt))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    override open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let rect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        let newx = rect.origin.x - 10
        let newRect = CGRect(x: newx, y: 0, width: 30, height: 30)
        return newRect
    }
}
