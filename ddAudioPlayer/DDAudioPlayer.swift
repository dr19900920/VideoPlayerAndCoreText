//
//  DDAudioPlayer.swift
//  EnglishCommunity-swift
//
//  Created by dengrui on 17/2/28.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit
import IJKMediaFramework

/// 播放器状态
enum DDAudioPlayerState {
    case unknown         // 未知
    case playable        // 可以播放
    case playthroughOK   // 从头到尾播放OK
    case stalled         // 熄火
    case playbackEnded   // 播放正常结束
    case playbackError   // 播放错误
    case userExited      // 用户退出
    case stopped         // 停止
    case paused          // 暂停
    case playing         // 正在播放
    case interrupted     // 中断
    case seekingForward  // 快退
    case seekingBackward // 快进
    case notSetURL       // 未设置URL
    case buffering       // 缓冲中
    case bufferFinished  // 缓冲完毕
}

protocol DDAudioPlayerDelegate: NSObjectProtocol {
    
    func player(_ player: DDAudioPlayer, playerStateChanged state: DDAudioPlayerState)
}

class DDAudioPlayer: UIView {

    /// 更新时间和缓冲进度的定时器
    var timer: Timer!
    /// 当前播放的音频的URL
    var currentPlayURL: URL!
    /// 播放器
    fileprivate var player: IJKMediaPlayback!
    /// 播放器控制视图
    fileprivate var controlView: DDAudioPlayerView!

    fileprivate var isSliderSliding = false // 是否正在滑动滑条
    
    /// 当前播放速度的下标
    fileprivate var currentPlayIndex = 1
    /// 支持的播放速度
    fileprivate var speeds: [Float] = [0.5, 1.0, 1.5, 2.0]
    
    weak var delegate: DDAudioPlayerDelegate?
    
    /// 初始化UI
    fileprivate func setupUI() {
        
        controlView = DDAudioPlayerView.instanceView()
        addSubview(controlView)
        controlView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        controlView.playBtn.addTarget(self, action: #selector(playButtonPressed(_:)), for: .touchUpInside)
        
        /// 时间滑条
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: .touchDown)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        controlView.timeSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [.touchUpInside,.touchCancel, .touchUpOutside])
        
        /// 加减速
        controlView.accelerateBtn.addTarget(self, action: #selector(accelerateBtnTapped(_:)), for: .touchDown)
        controlView.decelerateBtn.addTarget(self, action: #selector(decelerateBtnTapped(_:)), for: .touchDown)
        
        // 更新播放时间的定时器
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(updatePlayTime), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    /**
     直接使用URL播放
     
     - parameter url:   音频URL
     */
    func playWithURL(_ url: URL) {
        
        // 保存当前播放的URL
        currentPlayURL = url
        setupUI()
        player = IJKAVMoviePlayerController(contentURL: url)
        // 没有自动播放就播放
        player.prepareToPlay()
        setupNotificationObservers()
        controlView.playBtn.isSelected = true
        player.shouldAutoplay = true
    }
    
    /**
     手动播放
     */
    func play() {
        if let player = player {
            if !player.isPlaying() {
                player.play()
                controlView.playBtn.isSelected = true
            }
        }
    }
    
    /**
     手动暂停
     */
    func pause() {
        if let player = player {
            if player.isPlaying() {
                player.pause()
                controlView.playBtn.isSelected = false
            }
        }
    }
    
    /**
     准备销毁，移除各种资源
     */
    func prepareToDeinit() {
        if let player = player {
            player.shutdown()
            controlView.removeFromSuperview()
            timer.invalidate()
            removeMovieNotificationObservers()
        }
        
    }
}

// MARK: - 内部事件-私有方法
extension DDAudioPlayer {
    
    /**
     创建定时器
     */
    fileprivate func startTimer() {
        timer.fireDate = Date.distantPast
    }
    
    /**
     销毁定时器
     */
    fileprivate func pauseTimer() {
        timer.fireDate = Date.distantFuture
    }
    
    /**
     更新播放时间label
     */
    @objc
    fileprivate func updatePlayTime() {
        if isSliderSliding {
            return
        }
        
        controlView.currentTimeLabel.text = "\(formatSecondsToString(player.currentPlaybackTime))"
        controlView.totalTimeLabel.text = "\(formatSecondsToString(player.duration))"
        controlView.timeSlider.value = Float(player.currentPlaybackTime) / Float(player.duration)
        
        // 更新缓冲进度
        if player.duration > 0 && Float(player.playableDuration) / Float(player.duration) > 0.9 {
            controlView.progressView.setProgress(1.0, animated: true)
        } else if player.duration > 0 {
            controlView.progressView.setProgress(Float(player.playableDuration) / Float(player.duration), animated: true)
        }
    }
    
    /**
     进度条开始滑动 手按下
     */
    @objc
    fileprivate func progressSliderTouchBegan(_ sender: UISlider)  {
        isSliderSliding = true
    }
    
    /**
     进度条值改变 滑动中。。。
     */
    @objc
    fileprivate func progressSliderValueChanged(_ sender: UISlider)  {
        controlView.currentTimeLabel?.text = formatSecondsToString(player.duration * Double(sender.value))
    }
    
    /**
     进度条滑动结束 手松开
     */
    @objc
    fileprivate func progressSliderTouchEnded(_ sender: UISlider)  {
        
        isSliderSliding = false
        seekToTime(Int(player.duration * Double(sender.value)))
        play()
    }
    
    /**
     点击加速
     */
    @objc
    fileprivate func accelerateBtnTapped(_ button: UIButton) {
        if currentPlayIndex >= speeds.count - 1 {
            return
        }
        currentPlayIndex += 1
        // 设置播放速度和按钮文字
        player.playbackRate = speeds[currentPlayIndex]
        controlView.speedsLabel.text = "\(speeds[currentPlayIndex])X"
    }
    
    /**
     点击减速
     */
    @objc
    fileprivate func decelerateBtnTapped(_ button: UIButton) {
        if currentPlayIndex <= 0 {
            return
        }
        currentPlayIndex -= 1
        // 设置播放速度和按钮文字
        player.playbackRate = speeds[currentPlayIndex]
        controlView.speedsLabel.text = "\(speeds[currentPlayIndex])X"
    }
    
    /**
     点击播放/暂停按钮
     */
    @objc
    fileprivate func playButtonPressed(_ button: UIButton) {
        if button.isSelected {
            pause()
        } else {
            play()
        }
    }
    
    /**
     将秒转成时间格式
     
     - parameter secounds: 秒数
     
     - returns: 时间格式字符串
     */
    fileprivate func formatSecondsToString(_ secounds: TimeInterval) -> String {
        let Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    /**
     调整播放时间
     
     - parameter second: 需要调整到的秒
     */
    fileprivate func seekToTime(_ second: Int) {
        player.currentPlaybackTime = TimeInterval(second)
    }
}

// MARK: - IJK内置通知
extension DDAudioPlayer {
    
    /**
     注册通知
     */
    fileprivate func setupNotificationObservers() {
        
        // 播放器加载状态改变
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange(_:)), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player)
        
        // 播放器完成播放
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackDidFinish(_:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPreparedToPlayDidChange(_:)), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        
        // 播放器状态改变
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackStateDidChange(_:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: player)
    }
    
    /**
     移除通知
     */
    fileprivate func removeMovieNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    /**
     加载状态发生改变监听
     */
    @objc
    fileprivate func loadStateDidChange(_ notification: Notification) {
        
        let loadState = player.loadState
        
        switch loadState {
        case IJKMPMovieLoadState():
            // 回调加载状态
            delegate?.player(self, playerStateChanged: .unknown)
            
        case IJKMPMovieLoadState.playable:
            // 回调加载状态
            delegate?.player(self, playerStateChanged: .playable)
            
        case IJKMPMovieLoadState.playthroughOK:
            // 回调加载状态
            delegate?.player(self, playerStateChanged: .playthroughOK)
            
        case IJKMPMovieLoadState.stalled:
            // 回调加载状态
            delegate?.player(self, playerStateChanged: .stalled)
            
        default:
            return
        }
        
    }
    
    /**
     播放完成监听
     */
    @objc
    fileprivate func moviePlayBackDidFinish(_ notification: Notification) {
        
        let reason = IJKMPMovieFinishReason(rawValue: Int(notification.userInfo!["IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey"]! as! NSNumber))!
        switch reason {
        case IJKMPMovieFinishReason.playbackEnded:
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .playbackEnded)
            
        case IJKMPMovieFinishReason.playbackError:
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .playbackError)
            
        case IJKMPMovieFinishReason.userExited:
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .userExited)
            
        }
    }
    
    @objc
    fileprivate func mediaIsPreparedToPlayDidChange(_ notification: Notification) {

    }
    
    /**
     播放状态改变监听
     */
    @objc
    fileprivate func moviePlayBackStateDidChange(_ notification: Notification) {
        
        switch player.playbackState {
        case IJKMPMoviePlaybackState.stopped:
            // 暂停定时器
            pauseTimer()
            // 切换到暂停图标
            controlView.playBtn.isSelected = false
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .stopped)
            
        case IJKMPMoviePlaybackState.playing:
            // 开启定时器并隐藏加载UI
            startTimer()
            // 切换到播放图标
            controlView.playBtn.isSelected = true
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .playing)
            
        case IJKMPMoviePlaybackState.paused:
            // 暂停定时器
            pauseTimer()
            // 切换到暂停图标
            controlView.playBtn.isSelected = false
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .paused)
            
        case IJKMPMoviePlaybackState.interrupted:
            // 暂停定时器
            pauseTimer()
            // 切换到暂停图标
            controlView.playBtn.isSelected = false
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .interrupted)
            
        case IJKMPMoviePlaybackState.seekingForward:
            // 切换到暂停图标
            controlView.playBtn.isSelected = false
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .seekingForward)
            
        case IJKMPMoviePlaybackState.seekingBackward:
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .seekingBackward)
            
        }
        
    }
}

