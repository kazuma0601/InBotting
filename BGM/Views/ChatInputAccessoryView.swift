//
//  ChatInputAccessoryView.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/06.
//

import UIKit

//　①デリゲートを他にも渡す処理　　　　　　　　　　⬇︎エラーになった場合付ける
protocol ChatInputAccessoryViewDelegate: class {
    func tappedSendButton(text: String)
}
//  チャットコメント入力欄の Cell を作成
class ChatInputAccessoryView: UIView {
    
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    //  送信ボタンを押した時の処理
    @IBAction func tappedSendButton(_ sender: Any) {
        //  ③デリゲートを他にも渡す処理
        //  これでコメント欄に記入した情報が渡せる状態になる。
        guard  let text = chatTextView.text else { return }
        delegate?.tappedSendButton(text: text)
    }
    //  ②デリゲートを他にも渡す処理
    weak var delegate: ChatInputAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        nibInit()
        setupViews()
        autoresizingMask = .flexibleHeight
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        chatTextView.keyboardAppearance = .dark
    }
    
    private func setupViews() {
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1
        
        sendButton.layer.cornerRadius = 15
        sendButton.imageView?.contentMode = .scaleAspectFill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
        
        chatTextView.text = ""
        chatTextView.delegate = self
    }
    //  コメント送信時コメントを空欄にするメソッド
    func removeText() {
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    //  チャットコメント入力欄の Cell のファイルメソッド
    private func nibInit() {
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ChatInputAccessoryView: UITextViewDelegate {
    
    //  コメント欄に入力された文字を認識してくれる処理
    func textViewDidChange(_ textView: UITextView) {
        //  もしコメント欄が未記入だったら...
        if textView.text.isEmpty {
            sendButton.isEnabled = false  //送信ボタンは押せる。
        }else{  //  記入されたら...
            sendButton.isEnabled = true  //送信ボタンは押せない。
        }
    }
}
