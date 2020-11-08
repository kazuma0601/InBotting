//
//  TimeLineViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/15.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import Nuke
import PKHUD

class TimeLineViewController: UIViewController, UITabBarControllerDelegate {
    
    var timelines = [TimeLines]()
    var username = ""
    var profileImage = ""
    var textView = ""
    var uid = ""
    var commentCount = Int()
    var heartCount = Int()
    
    //  タブバーを押した時、一番上に移動する処理
    var canScrollToTopTimeLine: Bool = false
    
    private let refreshControl = UIRefreshControl()
    
    private let cellId = "cellId"
    var user: User?
    var timeline: TimeLines?
    
    @IBOutlet weak var timeLineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // HUDを表示
        HUD.show(.progress)
        // HUDを表示して指定時間後に非表示にする
        HUD.flash(.progress, delay: 1)
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .dark
        //  リロード
        timeLineTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        
        timeLineTableView.delegate = self
        timeLineTableView.dataSource = self
        fetchTimeLineViewInfo()
        fetchDatabaseInfo()
        
        timeLineTableView.separatorColor = .gray
    }
    
    //  リロード処理
    @objc func refresh(sender: UIRefreshControl) {
        // ここに通信処理などデータフェッチの処理を書く
        self.timeLineTableView.reloadData()
        // データフェッチが終わったらUIRefreshControl.endRefreshing()を呼ぶ必要がある
        sender.endRefreshing()
    }
    
    
    //  タブバーを押した時、一番上に移動する処理
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.delegate = self
        canScrollToTopTimeLine = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        canScrollToTopTimeLine = false
    }
    //  タブバーを押した時、一番上に移動する処理
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // 呼ばれたTabBarItemの番号(0,1...)
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 1 && canScrollToTopTimeLine {
            // 一番上に移動
            self.timeLineTableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    
    // 自分の user 情報の取得をする処理メソッド
    private func fetchTimeLineViewInfo() {
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
    
    //  投稿を受信メソッド
    private func fetchDatabaseInfo() {
        //  投稿を受信
        let postsRef = Database.database().reference().child("timeLines")
        
        postsRef.observe(.value) { (snapshot) in
            self.timelines.removeAll()
            
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                let timeLines = TimeLines(snapshop: childSnapshot)
                
                print(timeLines)
                self.timelines.insert(timeLines, at: 0)
            }
            self.timeLineTableView.reloadData()
            
        }
    }
    
    
}
// MARK: - TableView
extension TimeLineViewController: UITableViewDelegate, UITableViewDataSource {

    //  cellの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        timeLineTableView.estimatedRowHeight = 60
        return UITableView.automaticDimension
    }
    //  タイムライン上にあるcell の数(投稿数)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelines.count
    }
    //  cellの値
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TimeLineTableViewCell
        let timeLine = timelines[indexPath.row]
        
        cell.timeLine = timeLine
        
        return cell
    }
    
    //  cellが選択された時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }


}

class TimeLineTableViewCell: UITableViewCell, UITextViewDelegate {
    
    
    @IBOutlet weak var timeLineProfileImageView: UIImageView!
    @IBOutlet weak var timeLineUserNameLabel: UILabel!
    @IBOutlet weak var timeLineTaxtView: UITextView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var heartCountLabel: UILabel!
    
    //  ライク・ハートボタンを押したか押してないかを判断する変数
    var heartTapFlag = false
    var commentTapFlag = false
    
    var user: User?
    
    var timeLine: TimeLines! {
        didSet {
            timeLineTaxtView.text = timeLine.textView
            //  ユーザー名
            timeLineUserNameLabel.text = timeLine.username
            //  プロフィール画像を認識し、反映。
            if let url = URL(string: timeLine.profileImage) {
                Nuke.loadImage(with: url, into: timeLineProfileImageView)
            }
            
            heartCountLabel.text = "\(timeLine.heartCount)"
            
            //  ライクボタン・ハートボタンが押されてない状態の場合...
            if heartTapFlag == false {
                //  ノーマルカラー
                heartButton.tintColor = .lightGray
                heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
                
            }else if timeLine.heartCount == 0 && heartTapFlag == true {
                //  更新時、heartTapFlag が true の状態のままなので一度 false に戻してあげる。
                heartTapFlag = false
                heartButton.tintColor = .lightGray
                heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
                
            }else if timeLine.heartCount == 0 && heartTapFlag == false {
                //  更新時、Heartボタンを押してなかった場合...
                heartButton.tintColor = .lightGray
                heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timeLineTaxtView.delegate = self
        timeLineProfileImageView.layer.cornerRadius = 27.5
        timeLineTaxtView.layer.cornerRadius = 10
        
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.tintColor = .lightGray
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    //  ハートボタンが押された時の処理
    @IBAction func heartButtonTap(_ sender: Any) {
        if heartTapFlag == false{
            timeLine.plusHeart()
            heartCountLabel.text = "\(timeLine.heartCount)"
            heartButton.tintColor = .red
            heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            heartTapFlag = true
            
        }else if heartTapFlag == true{
            //  再びハートボタンを押した時は 1 減らす。
            timeLine.minusHeart()
            heartCountLabel.text = "\(timeLine.heartCount)"
            heartButton.tintColor = .lightGray
            heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
            heartTapFlag = false
            
        }
    }
    
    
    //  ①日付、時間表示を設定メソッド
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
        
    }
}
