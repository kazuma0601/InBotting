//
//  TalkViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/09/27.
//

import UIKit

class TalkViewController: UIViewController {
    
    
    @IBOutlet weak var InButton1: UIButton!
    @IBOutlet weak var InButton1sub: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .dark
        navigationItem.title = "コミュ力 Lv.0"
        
        //  ナビゲーションバーの影(シャドー)設定 vr.1
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false
        
        
        //  陰(ツイート)ボタンの影(シャドー)設定
        self.InButton1.layer.shadowColor = UIColor.white.cgColor
        self.InButton1.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.InButton1.layer.shadowRadius = 4.0
        self.InButton1.layer.shadowOpacity = 1.0
        self.InButton1.layer.masksToBounds = false
        self.InButton1sub.layer.cornerRadius = 7.0
        
        
    }
    //  ユーザーリストのボタンが押さえれた時の処理
    @IBAction func userListButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "UserList", bundle: nil)
        let userListViewController = storyboard.instantiateViewController(withIdentifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: userListViewController)
        self.present(nav, animated: true, completion: nil)
        
    }
    
    
    
    //  投稿画面ボタン
    @IBAction func inPostButton1(_ sender: Any) {
        //  投稿画面を表示させるための設定
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        let postViewController = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        //  投稿画面を表示
        self.present(postViewController, animated: true, completion: nil)
    }
    
    
    

}
