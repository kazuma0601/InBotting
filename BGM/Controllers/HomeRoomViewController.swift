//
//  HomeRoomViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/07.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import Nuke
import XLPagerTabStrip
import PKHUD

//  マイページ画面
class HomeRoomViewController: ButtonBarPagerTabStripViewController {
    
    
    private var user: User? {
        //ユーザーの情報を表示させる。
        didSet {
            //  ユーザー名
            userHomeLabel.text = user?.username
            // 　自己紹介
            commentHomeLabel.text = user?.profilecomment
            //  画像を認識し、反映。
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: homeImageView)
            }
            //  背景画像を認識し、反映。
            if let url = URL(string: user?.backgroundProfileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: homeBackImageView)
            }
        }
    }
    
    @IBOutlet weak var homeBackImageView: UIImageView!
    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var userHomeLabel: UILabel!
    @IBOutlet weak var commentHomeLabel: UILabel!
    @IBOutlet weak var homeBackView: UIView!
    
    

    override func viewDidLoad() {
        //  Menuデザイン設定
        self.loadDesignHome()
        super.viewDidLoad()
        
        // HUDを表示
        HUD.show(.progress)
        // HUDを表示して指定時間後に非表示にする
        HUD.flash(.progress, delay: 0.2)
        
        homeImageView.layer.cornerRadius = 45
        homeImageView.layer.borderWidth = 2
        homeImageView.layer.borderColor = UIColor.white.cgColor
        // 常にダークモードを指定することでライトモード適用を回避
        self.overrideUserInterfaceStyle = .dark
        
        // 自分のユーザー情報を表示
        fetchLoginUserInfo()
        
        //  グラデーション設定
        gradientHomeColorView()
    }
    
    //  グラデーション設定
    private func gradientHomeColorView() {
        homeBackView.backgroundColor = UIColor.clear
        let topColor = UIColor.clear
        let bottomColor = UIColor.black
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.frame = homeBackView.bounds
        homeBackView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let bottingVC = UIStoryboard(name: "ChatRoom", bundle: nil).instantiateViewController(withIdentifier: "ぼっちんぐ")
//        let followVC = UIStoryboard(name: "ChatRoom", bundle: nil).instantiateViewController(withIdentifier: "フォロー")
//        let followerVC = UIStoryboard(name: "ChatRoom", bundle: nil).instantiateViewController(withIdentifier: "フォロワー")
        let heartVC = UIStoryboard(name: "ChatRoom", bundle: nil).instantiateViewController(withIdentifier: "いいね")
        let ChildViewControllers:[UIViewController] = [bottingVC, heartVC]
        
        return ChildViewControllers
    }
    
    //  デザイン設定
    func loadDesignHome() {
        
        self.settings.style.buttonBarBackgroundColor = .black
        self.settings.style.buttonBarItemBackgroundColor = .black
        self.settings.style.selectedBarBackgroundColor = .white
        self.settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 16)
        self.settings.style.selectedBarHeight = 2     //  スライドする下線の太さ細さ調整
        self.settings.style.buttonBarMinimumLineSpacing = 0
        self.settings.style.buttonBarItemTitleColor = .white
        self.settings.style.buttonBarItemsShouldFillAvailableWidth = true
        //  セレクトバーの全体幅(左)の調整
        self.settings.style.buttonBarLeftContentInset = 0
        //  セレクトバーの全体幅(右)の調整
        self.settings.style.buttonBarRightContentInset = -20
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?,ProgressReporting: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            //  選択された時の変色
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.gray
            newCell?.label.textColor = UIColor.white
            
        }
        
    }
    
    
    
    
    // 自分の user 情報の取得をする処理メソッド
    private func fetchLoginUserInfo() {
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
    
    
    
    

}
