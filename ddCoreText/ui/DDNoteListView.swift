//
//  DDNoteListView.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/20.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit

private let kDDNoteListCell = "kDDNoteListCell"

class DDNoteListView: UIView {

    var notes: [String]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupUI() {
        dismissBtn.addTarget(self, action: #selector(removeNoteList), for: .touchUpInside)
        dismissBtn.frame = frame
        addSubview(dismissBtn)
        tableView.frame = CGRect(x: 30, y: frame.height * 0.25, width: SizeStyle.screenWidth - 60, height: frame.height * 0.5)
        addSubview(tableView)
    }
    
    /// 展示
    func show() {
        alpha = 0
        let window = UIApplication.shared.windows.last
        window?.addSubview(self)
        UIView.animate(withDuration: 0.3) { 
            self.alpha = 1
        }
    }
    
    ///
    @objc
    fileprivate func removeNoteList() {
        UIView.animate(withDuration: 0.3, animations: { 
            self.alpha = 0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        let nib = UINib(nibName: "ddNoteListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: kDDNoteListCell)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        return tableView
    }()
    
    fileprivate lazy var dismissBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return btn
    }()
}

extension DDNoteListView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kDDNoteListCell, for: indexPath) as! DDNoteListCell
        cell.content = notes![indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}
