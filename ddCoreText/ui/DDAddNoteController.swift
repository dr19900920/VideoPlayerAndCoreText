//
//  DDAddNoteController.swift
//  summer-hill-ios
//
//  Created by dengrui on 17/2/20.
//  Copyright © 2017年 NEOTECHED. All rights reserved.
//

import UIKit

class DDAddNoteController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneBtn: UIButton!
    
    var mark: NEOMarkPartModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.becomeFirstResponder()
        textView.returnKeyType = .done
        textView.alwaysBounceVertical = true
        textView.keyboardDismissMode = .onDrag
        textView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        textView.resignFirstResponder()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationDDAddNote), object: nil, userInfo: ["mark": mark!])
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        postNewMark()
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func postNewMark() {
        mark?.note = textView.text
        mark?.type = "note"
        textView.resignFirstResponder()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationDDAddNote), object: nil, userInfo: ["mark": mark!])
    }

}

// MARK: - UITextViewDelegate
extension DDAddNoteController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            postNewMark()
            return false
        }
        return true
    }
    
    
}
