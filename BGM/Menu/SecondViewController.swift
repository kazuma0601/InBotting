//
//  SecondViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/03.
//

//import UIKit
//import XLPagerTabStrip
//import FirebaseFirestore
//import FirebaseAuth
//import FirebaseStorage
//import Nuke
//
//class SecondViewController: UIViewController, IndicatorInfoProvider {
//
//    private var selectedUser: User?
//    private let cellId = "cellId"
//    private var users = [User]()
//
//    @IBOutlet weak var bottingCollectionView: UICollectionView!
//    @IBOutlet weak var recommendedUserTableView: UITableView!
//
//
//    //  Menu "トレンド"の変数
//    var itemInfo: IndicatorInfo = "おすすめ陰キャ"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//        bottingCollectionView.delegate = self
//        bottingCollectionView.dataSource = self
//        recommendedUserTableView.delegate = self
//        recommendedUserTableView.dataSource = self
//        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
//        self.overrideUserInterfaceStyle = .light
//
//        fetchRecommendedUserInfoFromFirestore()
//    }
//
//    //  ページスクロール
//    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
//        return itemInfo
//    }
//
//    //  user 情報の取得をする処理メソッド
//    private func fetchRecommendedUserInfoFromFirestore() {
//        Firestore.firestore().collection("users").addSnapshotListener { (snapshots, err) in
//            if let err = err {
//                print("user情報の取得に失敗しました。\(err)")
//                return
//            }
//            snapshots?.documents.forEach({ (snapshot) in
//                let dic = snapshot.data()
//                let user = User.init(dic: dic)
//                user.uid = snapshot.documentID
//
//                //  現在ログインしているユーザーのUIDを取得
//                guard let uid = Auth.auth().currentUser?.uid else { return }
//                //  もし、⬇︎このUID(ユーザー情報)が現在ログインしてるUID(ユーザー情報)と同じだったら追加しない..
//                if uid == snapshot.documentID {
//                    return
//                }
//                //  違った場合はユーザーリストに追加する
//                self.users.append(user)
//                self.recommendedUserTableView.reloadData()
//            })
//        }
//    }
//
//}
//
//
//extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
//
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 86
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return users.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = recommendedUserTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SecondTableViewCell
//        //  ユーザーの情報を渡す。
//        cell.user = users[indexPath.row]        //  登録しているユーザーの数だけ表示
//
//
//        //これでセルをタップ時、色は変化しなくなる
//        cell.selectionStyle = UITableViewCell.SelectionStyle.none
//        return cell
//    }
//    //  cell がタップされた時の処理
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        //  チャットルームへ画面遷移
//        let secondstoryboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
//        let userRoomViewController = secondstoryboard.instantiateViewController(withIdentifier: "UserRoomViewController") as! UserRoomViewController
//        //  ユーザー情報のドキュメント取得(プロフフィール表示)
//        userRoomViewController.pushUser = users[indexPath.row]
//
//        navigationController?.pushViewController(userRoomViewController, animated: true)
//
//        //  画面遷移時にTabBarを隠す処理
////        chatRoomViewController.hidesBottomBarWhenPushed = true
//        self.tabBarController?.tabBar.isHidden = true
//        self.tabBarController?.hidesBottomBarWhenPushed = true
//    }
//    //  画面遷移時(戻ってきた時)にTabBarを出す処理
//    override func viewWillAppear(_ animated: Bool) {
//        self.tabBarController?.tabBar.isHidden = false
//
//
//    }
//
//}
//
//
//extension SecondViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//
//
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 10
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = bottingCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SecondCollectionViewCell
//
//        return cell
//    }
//
//
//
//}
////  CollectionViewCell
//class SecondCollectionViewCell: UICollectionViewCell {
//
//    @IBOutlet weak var collectionProfileImageView: UIImageView!
//
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        collectionProfileImageView.layer.cornerRadius = 48
//
//
//    }
//
//
//}
//
////  TableViewCell
//class SecondTableViewCell: UITableViewCell {
//
//    var user: User? {
//        didSet {
//            recommendedUserNameLabel.text = user?.username
//            //  画像を認識し、反映。
//            if let url = URL(string: user?.profileImageUrl ?? "") {
//                Nuke.loadImage(with: url, into: recommendedUserProfileImageView)
//            }
//            recommendedUserTextView.text = user?.profilecomment
//        }
//    }
//
//
//    @IBOutlet weak var recommendedUserProfileImageView: UIImageView!
//    @IBOutlet weak var recommendedUserNameLabel: UILabel!
//    @IBOutlet weak var recommendedUserTextView: UITextView!
//
//
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        recommendedUserProfileImageView.layer.cornerRadius = 30
//
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//
//        // Configure the view for the selected state
//    }
//
//}
