//
//  ChatRoomTableViewCell.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/06.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Nuke

class ChatRoomTableViewCell: UITableViewCell {
    
    //  ②メッセージの幅を調整させるメソッドの計算及び微調整
    var message: Message? {
        didSet {
//            if let message = message {
//                partnerMessageTextView.text = message.message
//                let witdh = estimateFrameForTextView(text: message.message).width + 20
//                messageTextViewWidthConstraint.constant = witdh
//                partnerDateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
//
//            }
        }
    }
   
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    @IBOutlet weak var myDateLabel: UILabel!
    
    @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var myMessageTextViewWidthConstraint: NSLayoutConstraint!
    
    //  Xib読み込み時に呼ばれる（ViewControllerのviewDidLoad的なもの）
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        userImageView.layer.cornerRadius = 25
        partnerMessageTextView.layer.cornerRadius = 15
        myMessageTextView.layer.cornerRadius = 15
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //  チャットメッセージ確認
        checkWhichUserMessage()
    }
    //  チャットメッセージ確認メソッド
    private func checkWhichUserMessage() {
        //  現在ログインしている MyユーザーのUIDを取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //  もし、このUID(ユーザー情報)が現在ログインしてるUID(ユーザー情報)と同じだった場合はメッセージを表示。
        if uid == message?.uid {
            partnerMessageTextView.isHidden = true
            partnerDateLabel.isHidden = true
            userImageView.isHidden = true
            //  メッセージの幅を調整させるメソッドの計算及び微調整
            myMessageTextView.isHidden = false
            myDateLabel.isHidden = false
            if let message = message {
                myMessageTextView.text = message.message
                let witdh = estimateFrameForTextView(text: message.message).width + 20
                myMessageTextViewWidthConstraint.constant = witdh
                myDateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
            }
        } else {   // 　違っていて、他人のUID(ユーザー情報)だった場合は表示させない。
            partnerMessageTextView.isHidden = false
            partnerDateLabel.isHidden = false
            userImageView.isHidden = false
            //  メッセージの幅を調整させるメソッドの計算及び微調整
            myMessageTextView.isHidden = true
            myDateLabel.isHidden = true
            if let urlString = message?.partnerUser?.profileImageUrl, let url = URL(string: urlString) {
                Nuke.loadImage(with: url, into: userImageView)
            }
            
            if let message = message {
                partnerMessageTextView.text = message.message
                let witdh = estimateFrameForTextView(text: message.message).width + 20
                messageTextViewWidthConstraint.constant = witdh
                partnerDateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
            }
        }
        
    }
    
    //  ①チャットコメント欄の幅を調整させるメソッド(定番)
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)   //マックス値
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    //  ①日付、時間表示を設定メソッド
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
//        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
        
    }
}
