//
//  UserRoomViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/26.
//

import UIKit
import XLPagerTabStrip
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Nuke

class UserRoomViewController: ButtonBarPagerTabStripViewController {
    
    
    private let cellId = "cellId"
    
    //  SecondViewControllerのcellのユーザー情報を取得
    var pushUser: User?
    private var user: User? {
        //ユーザーの情報を表示させる。
        didSet {
            //  ユーザー名
            userRoomNameLabel.text = pushUser?.username
            // 　自己紹介
            userRoomCommentLabel.text = pushUser?.profilecomment
            //  画像を認識し、反映。
            if let url = URL(string: pushUser?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: userRoomProfileImageView)
            }
            //  画像を認識し、反映。
            if let url = URL(string: pushUser?.backgroundProfileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: userRoomBackImageView)
            }
        }
    }
    
    
    @IBOutlet weak var userRoomBackImageView: UIImageView!
    @IBOutlet weak var userRoomProfileImageView: UIImageView!
    @IBOutlet weak var userRoomNameLabel: UILabel!
    @IBOutlet weak var userRoomCommentLabel: UILabel!
    @IBOutlet weak var userRoomBackView: UIView!
    @IBOutlet weak var userRoomFollowButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        //  Menuデザイン設定
        self.loadDesignUserRoom()
        super.viewDidLoad()
        
        userRoomFollowButton.layer.cornerRadius = 15
        userRoomProfileImageView.layer.cornerRadius = 45
        userRoomProfileImageView.layer.borderWidth = 2
        userRoomProfileImageView.layer.borderColor = UIColor.white.cgColor
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        //  グラデーション設定
        gradientUserRoomColorView()
        
        fetchUserRoomInfoFromFirestore()
        
        
    }
    
    //  グラデーション設定
    private func gradientUserRoomColorView() {
        userRoomBackView.backgroundColor = UIColor.clear
        let topColor = UIColor.clear
        let bottomColor = UIColor.black
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.frame = userRoomBackView.bounds
        userRoomBackView.layer.insertSublayer(gradientLayer, at: 0)
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
    func loadDesignUserRoom() {
        
//        self.settings.style.selectedBarBackgroundColor = UIColor.black
        self.settings.style.buttonBarBackgroundColor = .black
        self.settings.style.buttonBarItemBackgroundColor = .black
        self.settings.style.selectedBarBackgroundColor = .white
        self.settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 16)
        self.settings.style.selectedBarHeight = 4.0      //  スライドする下線の太さ細さ調整
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
    
    
    
    //  user 情報の取得をする処理メソッド
    private func fetchUserRoomInfoFromFirestore() {
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

