//
//  BottingPostViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import Nuke
import PKHUD

class BottingPostViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var bottingPostProfileImageView: UIImageView!
    @IBOutlet weak var bottingPostPlaceholder: UILabel!
    @IBOutlet weak var bottingPostTextView: UITextView!
    @IBOutlet weak var bottingPostMainImageView: UIButton!
    @IBOutlet weak var bottingPostButton: UIBarButtonItem!
    @IBOutlet weak var bottingCharacterLimit: UILabel!
    
    
    var user: User? {
        didSet {
            //  画像を認識し、反映。
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: bottingPostProfileImageView)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .dark
        bottingPostTextView.keyboardAppearance = .dark
        
        bottingPostTextView.delegate = self
        //  予め投稿ボタンを押せない状態にしておく。(最初は未記入状態だから。)
        bottingPostButton.isEnabled = false
        bottingPostButton.tintColor = UIColor.lightGray
        bottingCharacterLimit.textColor = UIColor.darkGray
        //  画面表示時にキーボードが自動的に出る処理
        self.bottingPostTextView.becomeFirstResponder()
        
        bottingPostProfileImageView.layer.cornerRadius = 35
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        // 自分の user 情報の取得
        fetchBottingPostUserInfo()
        
        
        
        
        //  ツールバーのインスタンス生成
        let toolBottingBar = UIToolbar()
        //  ツールバーに配置するアイテムのインスタンスを作成
        let flexidleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let textButton: UIBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(taptextBottingButton(_:)))
        let imageButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: self, action: #selector(tapimageButton(_:)))
        
        toolBottingBar.setItems([imageButton, flexidleItem, textButton], animated: true)
        
        //  ツールバーのサイズ設定
        toolBottingBar.sizeToFit()
        //  テキストフィールドにツールバーを設定
        bottingPostTextView.inputAccessoryView = toolBottingBar
    }
    
    //  ツールバーのボタン(戻る)が押された時の処理
    @objc func taptextBottingButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        
    }
    @objc func tapimageButton(_ sender: UIButton) {
        //  アルバム表示をする処理
        let bottingImagePickerController = UIImagePickerController()
        bottingImagePickerController.delegate = self
        //  写真及び、画像の拡大等可能にする処理
        bottingImagePickerController.allowsEditing = true
        self.present(bottingImagePickerController, animated: true, completion: nil)
        
    }
    
    // 自分の user 情報の取得をする処理メソッド
    private func fetchBottingPostUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { (snapshot, err) in
            //  .getDocument { (snapshot, err) in    //  リアルタイム更新なら⬆︎こっち。
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            //  現在ログインしているユーザーのUIDを取得
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            
            let user = User(dic: dic)
            self.user = user
        }
    }

    
    
    
    //  textViewの中のテキストが記入されたら呼ばれる処理
    func textViewDidChange(_ textView: UITextView) {
        //  もし、未入力だった場合...
        if bottingPostTextView.text == "" {
            //  placeholderLabel は消えない。
            bottingPostPlaceholder.isHidden = false
            //  投稿ボタンは押せない。
            bottingPostButton.isEnabled = false
            bottingPostButton.tintColor = UIColor.lightGray
        }else{  //記入したら...
            //  placeholderLabel は消える。
            bottingPostPlaceholder.isHidden = true
            //  投稿ボタン・戻るボタンは押せる。
            bottingPostButton.isEnabled = true
            bottingPostButton.tintColor = nil
        }
        
    }
    
    
    //  戻るボタンを押した時の処理
    @IBAction func bottingPostBack(_ sender: Any) {
        //  戻る処理
        dismiss(animated: true, completion: nil)
    }
    //  ぼっちング(投稿)ボタンを押した時の処理
    @IBAction func bottingPostAction(_ sender: Any) {
        //  画像を Storage に保存する処理
        guard let image = bottingPostMainImageView.imageView?.image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        
        HUD.show(.progress)
        
        let bottingfileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("botting_image").child(bottingfileName)
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firestorageへ情報の保存が失敗しました。\(err)")
                HUD.hide()
                return
            }
            print("Firestorageへ情報の保存が成功しました。")
            //  Firestorageから、ダウンロードする処理
            storageRef.downloadURL { (url, err) in
                if  let err = err {
                    print("Firestorageからのダウンロードに失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                //  Firestorageから、ダウンロードした url を String型に変換する処理
                guard let urlString = url?.absoluteString else { return }
                //  ユーザーの情報をデータベースを Firestore に保存する処理をまとめたメソッドを付け加える。
                bottingPostUserToFirestore(postImage: urlString)
            }
        }
        //  ユーザーの情報をデータベースを Firestore に保存する処理をまとめたメソッド
        func bottingPostUserToFirestore(postImage: String) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            //  ユーザーの情報(UID: ユーザー個別のID)データベースを保存
            guard let userName = user?.username else { return }
            guard let bottingPostTextView = self.bottingPostTextView.text else { return }
            guard let profileImage = user?.profileImageUrl else { return }
            let myUser = [uid]   //  ぼっちング投稿者のUID( []にすることで識別ができる)
            
            let docData = [
                "userName": userName,
                "profileImage": profileImage,
                "textView": bottingPostTextView,
                "myUser": myUser,
                "createdAt": Timestamp(),
                "heartCount": Int(),
                "commentCount": Int(),
                "postImage": postImage  //Firestorageから、ダウンロードした url を String型に変換した後付け加える。(Firestoreに保存)
            ] as [String : Any]
            //　　　　　　　　　　　　　　　　　　　　　　　　　　　　⬇︎だと自動でドキュメントを指定してくれて追加される。
            Firestore.firestore().collection("Bottings").addDocument(data: docData) { (err) in
//                .document(uid).setData(docData) { (err) in  ⬅︎だと上書きされる。
                if let err = err {
                    print("Firestoreへの保存に失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                print("Firestoreへの保存が成功しました。")
                HUD.hide()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
    }
    
    
    //  プロフィール画像ボタンが押された時の処理
    @IBAction func tappedBottingPostMainImageView(_ sender: Any) {
        //  アルバム表示をする処理
        let bottingImagePickerController = UIImagePickerController()
        bottingImagePickerController.delegate = self
        //  写真及び、画像の拡大等可能にする処理
        bottingImagePickerController.allowsEditing = true
        self.present(bottingImagePickerController, animated: true, completion: nil)
    }
    
    //  タッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 画面(どこでも可)をタッチすればキーボードを閉じる
        view.endEditing(true)
    }
    //  リターンキーを押した時にキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //  キーボードが閉じる処理
        textField.resignFirstResponder()
        
        return true
    }
    
    //  文字数制限
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 入力を反映させたテキストを取得する
        let resultText: String = (bottingPostTextView.text! as NSString).replacingCharacters(in: range, with: text)
        if resultText.count >= 10 {
            bottingCharacterLimit.textColor = UIColor.white
        }else{
            bottingCharacterLimit.textColor = UIColor.darkGray
        }
        if resultText.count >= 55 {
            bottingCharacterLimit.text = "残り５字"
            bottingCharacterLimit.textColor = UIColor.red
        } else {
            bottingCharacterLimit.text = "60字まで"
        }
        if resultText.count <= 60 {
            return true
        }
        return false
    }
    

}

extension BottingPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //  アルバム表示して、写真及び、画像の追加ができる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //  もし、⬇︎の情報が nil ではなかったら...
        if let editImage = info[.editedImage] as? UIImage {
            //  大きさなど編集した写真及び、画像。
            bottingPostMainImageView.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let originalImage = info[.editedImage] as? UIImage {
            //  無編集の写真及び、画像。
            bottingPostMainImageView.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        //  丸枠綺麗に収まるように処理
        bottingPostMainImageView.setTitle("", for: .normal)
        bottingPostMainImageView.imageView?.contentMode = .scaleAspectFill
        bottingPostMainImageView.contentHorizontalAlignment = .fill
        bottingPostMainImageView.contentVerticalAlignment = .fill
        bottingPostMainImageView.clipsToBounds = true
        
        //  元の画面に戻る(画面遷移)処理
        dismiss(animated: true, completion: nil)
    }
    
    
}
