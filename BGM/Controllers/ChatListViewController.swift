//
//  ChatListViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/06.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Nuke
import PKHUD

class ChatListViewController: UIViewController {
    
    //  cell のID
    private let cellId = "cellId"
    private var chatrooms = [ChatRoom]()
    
    //  自分のユーザー情報の変数
    private var user: User? {
        didSet {
//            navigationController?.navigationItem.title = user?.username
        }
    }
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // HUDを表示
        HUD.show(.progress)
        // HUDを表示して指定時間後に非表示にする
        HUD.flash(.progress, delay: 0.2)
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .dark
        //  リロード
        chatListTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        
        chatListTableView.tableFooterView = UIView()
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        //  現在ログインしている MyユーザーのUIDを取得して表示。
        fetchLoginUserInfo()
        
        // ChatRooms 情報の取得をして表示させる処理
        fetchChatroomsInfoFromFirestore()
        
    }
    
    //  リロード処理
    @objc func refresh(sender: UIRefreshControl) {
        // ここに通信処理などデータフェッチの処理を書く
        self.chatListTableView.reloadData()
        // データフェッチが終わったらUIRefreshControl.endRefreshing()を呼ぶ必要がある
        sender.endRefreshing()
    }
    
    // ChatRooms 情報の取得をする処理メソッド (リアルタイム)
    private func fetchChatroomsInfoFromFirestore() {
        //                                 ⬇︎ 誤字注意！(間違えやすい)
        Firestore.firestore().collection("chatRooms")
            .addSnapshotListener { (snapshots, err) in
                if let err = err {
                    print("ChatRooms情報の取得に失敗しました。\(err)")
                    return
                }
                snapshots?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                    case .modified, .removed:
                        print("nothing to do")
                    }
                })
            }
    }
    
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let dic = documentChange.document.data()
        let chatroom = ChatRoom(dic: dic)
        chatroom.documentId = documentChange.document.documentID
        //  現在ログインしている MyユーザーのUIDを取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let isConain = chatroom.members.contains(uid)
        
        if !isConain { return }  //  ⬆︎に含まれない時は⬇︎の処理は行わない。
        
        chatroom.members.forEach { (memberUid) in
            if memberUid != uid {    //  もし、このUID(ユーザー情報)が現在ログインしてるUID(ユーザー情報)と同じだった場合は取得しない。
                Firestore.firestore().collection("users").document(memberUid).getDocument { (userSnapshot, err) in
                    if let err = err {
                        print("ユーザー情報の取得に失敗しました。\(err)")
                        return
                    }
                    //  違った場合は取得する。
                    guard let dic = userSnapshot?.data() else { return }
                    let user = User(dic: dic)
                    user.uid = documentChange.document.documentID
                    chatroom.partnerUser = user
                    //  最新情報(メッセージやり取りの最後のメッセージ)の取得処理
                    guard let chatroomId = chatroom.documentId else { return }
                    let latestMessageId = chatroom.latestMessageId
                    //  最新情報(メッセージやり取りの最後のメッセージ)が存在しなかったら..
                    if latestMessageId == "" {
                        self.chatrooms.append(chatroom)
                        self.chatListTableView.reloadData()
                        return
                    }
                    
                    Firestore.firestore().collection("chatRooms").document(chatroomId).collection("messages").document(latestMessageId).getDocument { (messageSnapshot, err) in
                        if let err = err {
                            print("最新情報の取得に失敗しました。\(err)")
                            return
                        }
                        guard let dic = messageSnapshot?.data() else { return }
                        let message = Message(dic: dic)
                        chatroom.latestMessage = message
                        
                        self.chatrooms.append(chatroom)
                        self.chatListTableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    //  現在ログインしているユーザーのUIDを取得するメソッド
    private func fetchLoginUserInfo() {
        //  現在ログインしている MyユーザーのUIDを取得
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
    
    
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    //  cell の高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    //  cell  の数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    //  cell の値
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        cell.chatroom = chatrooms[indexPath.row]
        //これでセルをタップ時、色は変化しなくなる
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    //  cell がタップされた時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  チャットルームへ画面遷移
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.user = user
        chatRoomViewController.chatroom = chatrooms[indexPath.row]
        navigationController?.pushViewController(chatRoomViewController, animated: true)
        //  画面遷移時にTabBarを隠す処理
//        self.tabBarController?.tabBar.isHidden = true
//        self.tabBarController?.hidesBottomBarWhenPushed = true
        
    }
    //  画面遷移時(戻ってきた時)にTabBarを出す処理
    override func viewWillAppear(_ animated: Bool) {
//        self.tabBarController?.tabBar.isHidden = false
        
        
    }
    
}


class ChatListTableViewCell: UITableViewCell {
    // ChatRooms 情報の取得をして表示させる処理
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom {
                //  名前の表示
                partnerLabel.text = chatroom.partnerUser?.username
                //  画像(アイコン)の表示
                guard let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else { return }
                Nuke.loadImage(with: url, into: userImageView)
                //  時間の表示
                dateLabel.text = dateFormatterForDateLabel(date: chatroom.latestMessage?.createdAt.dateValue() ?? Date())
                //  最新情報(メッセージやり取りの最後のメッセージ)の表示
                latestMessageLabel.text = chatroom.latestMessage?.message
            }
        }
    }
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 25
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    //  ①日付、時間表示を設定メソッド
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
        
    }
    
}
