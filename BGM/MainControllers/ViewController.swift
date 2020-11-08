//
//  ViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/09/27.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage



class ViewController: UIViewController, UITextFieldDelegate {
    
    //  投稿画面ボタン
    @IBOutlet weak var InButton3: UIButton!
    @IBOutlet weak var InButton3sub: UIImageView!
    //  サーチ表示の元
    let textField = UITextField()
    
    
    
    
    
    //    var shadowImage: UIImage?
    //  アラート表示
    var alertController: UIAlertController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .dark
        //  まだ、会員登録を行なっていない場合、下記の 起動時、会員登録画面が出る。
        if Auth.auth().currentUser?.uid == nil {
            //  起動時、会員登録画面が出る処理
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            let nav = UINavigationController(rootViewController: signUpViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        
        
        
        
        //  ナビゲーションバーの影(シャドー)設定 vr.1
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false
        //  陰(ツイート)ボタンの影(シャドー)設定
        self.InButton3.layer.shadowColor = UIColor.white.cgColor
        self.InButton3.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.InButton3.layer.shadowRadius = 4.0
        self.InButton3.layer.shadowOpacity = 1.0
        self.InButton3.layer.masksToBounds = false
        self.InButton3sub.layer.cornerRadius = 7.0
        
        
        //  サーチ表示の元
        textField.delegate = self
        
        
        
//        textField.backgroundColor = .white
//        textField.frame.size = CGSize(width: 240, height: 30)
//        textField.layer.cornerRadius = 15
//        textField.placeholder = "陰キャラ検索"
//        textField.textAlignment = .center
//        self.navigationItem.titleView = textField
        
        
        
    }
    
    //  投稿画面ボタン(投稿画面を表示)
    @IBAction func inPostButton3(_ sender: Any) {
//        投稿画面を表示させるための設定
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        let bottingPostViewController = storyboard.instantiateViewController(withIdentifier: "BottingPostViewController") as! BottingPostViewController
        //  投稿画面を表示
        self.present(bottingPostViewController, animated: true, completion: nil)
    }
    
    
    
    //  サーチ表示ボタンが押された時の処理
    @IBAction func searchButtonAction(_ sender: Any) {
        //  検索画面を表示させるための設定
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        let searchViewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        //  検索画面を表示
        self.present(searchViewController, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    //  アラート表示メソッド
    func showAlert() {
        //  表示設定
        alertController = UIAlertController(title: "選択", message: "どちらを使用しますか？", preferredStyle: .actionSheet)
        //  下からアラートが出てくるアクションバージョン
        let action1 = UIAlertAction(title: "カメラ", style: .default) { (alert) in
            
        }
        let action2 = UIAlertAction(title: "アルバム", style: .default) { (alert) in
            
        }
        let action3 = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        //  アラート表示(反映させる)
        present(alertController, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 画面(どこでも可)をタッチすればキーボードを閉じる
        view.endEditing(true)
        
    }
    
    
    
    
}

