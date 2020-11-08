//
//  HeartListBottingViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/11/04.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Nuke

class HeartListBottingViewController: UIViewController {
    
    var bottingheart: BottingHeart?
    
    
    @IBOutlet weak var heartProfileImageView: UIImageView!
    @IBOutlet weak var heartUserName: UILabel!
    @IBOutlet weak var heartTextView: UITextView!
    @IBOutlet weak var heartPostImageView: UIImageView!
    @IBOutlet weak var heartHeartCount: UILabel!
    
    
    //  ぼっちんぐハートリスト
    var heartListReflectProfileImageView = String()
    var heartListReflectUserName = String()
    var heartListReflectTextView = String()
    var heartListReflectPostImageView = String()
    var heartListReflectHeartCount = Int()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  オリジナルナビゲーション
        originalHeartNavigationBar()
        
        heartProfileImageView.layer.cornerRadius = 25
        
        //  ぼっちんぐハートリスト
        heartUserName.text = heartListReflectUserName
        if let url = URL(string: heartListReflectProfileImageView) {
            Nuke.loadImage(with: url, into: heartProfileImageView)
        }
        if let url = URL(string: heartListReflectPostImageView) {
            Nuke.loadImage(with: url, into: heartPostImageView)
        }
        heartTextView.text = heartListReflectTextView
        heartHeartCount.text = "\(heartListReflectHeartCount)"
    }
    
    
    //  オリジナルナビゲーション
    private func originalHeartNavigationBar() {
        navigationItem.title = "いいね"
//        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let postBackButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(tapaHeartpost))
        navigationItem.rightBarButtonItem = postBackButton
        navigationItem.rightBarButtonItem?.tintColor = .lightGray
    }
    
    //  削除ボタンが押された時の処理
    @objc func tapaHeartpost() {
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
//
//                self.navigationController?.popViewController(animated: true)
//            }))
//            self.present(alertSecond, animated: true, completion: nil)
//        }
        let action2 = UIAlertAction(title: "シェアする", style: .destructive) { action in
            let text = self.heartTextView.text
            let image = self.heartPostImageView.image
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
    
    
    // MARK: - 取得
    

}
