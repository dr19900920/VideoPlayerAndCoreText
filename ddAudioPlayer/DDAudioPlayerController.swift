//
//  JFGrammarDetailViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/12.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit
import IJKMediaFramework

class DDAudioPlayerController: UIViewController {
    
    /// 音频地址
    var url: URL? {
        didSet {
            guard let url = url else {
                return
            }
            player.playWithURL(url)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        player.prepareToDeinit()
    }

    /**
     准备UI
     */
    fileprivate func prepareUI() {
        view.backgroundColor = UIColor.white
        view.addSubview(player)
        view.addSubview(dismissBtn)
        // 播放器
        player.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(0)
        }
        // 后退按钮
        dismissBtn.addTarget(self, action: #selector(dismissClick), for: .touchDown)
        dismissBtn.snp.makeConstraints { (make) in
            make.top.left.equalTo(40)
        }
    }
    
    @objc
    fileprivate func dismissClick() {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        debugLog("销毁")
    }
    
    // MARK: - 懒加载
    // 播放器
    fileprivate lazy var player: DDAudioPlayer = {
        let player = DDAudioPlayer()
        player.delegate = self
        return player
    }()
    
    // 后退按钮
    fileprivate lazy var dismissBtn: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(named: "ddaudioplayer_back"), for: UIControlState())
        return btn
    }()
}

// MARK: - DDAudioPlayerDelegate
extension DDAudioPlayerController: DDAudioPlayerDelegate {
    
    func player(_ player: DDAudioPlayer, playerStateChanged state: DDAudioPlayerState) {
        if state == .playbackEnded {
            // 自动播放下一节

        }
                
    }
}
