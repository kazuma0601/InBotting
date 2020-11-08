//
//  userListViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/08.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Nuke

class UserListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?
    
    
    @IBOutlet weak var startChatButton: UIButton!
    @IBOutlet weak var userListTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        userListTableView.delegate = self
        userListTableView.dataSource = self
        userListTableView.tableFooterView = UIView()
        startChatButton.layer.cornerRadius = 16
        startChatButton.isEnabled = false
        startChatButton.backgroundColor = .rgb(red: 0, green: 0, blue: 100)
        startChatButton.tintColor = .white
        
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        //  情報の取得を表示する処理
        fetchUserInfoFromFirestore()
        
        
        
        
    }
    
    //  user 情報の取得をする処理メソッド
    private func fetchUserInfoFromFirestore() {
        Firestore.firestore().collection("users").getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                user.uid = snapshot.documentID
                
                //  現在ログインしているユーザーのUIDを取得
                guard let uid = Auth.auth().currentUser?.uid else { return }
                //  もし、⬇︎このUID(ユーザー情報)が現在ログインしてるUID(ユーザー情報)と同じだったら追加しない..
                if uid == snapshot.documentID {
                    return
                }
                //  違った場合はユーザーリストに追加する
                self.users.append(user)
                self.userListTableView.reloadData()
            })
        }
    }
    
    //  選択ボタンが押された時の処理
    @IBAction func startChatAction(_ sender: Any) {
        print("hhhhh")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUser?.uid else { return }
        let members = [uid, partnerUid]
        
        let docData = [
            "members": members,
            "latestMessageId": "",
            "createdAt": Timestamp()
        ] as [String : Any]
        
        
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (err) in
            if let err = err {
                print("ChatRoom情報の保存に失敗しました。\(err)")
                return
            }
            self.dismiss(animated: true, completion: nil)
            print("ChatRoom情報の保存に成功しました。")
        }
    }
    
    
    
    
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count       //  登録しているユーザーの数だけ表示
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        //  ユーザーの情報を渡す。
        cell.user = users[indexPath.row]        //  登録しているユーザーの数だけ表示
        
        return cell
    }
    //  cell が押された特の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startChatButton.isEnabled = true
        startChatButton.backgroundColor = .rgb(red: 0, green: 0, blue: 250)
        let user = users[indexPath.row]
        self.selectedUser = user
    }
    
    
    
}
class UserListTableViewCell: UITableViewCell {
    
    var user: User? {
        didSet {
            userListLabel.text = user?.username
            
            //  画像を認識し、反映。
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: userListImageView)
            }
        }
    }
    
    @IBOutlet weak var userListImageView: UIImageView!
    @IBOutlet weak var userListLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userListImageView.layer.cornerRadius = 30
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
}
