//
//  PhotoPageContainerViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/31.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Nuke

class PhotoPageContainerViewController: UIViewController {
    
//    private var botting = [Bottings]()
    var imageBotting: Bottings?
    
    private var user: User? {
        didSet {
            imageUserNameLabel.text = user?.username
            //  プロフィール画像を認識し、反映。
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: imageProfileImageView)
            }
        }
    }
    
    
    @IBOutlet weak var imageProfileImageView: UIImageView!
    @IBOutlet weak var imageUserNameLabel: UILabel!
    @IBOutlet weak var imageTextView: UITextView!
    @IBOutlet weak var imagePostImageView: UIImageView!
    @IBOutlet weak var imageHeartButton: UIButton!
    @IBOutlet weak var imageHeartCountLabel: UILabel!
    
    //  ぼっちんぐ投稿
    var ReflectProfileImageView = String()
    var ReflectUserName = String()
    var ReflectTextView = String()
    var ReflectPostImageView = String()
    var ReflectHeartCount = Int()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchimageBottingViewBottingInfo()
        
        imageProfileImageView.layer.cornerRadius = 25
        
        //  ぼっちんぐ投稿
        imageUserNameLabel.text = ReflectUserName
        //  プロフィール画像を認識し、反映。
        if let url = URL(string: ReflectProfileImageView) {
            Nuke.loadImage(with: url, into: imageProfileImageView)
        }
        if let url = URL(string: ReflectPostImageView) {
            Nuke.loadImage(with: url, into: imagePostImageView)
        }
        imageTextView.text = ReflectTextView
        imageHeartCountLabel.text = "\(ReflectHeartCount)"
        
        //  オリジナルナビゲーション
        originalNavigationBar()
        //  ユーザー情報の取得
        fetchImageFirestore()
        
    }
    //  オリジナルナビゲーション
    private func originalNavigationBar() {
        navigationItem.title = "投稿"
//        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let postBackButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(tappost))
        navigationItem.rightBarButtonItem = postBackButton
        navigationItem.rightBarButtonItem?.tintColor = .lightGray
    }
    //  削除ボタンが押された時の処理
    @objc func tappost() {
        //  表示設定
        let alert = UIAlertController()
//        let action1 = UIAlertAction(title: "削除", style: .destructive) { action in
//            //  アラート最終確認
//            let alertSecond = UIAlertController(title: "本当に削除しますか？", message: "", preferredStyle: .alert)
//            //  キャンセルした場合
//            alertSecond.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { action in
//            }))
//            //  続行した場合
//            alertSecond.addAction(UIAlertAction(title: "続行", style: .destructive, handler: { action in
//                self.navigationController?.popViewController(animated: true)
//            }))
//            self.present(alertSecond, animated: true, completion: nil)
//        }
        let action2 = UIAlertAction(title: "シェアする", style: .destructive) { action in
            let text = self.imageTextView.text
            let image = self.imagePostImageView.image
            let items = [text as Any, image as Any] as [Any]
            
            let activeVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(activeVC, animated: true, completion: nil)
        }
        let action3 = UIAlertAction(title: "キャンセル", style: .cancel) { action in
        }
        
//        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        //  アラート表示(反映させる)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    
    //  ぼっちング投稿の内容を取得
    private func fetchimageBottingViewBottingInfo() {
        Firestore.firestore().collection("Bottings").addSnapshotListener { (snapshots, err) in
            //  .getDocuments { (snapshots, err) in    //リアルタイム更新なら⬆︎こっち。
            if let err = err {
                print("Bottings情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                //  新しく追加されたデータだけを表示。
                case .added:
                    let dic = documentChange.document.data()
                    let botting = Bottings(dic: dic)
                    botting.documentId = documentChange.document.documentID
                    
                    //  現在ログインしているユーザーのUIDを取得
                    guard let Uid = Auth.auth().currentUser?.uid else { return }
                    //  ぼっちング投稿者のUIDを取得
                    botting.myUser.forEach { (uid) in
                        //  ぼっちング投稿者のUIDが現在ログインしているユーザーのUIDと一緒だったら..取得させる。
                        if uid == Uid {
                            self.imageBotting = botting
                        }
                    }
                    
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
    
    //  user 情報の取得をする処理メソッド
    private func fetchImageFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            
            let user = User(dic: dic)
            self.user = user
        }
    }
    
}
