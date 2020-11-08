//
//  CommentInputAccessoryView.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import Nuke

protocol CommentInputAccessoryViewDelegate: class {
    func tappedSendCommentButton(text: String)
}

class CommentInputAccessoryView: UIView {
    
    
    
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var commentSendButton: UIButton!
    @IBOutlet weak var commentPlaceholder: UILabel!
    
    weak var delegate: CommentInputAccessoryViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInited()
        
        commentSendButton.isEnabled = false
        commentSendButton.setTitleColor(UIColor.gray, for: .normal)
        autoresizingMask = .flexibleHeight
        commentText.text = ""
        commentText.delegate = self
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        commentText.keyboardAppearance = .dark
        
    }
    
    //  送信後の処理メソッド
    func removeText() {
        commentText.text = ""
        commentSendButton.isEnabled = false
        commentSendButton.setTitleColor(UIColor.gray, for: .normal)
    }
    
    
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    private func nibInited() {
        let nib = UINib(nibName: "CommentInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    @IBAction func commentSendTap(_ sender: Any) {
        guard let text = commentText.text else { return }
        delegate?.tappedSendCommentButton(text: text)
        
        //  送信ボタンを押すとキーボードが閉じる処理
        commentText.resignFirstResponder()
        
    }
    
    
}
extension CommentInputAccessoryView: UITextViewDelegate {
    
    //  コメント欄に入力された文字を認識してくれる処理
    func textViewDidChange(_ textView: UITextView) {
        //  もしコメント欄が未記入だったら...
        if commentText.text.isEmpty {
            commentSendButton.isEnabled = false  //送信ボタンは押せる。
            commentPlaceholder.isHidden = false
            commentSendButton.setTitleColor(UIColor.gray, for: .normal)
            
        }else{  //  記入されたら...
            commentSendButton.isEnabled = true  //送信ボタンは押せない。
            commentPlaceholder.isHidden = true
            commentSendButton.setTitleColor(UIColor.black, for: .normal)
        }
    }
    

}
