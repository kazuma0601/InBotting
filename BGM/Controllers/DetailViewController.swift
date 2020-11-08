//
//  DetailViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/21.
//
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import Nuke

class DetailViewController: UIViewController, UITextViewDelegate {
    
    
    var bottingcomments: Bottings?
    var user: User?
    
    private let cellId = "cellId"
    private var comments = [Comments]()
    
    private lazy var commentInputAccessoryView: CommentInputAccessoryView = {
        let view = CommentInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    
    @IBOutlet weak var commentTableView: UITableView!

    //  ライク・ハートボタンを押したか押してないかを判断する変数
    var likeTapFlag = false
    var heartTapFlag = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        //  キーボードを手動で閉じる処理
        commentTableView.keyboardDismissMode = .interactive
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .dark
        
        // 自分の user 情報
        fetchCommentMessageViewInfo()
        // 既にコメント追加されているコメントを取得
        fetchCommentMessages()
        //  コメントナビゲーション
        commentNavigationBar()
        
    }
    //  コメントナビゲーション
    private func commentNavigationBar() {
        navigationItem.title = "コメント"
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let postBackButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(commentTaped))
        navigationItem.rightBarButtonItem = postBackButton
//        navigationItem.leftBarButtonItem?.tintColor =
    }
    
    @objc func commentTaped() {
        dismiss(animated: true, completion: nil)
    }
    
    
    // 自分の user 情報の取得をする処理メソッド
    private func fetchCommentMessageViewInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            
            let user = User(dic: dic)
            self.user = user
        }
    }
    
    
    override var inputAccessoryView: UIView? {
        get {
            return commentInputAccessoryView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }

    
    //  既にコメント追加されているコメントを取得する処理
    //  既にコメント追加されているコメントを残す処理
    private func fetchCommentMessages() {
        guard let commentDocID = bottingcomments?.documentId else { return }
        
        Firestore.firestore().collection("Bottings").document(commentDocID).collection("commentMessages").addSnapshotListener { (snapshots, err) in
            if let err = err {
                print("メーセージ情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let comment = Comments(dic: dic)
                    comment.documentsId = documentChange.document.documentID
                    
                    self.comments.insert(comment, at: 0)
                    self.commentTableView.reloadData()
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
    
    
    
}

//  コメント欄に入力したコメントメーセージ情報の保存
extension DetailViewController: CommentInputAccessoryViewDelegate {
    func tappedSendCommentButton(text: String) {
        guard let commentDocID = bottingcomments?.documentId else { return }
        guard let name = user?.username else { return }
        guard let profileImageView = user?.profileImageUrl else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        commentInputAccessoryView.removeText()
        
        let docData = [
            "name": name,
            "profileImage": profileImageView,
            "messageText": text,
            "uid": uid,
            "heartCount": Int()
        ] as [String : Any]
        Firestore.firestore().collection("Bottings").document(commentDocID).collection("commentMessages").document().setData(docData) { (err) in
            if let err = err {
                print("メーセージ情報の保存に失敗しました。\(err)")
                return
            }
            print("メーセージ情報の保存に成功しました。")
        }
    }
    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    //  cellの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DetailTableViewCell
        cell.comment = comments[indexPath.row]  //Bottings情報のドキュメント取得(ハートカウント機能)
        
        cell.detailcomment = comments[indexPath.row]
        
        return cell
    }
    
}

class DetailTableViewCell: UITableViewCell, UITextViewDelegate {
    
    //  ハートカウント機能
    var detailcomment: Comments?
    var bottingcomment: Bottings?
    
    @IBOutlet weak var commentProfileImageView: UIImageView!
    @IBOutlet weak var commentUserNameLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentHeartCountLabel: UILabel!
    @IBOutlet weak var commentHeartButton: UIButton!
    
    //  ライク・ハートボタンを押したか押してないかを判断する変数
    var heartTapFlag = false
    
    var comment: Comments! {
        didSet {
            //  ユーザー名
            commentUserNameLabel.text = comment.name
            //  プロフィール画像を認識し、反映。
            if let url = URL(string: comment.profileImage) {
                Nuke.loadImage(with: url, into: commentProfileImageView)
            }
            //  コメント
            commentTextView.text = comment.messageText
            //  ハートカウント
            commentHeartCountLabel.text = "\(comment.heartCount)"
            //  ライクボタン・ハートボタンが押されてない状態の場合...
            if heartTapFlag == false {
                //  ノーマルカラー
                commentHeartButton.tintColor = .lightGray
                commentHeartButton.setImage(UIImage(systemName: "heart"), for: .normal)
                
            }else if comment.heartCount == 0 && heartTapFlag == true {
                //  更新時、heartTapFlag が true の状態のままなので一度 false に戻してあげる。
                heartTapFlag = false
                commentHeartButton.tintColor = .lightGray
                commentHeartButton.setImage(UIImage(systemName: "heart"), for: .normal)
                
            }else if comment.heartCount == 0 && heartTapFlag == false {
                //  更新時、Heartボタンを押してなかった場合...
                commentHeartButton.tintColor = .lightGray
                commentHeartButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commentTextView.delegate = self
        commentProfileImageView.layer.cornerRadius = 20
        
        commentHeartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        commentHeartButton.tintColor = .lightGray
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    //  ハートボタンが押された時の処理
    @IBAction func commentHeartButtonTap(_ sender: Any) {
        if Auth.auth().currentUser?.uid != nil {
            if heartTapFlag == false{
                comment.plusComentHeart()
                commentHeartCountLabel.text = "\(comment.heartCount)"
                commentHeartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//                plusComentsHeart()  //プラスカウント更新
                commentHeartButton.tintColor = .red
                heartTapFlag = true
                
            }else if heartTapFlag == true{
                comment.minusComentHeart()
                //  再びハートボタンを押した時は 1 減らす。
                commentHeartCountLabel.text = "\(comment.heartCount)"
                commentHeartButton.setImage(UIImage(systemName: "heart"), for: .normal)
//                minusComentsHeart()  //マイナスカウント更新
                commentHeartButton.tintColor = .white
                heartTapFlag = false
            }
        }else{
            if heartTapFlag == false{
                comment.plusComentHeart()
                commentHeartCountLabel.text = "\(comment.heartCount)"
                commentHeartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//                plusComentsHeart()  //プラスカウント更新
                commentHeartButton.tintColor = .red
                heartTapFlag = true
                
            }else if heartTapFlag == true{
                comment.minusComentHeart()
                //  再びハートボタンを押した時は 1 減らす。
                commentHeartCountLabel.text = "\(comment.heartCount)"
                commentHeartButton.setImage(UIImage(systemName: "heart"), for: .normal)
//                minusComentsHeart()  //マイナスカウント更新
                commentHeartButton.tintColor = .white
                heartTapFlag = false
            }
        }
        
    }
    

    
    //  ハートボタンのプラスカウントメソッド
//    private func plusComentsHeart() {
//        guard let commentsDocData = bottingcomment?.documentUid else { return }
//        guard let commentsData = detailcomment?.documentsId else { return }
//        let upHeartData = ([
//            "heartCount": FieldValue.increment(Int64(1))
//        ])
//        Firestore.firestore().collection("Bottings").document(commentsDocData).collection("commentMessages").document(commentsData).updateData(upHeartData) { (err) in
//            if let err = err {
//                print("ハートボタンのプラスカウント更新に失敗しました。\(err)")
//                return
//            }
//            print("ハートボタンのプラスカウント更新に成功しました。")
//        }
//    }
//    //  ハートボタンのマイナスカウントメソッド
//    private func minusComentsHeart() {
//        guard let commentsDocData = bottingcomment?.documentUid else { return }
//        guard let commentsData = detailcomment?.documentsId else { return }
//        let upHeartData = ([
//            "heartCount": FieldValue.increment(Int64(-1))
//        ])
//        Firestore.firestore().collection("Bottings").document(commentsDocData).collection("commentMessages").document(commentsData).updateData(upHeartData) { (err) in
//            if let err = err {
//                print("ハートボタンのマイナスカウント更新に失敗しました。\(err)")
//                return
//            }
//            print("ハートボタンのマイナスカウント更新に成功しました。")
//        }
//    }
    
    
}
