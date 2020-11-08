//
//  BottingScoreViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/27.
//

import UIKit
import XLPagerTabStrip
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Nuke

class BottingScoreViewController: UIViewController, IndicatorInfoProvider, UIGestureRecognizerDelegate {
    
    private var bottings = [Bottings]()
    var userName = ""
    var profileImage = ""
    var textView = ""
    var postImage = ""
    var heartCount = Int()
    var documentUid = ""
    
    var botting: Bottings?
    
    @IBOutlet weak var bottingCollectionView: UICollectionView!
    
    
    private let cellId = "cellId"
    //  Menu "ニュース"の変数
    var itemInfo: IndicatorInfo = "ぼっちんぐ"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  ロングプレス(長押し)
        setupMyUserLongPressGesture()
        
        bottingCollectionView.delegate = self
        bottingCollectionView.dataSource = self
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        //  ぼっちング投稿の内容表示
        fetchUserRoomViewBottingInfo()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    
    //  ロングプレスメソッド(長押し)
    func setupMyUserLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.3 // 長押し時間
        longPressGesture.delegate = self
        self.bottingCollectionView.addGestureRecognizer(longPressGesture)
    }
    //  ロングプレスアクションメソッド(長押しした時の処理)
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        //  ロングプレスアクションした時...
        if gestureRecognizer.state == .began {
            //  バイブ(振動させる処理)
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        } else if gestureRecognizer.state == .changed {   //  ロングプレスアクションして変化した時...
            let touchPoint = gestureRecognizer.location(in: self.bottingCollectionView)
            if let indexPath = self.bottingCollectionView.indexPathForItem(at: touchPoint) {
                let cell = self.bottingCollectionView.cellForItem(at: indexPath)
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
                        self.bottingDelete()
                        self.bottings.remove(at: indexPath.row)
                        self.bottingCollectionView.reloadData()
                        
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
    //  ぼっちんぐの削除メソッド
    private func bottingDelete() {
        guard let DocData = botting?.documentId else { return }
        Firestore.firestore().collection("Bottings").document(DocData).delete() { (err) in
            if let err = err {
                print("ハートリストの削除に失敗しました。\(err)")
                return
            }
            print("ハートリストの削除に成功しました。")
        }
    }
    
    
    // MARK: - ぼっちング投稿の内容を取得
    private func fetchUserRoomViewBottingInfo() {
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
                    //  現在ログインしているユーザーのUIDを取得
                    guard let Uid = Auth.auth().currentUser?.uid else { return }
                    //  ぼっちング投稿者のUIDを取得
                    botting.myUser.forEach { (uid) in
                        //  ぼっちング投稿者のUIDが現在ログインしているユーザーのUIDと一緒だったら..表示させる。
                        if uid == Uid {
                            self.bottings.insert(botting, at: 0)
                            self.bottingCollectionView.reloadData()
                        }
                    }
                case .modified, .removed:
                    print("nothing to do")
                }
            })
            //  ぼっちんぐの削除用の取得
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let botting = Bottings(dic: dic)
                botting.documentId = snapshot.documentID
                //  現在ログインしているユーザーのUIDを取得
                guard let Uid = Auth.auth().currentUser?.uid else { return }
                //  ぼっちング投稿者のUIDを取得
                botting.myUser.forEach { (uid) in
                    //  ぼっちング投稿者のUIDが現在ログインしているユーザーのUIDと一緒だったら..表示させる。
                    if uid == Uid {
                        self.botting = botting
                    }
                }
            })
        }
    }

}

extension BottingScoreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bottings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = bottingCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BottingScoreCollectionViewCell
        //  ぼっちング投稿の情報を渡す。
        cell.botting = bottings[indexPath.row]        // ぼっちング投稿の数だけ表示
        return cell
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
    // cellがタップされた時の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageSB = UIStoryboard(name: "ChatRoom", bundle: nil)
        let imageVC = imageSB.instantiateViewController(withIdentifier: "delete") as! PhotoPageContainerViewController
        imageVC.imageBotting = bottings[indexPath.row]
        
        userName = bottings[indexPath.row].userName
        profileImage = bottings[indexPath.row].profileImage
        textView = bottings[indexPath.row].textView
        postImage = bottings[indexPath.row].postImage
        heartCount = bottings[indexPath.row].heartCount
        performSegue(withIdentifier: "Image", sender: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Image" {
            let photoPageContainerViewController = segue.destination as! PhotoPageContainerViewController
            photoPageContainerViewController.ReflectUserName = userName
            photoPageContainerViewController.ReflectProfileImageView = profileImage
            photoPageContainerViewController.ReflectTextView = textView
            photoPageContainerViewController.ReflectPostImageView = postImage
            photoPageContainerViewController.ReflectHeartCount = heartCount
        }
    }
    
    
    
}


class BottingScoreCollectionViewCell: UICollectionViewCell {
    
    var botting: Bottings! {
        didSet {
            //  投稿画像
            if let url = URL(string: botting.postImage) {
                Nuke.loadImage(with: url, into: bottingPostHistoryImageView)
            }
        }
    }
    
    
    @IBOutlet weak var bottingPostHistoryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    
}
