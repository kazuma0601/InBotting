//
//  PostViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/04.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import Nuke

//  投稿画面
class PostViewController: UIViewController, UITextViewDelegate {
    
    var user: User?
    
    
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var postCharacterLimit: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .dark
        postTextView.keyboardAppearance = .dark
        postTextView.delegate = self
        //  予め投稿ボタンを押せない状態にしておく。(最初は未記入状態だから。)
        postButton.isEnabled = false
        postButton.tintColor = UIColor.lightGray
        postCharacterLimit.textColor = UIColor.darkGray
        //  画面表示時にキーボードが自動的に出る処理
        self.postTextView.becomeFirstResponder()
        
        
        //  ツールバーのインスタンス生成
        let toolBar = UIToolbar()
        //  ツールバーに配置するアイテムのインスタンスを作成
        let flexidleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let textButton: UIBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(taptextButton(_:)))
        //  ツールバーのアイテム配置
        toolBar.setItems([flexidleItem, textButton], animated: true)
        //  ツールバーのサイズ設定
        toolBar.sizeToFit()
        //  テキストフィールドにツールバーを設定
        postTextView.inputAccessoryView = toolBar
        
        fetchLoginUserInfo()
    }
    
    
    
    // 自分の user 情報の取得をする処理メソッド
    private func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            
            let user = User(dic: dic)
            self.user = user
        }
    }
    
    
    //  ツールバーのボタン(戻る)が押された時の処理
    @objc func taptextButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        
    }
    
    //  textViewの中のテキストが記入されたら呼ばれる処理
    func textViewDidChange(_ textView: UITextView) {
        //  もし、未入力だった場合...
        if postTextView.text == "" {
            //  placeholderLabel は消えない。
            placeHolderLabel.isHidden = false
            //  投稿ボタンは押せない。
            postButton.isEnabled = false
            postButton.tintColor = UIColor.lightGray
        }else{  //記入したら...
            //  placeholderLabel は消える。
            placeHolderLabel.isHidden = true
            //  投稿ボタン・戻るボタンは押せる。
            postButton.isEnabled = true
            postButton.tintColor = nil
        }
        
    }
    
    
    //  言わない(戻る)ボタンを押した時の処理
    @IBAction func postBackAction(_ sender: Any) {
        //  戻る処理
        dismiss(animated: true, completion: nil)
    }
    //  言う(投稿)ボタンを押した時の処理
    @IBAction func postAction(_ sender: Any) {
        
        if postTextView.text != "" {
            //  タイムライン情報の保存
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let name = user?.username else { return }
            guard let profileImage = user?.profileImageUrl else { return }
            guard let postText = postTextView.text else { return }
            let postRef = Database.database().reference().child("timeLines").childByAutoId()
            
            let postObjct = [
                "uid": uid,
                "username": name,
                "profileImage": profileImage,
                "textView": postText,
                "commentCount": Int(),
                "heartCount": Int()
            ] as [String : Any]
            postRef.setValue(postObjct) { (err, ref) in
                if let err = err {
                    print("タイムライン情報の保存に失敗しました。\(err)")
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    //  タッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 画面(どこでも可)をタッチすればキーボードを閉じる
        view.endEditing(true)
    }
    //  リターンキーを押した時にキーボードを閉じる
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        //  キーボードが閉じる処理
        postTextView.resignFirstResponder()
        
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 入力を反映させたテキストを取得する
        let resultText: String = (postTextView.text! as NSString).replacingCharacters(in: range, with: text)
        if resultText.count >= 10 {
            postCharacterLimit.textColor = UIColor.white
        }else{
            postCharacterLimit.textColor = UIColor.darkGray
        }
        if resultText.count >= 145 {
            postCharacterLimit.text = "残り５字"
            postCharacterLimit.textColor = UIColor.red
        } else {
            postCharacterLimit.text = "150字まで"
        }
        if resultText.count <= 150 {
            return true
        }
        return false
    }
    

}
