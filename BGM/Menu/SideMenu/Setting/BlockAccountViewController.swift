//
//  BlockAccountViewController.swift
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

//  背景画像設定
class BlockAccountViewController: UIViewController {
    
    private var user: User? {
        didSet {
            //  画像を認識し、反映。
            if let url = URL(string: user?.backgroundProfileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: backgroundImageView)
            }
        }
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "背景画像設定"
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let blockAccountBackButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(tapblockAccount))
        let profileSettingSaveButton: UIBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(tapSaveBackgroundProfile))
        navigationItem.leftBarButtonItem = blockAccountBackButton
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem = profileSettingSaveButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        fetchbackgroundUmageViewUserInfo()
    }
    
    //  戻るボタンが押された時の処理
    @objc func tapblockAccount() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 自分の user 情報の取得をする処理
    private func fetchbackgroundUmageViewUserInfo() {
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
    
    
    // 保存ボタンが押された時の処理
    @objc func tapSaveBackgroundProfile() {
        guard let backgroundImage = backgroundImageView.image else { return }
        guard let uploadBackgroundImage = backgroundImage.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("users").child(fileName)
        
        storageRef.putData(uploadBackgroundImage, metadata: nil) { (matadata, err) in
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
                self.profileBackgroundSettingFirestore(backgroundProfileImageUrl: urlString)
            }
        }
    }
    //  プロフィール設定更新
    private func profileBackgroundSettingFirestore(backgroundProfileImageUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docData = [
            "backgroundProfileImageUrl": backgroundProfileImageUrl
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
    
    @IBAction func backgroundImageAction(_ sender: Any) {
        //  アルバム表示をする処理
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        //  写真及び、画像の拡大等可能にする処理
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    

}
extension BlockAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //  アルバム表示して、写真及び、画像の追加ができる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            backgroundImageView.image = image
        }
        
        //  丸枠綺麗に収まるように処理
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        //  元の画面に戻る(画面遷移)処理
        dismiss(animated: true, completion: nil)
    }
}
