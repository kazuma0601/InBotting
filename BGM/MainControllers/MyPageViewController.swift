//
//  MyPageViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/09/27.
//

import UIKit


class MyPageViewController: UIViewController {
    
    @IBOutlet weak var InButton: UIButton!
    @IBOutlet weak var InButtonsub: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //  ナビゲーションバーの影(シャドー)設定 vr.1
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false
        
        
        //  陰(ツイート)ボタンの影(シャドー)設定
        self.InButton.layer.shadowColor = UIColor.white.cgColor
        self.InButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.InButton.layer.shadowRadius = 4.0
        self.InButton.layer.shadowOpacity = 1.0
        self.InButton.layer.masksToBounds = false
        self.InButtonsub.layer.cornerRadius = 7.0
        
        
    
        
    }
    
    
    //  投稿画面ボタン
    @IBAction func inPostButton(_ sender: Any) {
        //  投稿画面を表示させるための設定
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        let postViewController = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        //  投稿画面を表示
        self.present(postViewController, animated: true, completion: nil)
        
    }
    
    
    
        
        
//        let settingViewController = SettingViewController()
//        navigationController?.pushViewController(settingViewController, animated: true)

    
    
    

}
