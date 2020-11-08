//
//  ProfileSettingViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/10.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Nuke

class ProfileSettingViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate  {
    
    private var user: User? {
        //  ユーザーの情報を表示させる。
        didSet {
            //  ユーザー名
            profileSettingNameTextField.text = user?.username
            // 　自己紹介
            profileSettingintroductionTextView.text = user?.profilecomment
            //  画像を認識し、反映。
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: profileSettingImageView)
            }
            
        }
    }
    
    var bottings: Bottings?
    
    
    @IBOutlet weak var profileSettingImageView: UIImageView!
    @IBOutlet weak var profileSettingNameTextField: UITextField!
    @IBOutlet weak var profileSettingintroductionTextView: UITextView!
    @IBOutlet weak var profilename: UILabel!
    @IBOutlet weak var profileintroduction: UILabel!
    @IBOutlet weak var profileLogo: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        profileSettingNameTextField.delegate = self
        profileSettingintroductionTextView.delegate = self// 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        profileSettingNameTextField.keyboardAppearance = .dark
        profileSettingintroductionTextView.keyboardAppearance = .dark
        self.profileSettingNameTextField.becomeFirstResponder()
        
        navigationItem.title = "アカウント設定"
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let profileSettingBackButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(tapBackProfile))
        let profileSettingSaveButton: UIBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(tapSaveProfile))
        navigationItem.leftBarButtonItem = profileSettingBackButton
        navigationItem.rightBarButtonItem = profileSettingSaveButton
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        
        profileSettingImageView.layer.cornerRadius = 60
        profileSettingintroductionTextView.layer.cornerRadius = 10
        profileSettingImageView.layer.borderWidth = 1
        profileSettingImageView.layer.borderColor = UIColor.black.cgColor
        
        // 自分の user 情報を表示
        fetchSettingProfileUserInfo()
        
        
    }
    
    
    // 自分の user 情報の取得をする処理
    private func fetchSettingProfileUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { (snapshot, err) in
//            .getDocument { (snapshot, err) in         //  リアルタイム更新なら⬆︎こっち。
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            
            let user = User(dic: dic)
            self.user = user
        }
    }
    
    //  戻るボタンが押された時の処理
    @objc func tapBackProfile() {
        self.dismiss(animated: true, completion: nil)
    }
    // 保存ボタンが押された時の処理
    @objc func tapSaveProfile() {
        guard let image = profileSettingImageView.image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("users").child(fileName)
        
        storageRef.putData(uploadImage, metadata: nil) { (matadata, err) in
            if let err = err {
                print("Firestorageへの保存に失敗しました。\(err)")
                return
            }
            storageRef.downloadURL { (url, err) in
                if let err = err {
                    print("Firestorageからのダウンロードに失敗しました。\(err)")
                    return
                }
                guard let urlString = url?.absoluteString else { return }
                self.profileSettingFirestore(profileImageUrl: urlString)
            }
        }
    }
    //  プロフィール設定更新
    private func profileSettingFirestore(profileImageUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let username = profileSettingNameTextField.text else { return }
        guard let profilecomment = profileSettingintroductionTextView.text else { return }
        let docData = [
            "username": username,
            "profilecomment": profilecomment,
            "profileImageUrl": profileImageUrl
        ] as [String : Any]
        Firestore.firestore().collection("users").document(uid).updateData(docData) { (err) in
            if let err = err {
                print("Firestoreへの更新に失敗しました。\(err)")
                return
            }
            print("Firestoreへの更新に成功しました。")
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    //  タッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 画面(どこでも可)をタッチすればキーボードを閉じる
        view.endEditing(true)
        
    }
    
    
    // MARK: -  プロフィール編集
    
    //  プロフィール画像がタップされさ時の処理
    @IBAction func profileSettingAction(_ sender: Any) {
//        print("タップ")
        //  アルバム表示をする処理
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        //  写真及び、画像の拡大等可能にする処理
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
        
    
    
}
extension ProfileSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //  アルバム表示して、写真及び、画像の追加ができる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            profileSettingImageView.image = image
        }
        
        //  丸枠綺麗に収まるように処理
        profileSettingImageView.contentMode = .scaleAspectFill
        profileSettingImageView.clipsToBounds = true
        //  元の画面に戻る(画面遷移)処理
        dismiss(animated: true, completion: nil)
    }
}
