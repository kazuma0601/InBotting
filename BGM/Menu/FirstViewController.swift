//
//  FirstViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/03.
//

import UIKit
import XLPagerTabStrip
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Nuke

//class FirstViewController: UIViewController, IndicatorInfoProvider, UITabBarControllerDelegate {
class FirstViewController: UIViewController, UITabBarControllerDelegate {
    
    private var bottings = [Bottings]()
    
    private let cellId = "cellId"
    //  タブバーを押した時、一番上に移動する処理
    var canScrollToTop: Bool = false
    
    @IBOutlet weak var bottingTableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    //  Menu "ホーム"の変数
//    var itemInfo: IndicatorInfo = "ぼっちんぐ"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .dark
        
        bottingTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        
        bottingTableView.delegate = self
        bottingTableView.dataSource = self
        
        // ぼっちング投稿を表示させる
        fetchFirstViewBottingInfo()
        
    }
    
    
    
    @objc func refresh(sender: UIRefreshControl) {
        // ここに通信処理などデータフェッチの処理を書く
        self.bottingTableView.reloadData()
        // データフェッチが終わったらUIRefreshControl.endRefreshing()を呼ぶ必要がある
        sender.endRefreshing()
    }
    
    
    
    //  タブバーを押した時、一番上に移動する処理
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.delegate = self
        canScrollToTop = true
        
        bottingTableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        canScrollToTop = false
    }
    //  タブバーを押した時、一番上に移動する処理
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // 呼ばれたTabBarItemの番号(0,1...)
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 && canScrollToTop {
            // 一番上に移動
            self.bottingTableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    //  ページスクロール
//    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
//        return itemInfo
//    }
    
    
    //  ぼっちング投稿の内容を取得
    private func fetchFirstViewBottingInfo() {
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
                    //Bottings情報のドキュメントを取得
                    botting.documentId = documentChange.document.documentID
                    
                    self.bottings.insert(botting, at: 0)
                    self.bottingTableView.reloadData()
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
    
    
}


extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 560
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bottings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = bottingTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! FirstViewTableViewCell
        let botting = bottings[indexPath.row]
        cell.botting = botting
        
        cell.bottingcomment = bottings[indexPath.row]   //Bottings情報のドキュメント取得(ハートカウント機能)
        cell.bottingheart = bottings[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  コメント欄画面を表示させるための設定
        let bottingstoryboard = UIStoryboard(name: "Post", bundle: nil)
        let detailViewController = bottingstoryboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        let nav = UINavigationController(rootViewController: detailViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        detailViewController.bottingcomments = bottings[indexPath.row]    //Bottings情報のドキュメント取得(コメント表示)
    }
    
}


class FirstViewTableViewCell: UITableViewCell {
    //  ハートカウント機能
    var bottingcomment: Bottings?
    //  ハートリスト
    var bottingheart: Bottings?
    
    @IBOutlet weak var bottingTableMainImageView: UIImageView!
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var bottombackgroundColorView: UIView!
    @IBOutlet weak var bottingTableUserNameLabel: UILabel!
    @IBOutlet weak var bottingTableProfileImageView: UIImageView!
    @IBOutlet weak var bottingTableTextView: UITextView!
    @IBOutlet weak var bottingHeartButton: UIButton!
    @IBOutlet weak var bottingCommentImage: UIImageView!
    @IBOutlet weak var bottingHeartCountLabel: UILabel!
    @IBOutlet weak var bottingCommentCountLabel: UILabel!
    
    var user: User?
    var bottingHT: BottingHeart?
    
    //  ライク・ハートボタンを押したか押してないかを判断する変数
    var heartTapFlag = false
    var commentTapFlag = false
    //  ぼっちング投稿を表示させる
    var botting: Bottings! {
        didSet {
            //  ユーザー名
            bottingTableUserNameLabel.text = botting.userName
            //  プロフィール画像を認識し、反映。
            if let url = URL(string: botting.profileImage) {
                Nuke.loadImage(with: url, into: bottingTableProfileImageView)
            }
            
            bottingCommentCountLabel.text = "\(botting.commentCount)"
            bottingHeartCountLabel.text = "\(botting.heartCount)"
            //  コメントテキスト
            bottingTableTextView.text = botting.textView
            //  投稿画像
            if let url = URL(string: botting.postImage) {
                Nuke.loadImage(with: url, into: bottingTableMainImageView)
            }
            
            //  ライクボタン・ハートボタンが押されてない状態の場合...
            if heartTapFlag == false {
                //  ノーマルカラー
                bottingHeartButton.tintColor = .white
                
            }else if botting.heartCount == 0 && heartTapFlag == true {
                //  更新時、heartTapFlag が true の状態のままなので一度 false に戻してあげる。
                heartTapFlag = false
                bottingHeartButton.tintColor = .white
                
            }else if botting.heartCount == 0 && heartTapFlag == false {
                //  更新時、Heartボタンを押してなかった場合...
                bottingHeartButton.tintColor = .white
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bottingTableProfileImageView.layer.cornerRadius = 33
        bottingTableProfileImageView.layer.borderWidth = 2
        bottingTableProfileImageView.layer.borderColor = UIColor.white.cgColor
        
        //  グラデーション設定
        gradientColorView()
        
        
        fetchBottingHeartPostUserInfo()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //  グラデーション設定
    private func gradientColorView() {
        //  Topグラデーション設定
        backgroundColorView.backgroundColor = UIColor.clear
        let topColor = UIColor.black
        let bottomColor = UIColor.clear
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.frame = backgroundColorView.bounds
        backgroundColorView.layer.insertSublayer(gradientLayer, at: 0)
        //  Bottomグラデーション設定
        bottombackgroundColorView
            .backgroundColor = UIColor.clear
        let TopColor = UIColor.clear
        let BottomColor = UIColor.black
        let GradientColors: [CGColor] = [TopColor.cgColor, BottomColor.cgColor]
        let GradientLayer: CAGradientLayer = CAGradientLayer()
        GradientLayer.colors = GradientColors
        GradientLayer.frame = bottombackgroundColorView.bounds
        bottombackgroundColorView.layer.insertSublayer(GradientLayer, at: 0)
    }
    
    //  グラデーション設定
    private func gradientColorBottomView() {
        
    }
    
    
    
    //  ハートボタンが押された時の処理
    @IBAction func bottingHeartButtonTap(_ sender: Any) {
        if Auth.auth().currentUser?.uid != nil {
            if heartTapFlag == false{
                botting.plusHH()
                bottingHeartCountLabel.text = "\(botting.heartCount)"
                plusHeartCount()  //プラスカウント更新
                bottingHeartList()   //ハートリストに保存
                bottingHeartButton.tintColor = .red
                heartTapFlag = true
                
            }else if heartTapFlag == true{
                botting.minusHH()
                //  再びハートボタンを押した時は 1 減らす。
                bottingHeartCountLabel.text = "\(botting.heartCount)"
                minusHeartCount()  //マイナスカウント更新
                bottingHeartButton.tintColor = .white
                heartTapFlag = false
            }
        }else{
            if heartTapFlag == false{
                botting.plusHH()
                bottingHeartCountLabel.text = "\(botting.heartCount)"
                plusHeartCount()  //プラスカウント更新
                bottingHeartList()   //ハートリストに保存
                bottingHeartButton.tintColor = .red
                heartTapFlag = true
                
            }else if heartTapFlag == true{
                botting.minusHH()
                //  再びハートボタンを押した時は 1 減らす。
                bottingHeartCountLabel.text = "\(botting.heartCount)"
                minusHeartCount()  //マイナスカウント更新
                bottingHeartButton.tintColor = .white
                heartTapFlag = false
            }
        }
        
    }
    
    //  ハートボタンのプラスカウントメソッド
    private func plusHeartCount() {
        guard let commentData = bottingcomment?.documentId else { return }
        let upData = ([
            "heartCount": FieldValue.increment(Int64(1))
        ])
        Firestore.firestore().collection("Bottings").document(commentData).updateData(upData) { (err) in
            if let err = err {
                print("ハートボタンのプラスカウント更新に失敗しました。\(err)")
                return
            }
            print("ハートボタンのプラスカウント更新に成功しました。")
        }
    }
    //  ハートボタンのマイナスカウントメソッド
    private func minusHeartCount() {
        guard let commentData = bottingcomment?.documentId else { return }
        let upData = ([
            "heartCount": FieldValue.increment(Int64(-1))
        ])
        Firestore.firestore().collection("Bottings").document(commentData).updateData(upData) { (err) in
            if let err = err {
                print("ハートボタンのマイナスカウント更新に失敗しました。\(err)")
                return
            }
            print("ハートボタンのマイナスカウント更新に成功しました。")
        }
    }
    
    
// MARK: - 取得
    // 自分の user 情報の取得をする処理メソッド
    private func fetchBottingHeartPostUserInfo() {
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
    //  ぼっちング投稿の内容を取得
    private func fetchimageBottingViewBottingInfo() {
        guard let bottingID = bottingHT?.Uid else { return }
        Firestore.firestore().collection("BottingHeart").document(bottingID).addSnapshotListener { (snapshots, err) in
            //  .getDocuments { (snapshots, err) in    //リアルタイム更新なら⬆︎こっち。
            if let err = err {
                print("Bottings情報の取得に失敗しました。\(err)")
                return
            }
            //  現在ログインしているユーザーのUIDを取得
            guard let snapshot = snapshots, let dic = snapshot.data() else { return }
            
            let bottinghearts = BottingHeart(dic: dic)
            bottinghearts.Uid = snapshot.documentID
            self.bottingHT = bottinghearts
        }
    }
    
    
// MARK: - ハートリストに保存・削除
    //  ハートリストに保存メソッド
    private func bottingHeartList() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let userName = bottingheart?.userName else { return }
        guard let profileImage = bottingheart?.profileImage else { return }
        guard let textView = bottingheart?.textView else { return }
        guard let postImage = bottingheart?.postImage else { return }
        guard let heartCount = bottingheart?.heartCount else { return }
        guard let commentCount = bottingheart?.commentCount else { return }
        let myUser = [uid]   //  ぼっちング投稿者のUID( []にすることで識別ができる)
        let heartList = [
            "userName": userName,
            "profileImage": profileImage,
            "textView": textView,
            "myUser": myUser,
            "postImage": postImage,
            "heartCount": heartCount,
            "commentCount": commentCount
        ] as [String : Any]
        Firestore.firestore().collection("BottingHeart").addDocument(data: heartList) { (err) in
            if let err = err {
                print("ハートリスト情報の保存に失敗しました。\(err)")
                return
            }
            print("ハートリスト情報の保存に成功しました。")
        }
        
    }
    
    
}
