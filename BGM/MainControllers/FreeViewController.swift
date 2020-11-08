//
//  FreeViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/09/27.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class FreeViewController: UIViewController, UITextFieldDelegate {
    
    
    //  サーチ表示の元
    let textField = UITextField()
    
    
    
    //  陰(ツイート)ボタン
    @IBOutlet weak var InButton2: UIButton!
    @IBOutlet weak var InButton2sub: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  サーチ表示
        textFieldTouchDownNavigation()
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .dark
        
        //  ナビゲーションバーの影(シャドー)設定 vr.1
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false
        
        //  陰(ツイート)ボタンの影(シャドー)設定
        self.InButton2.layer.shadowColor = UIColor.white.cgColor
        self.InButton2.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.InButton2.layer.shadowRadius = 4.0
        self.InButton2.layer.shadowOpacity = 1.0
        self.InButton2.layer.masksToBounds = false
        self.InButton2sub.layer.cornerRadius = 7.0

    }
    
    
    //  投稿画面ボタン
    @IBAction func inPostButton2(_ sender: Any) {
        
        //  投稿画面を表示させるための設定
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        let postViewController = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        //  投稿画面を表示
        self.present(postViewController, animated: true, completion: nil)
        
        
    }
    
    private func textFieldTouchDownNavigation() {
        //  サーチ表示の元
        textField.addTarget(self, action: #selector(textFieldButton), for: .touchDown)
        textField.delegate = self
        textField.backgroundColor = .black
        textField.frame.size = CGSize(width: 240, height: 35)
        textField.layer.cornerRadius = 18
        textField.placeholder = "陰キャラ検索"
        textField.textAlignment = .center
        self.navigationItem.titleView = textField
        
    }
    //  サーチ表示させるための処理
    @objc func textFieldButton() {
        //  検索画面を表示させるための設定
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        let searchViewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        //  検索画面を表示
        self.present(searchViewController, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 画面(どこでも可)をタッチすればキーボードを閉じる
        view.endEditing(true)
    }
    

}
