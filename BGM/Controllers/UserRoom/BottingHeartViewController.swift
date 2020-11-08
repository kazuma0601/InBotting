//
//  BottingHeartViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/11/02.
//

import UIKit
import XLPagerTabStrip
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Nuke

class BottingHeartViewController: UIViewController, IndicatorInfoProvider, UIGestureRecognizerDelegate {
    
    
    private var bottinghearts = [BottingHeart]()
    var userName = ""
    var profileImage = ""
    var textView = ""
    var postImage = ""
    var heartCount = Int()
    
    private let cellId = "cellId"
    var botting: BottingHeart?
    
    //  Menu "ニュース"の変数
    var itemInfo: IndicatorInfo = "いいね"
    
    @IBOutlet weak var bottingheartCollectionView: UICollectionView!
    
    var dictionarySelectedIndexPath: [IndexPath: Bool] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  ロングプレス(長押し)
        setupLongPressGesture()
        
        bottingheartCollectionView.delegate = self
        bottingheartCollectionView.dataSource = self
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        //  ぼっちング投稿の内容表示
        fetchBottingHeartViewBottingInfo()
    }
    //  ページング
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    //  ロングプレスメソッド(長押し)
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.3 // 長押し時間
        longPressGesture.delegate = self
        self.bottingheartCollectionView.addGestureRecognizer(longPressGesture)
    }
    //  ロングプレスアクションメソッド(長押しした時の処理)
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        //  ロングプレスアクションした時...
        if gestureRecognizer.state == .began {
            //  バイブ(振動させる処理)
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        } else if gestureRecognizer.state == .changed {   //  ロングプレスアクションして変化した時...
            let touchPoint = gestureRecognizer.location(in: self.bottingheartCollectionView)
            if let indexPath = self.bottingheartCollectionView.indexPathForItem(at: touchPoint) {
                let cell = self.bottingheartCollectionView.cellForItem(at: indexPath)
                cell?.tintColor = .black
                //  アラート表示設定
                let alert = UIAlertController()
                //  消去アラート表示
                let action1 = UIAlertAction(title: "削除", style: .destructive) { action in
                    //  アラート最終確認
                    let alertSecond = UIAlertController(title: "本当に削除しますか？", message: "", preferredStyle: .alert)
                    //  キャンセルした場合
                    alertSecond.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { action in
                    }))
                    //  続行した場合
                    alertSecond.addAction(UIAlertAction(title: "続行", style: .destructive, handler: { action in
                        
                        //  指定したcellの削除処理
                        self.bottingheartDelete()
                        self.bottinghearts.remove(at: indexPath.row)
                        self.bottingheartCollectionView.reloadData()
                        
                    }))
                    self.present(alertSecond, animated: true, completion: nil)
                }
                let action2 = UIAlertAction(title: "キャンセル", style: .cancel) { action in
                }
                alert.addAction(action1)
                alert.addAction(action2)
                //  アラート表示(反映させる)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    //  ハートリストの削除メソッド
    private func bottingheartDelete() {
        guard let heartDocData = botting?.Uid else { return }
        Firestore.firestore().collection("BottingHeart").document(heartDocData).delete() { (err) in
            if let err = err {
                print("ハートリストの削除に失敗しました。\(err)")
                return
            }
            print("ハートリストの削除に成功しました。")
        }
    }
    
// MARK: - ぼっちング投稿の内容を取得
    private func fetchBottingHeartViewBottingInfo() {
        Firestore.firestore().collection("BottingHeart").addSnapshotListener { (snapshots, err) in
            //  .getDocuments { (snapshots, err) in    //リアルタイム更新なら⬆︎こっち。
            if let err = err {
                print("BottingHeart情報の取得に失敗しました。\(err)")
                return
            }
            //  ぼっちング投稿の内容の取得
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                //  新しく追加されたデータだけを表示。
                case .added:
                    let dic = documentChange.document.data()
                    let botting = BottingHeart(dic: dic)
                    //  現在ログインしているユーザーのUIDを取得
                    guard let Uid = Auth.auth().currentUser?.uid else { return }
                    //  ぼっちング投稿者のUIDを取得
                    botting.myUser.forEach { (uid) in
                        //  ぼっちング投稿者のUIDが現在ログインしているユーザーのUIDと一緒だったら..表示させる。
                        if uid == Uid {
                            self.bottinghearts.insert(botting, at: 0)
                            self.bottingheartCollectionView.reloadData()
                        }
                    }
                case .modified, .removed:
                    print("nothing to do")
                }
            })
            //  ハートリストの削除用の取得
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let botting = BottingHeart(dic: dic)
                botting.Uid = snapshot.documentID

                self.botting = botting
            })
        }
    }
    
    
}
extension BottingHeartViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bottinghearts.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = bottingheartCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BottingHeartCollectionViewCell
        cell.bottingheart = bottinghearts[indexPath.row]
        return cell
    }
    
    //  cell がタップされた時の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        userName = bottinghearts[indexPath.row].userName
        profileImage = bottinghearts[indexPath.row].profileImage
        textView = bottinghearts[indexPath.row].textView
        postImage = bottinghearts[indexPath.row].postImage
        heartCount = bottinghearts[indexPath.row].heartCount
        performSegue(withIdentifier: "Heart", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Heart" {
            let HeartListBottingVC = segue.destination as! HeartListBottingViewController
            HeartListBottingVC.heartListReflectUserName = userName
            HeartListBottingVC.heartListReflectProfileImageView = profileImage
            HeartListBottingVC.heartListReflectTextView = textView
            HeartListBottingVC.heartListReflectPostImageView = postImage
            HeartListBottingVC.heartListReflectHeartCount = heartCount
        }
    }
    
    // collのサイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let size = (bottingCollectionView.frame.size.width - 20) / 3
//        return CGSize(width: size, height: size)
        return CGSize(width: (view.frame.size.width/3)-1,
                      height: (view.frame.size.width/3)-3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    // collectionView全体の上下横幅スペース
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    
}
class BottingHeartCollectionViewCell: UICollectionViewCell {
    
    var bottingheart: BottingHeart! {
        didSet {
            //  投稿画像
            if let url = URL(string: bottingheart.postImage) {
                Nuke.loadImage(with: url, into: bottingheartImageView)
            }
            
        }
    }

    @IBOutlet weak var bottingheartImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    
}
