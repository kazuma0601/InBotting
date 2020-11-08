//
//  Bottings.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class Bottings {
    
    var userName: String
    var profileImage: String
    var textView: String
    var postImage: String
    let myUser: [String]     //  ぼっちング投稿者のUID( [String]にすることで識別ができる)
    let createdAt: Timestamp
    var heartCount = 0
    var commentCount = 0
    
    var documentId: String?
    var documentUid: String?
    
    init(dic: [String: Any]) {
        self.userName = dic["userName"] as? String ?? ""
        self.profileImage = dic["profileImage"] as? String ?? ""
        self.textView = dic["textView"] as? String ?? ""
        self.postImage = dic["postImage"] as? String ?? ""
        self.myUser = dic ["myUser"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.heartCount = dic["heartCount"] as? Int ?? Int()
        self.commentCount = dic["commentCount"] as? Int ?? Int()
    }
}
extension Bottings {
    func plusCC() {
        
        commentCount += 1
    }
    func plusHH() {
        
        heartCount += 1
    }
    
    func minusCC() {
        commentCount -= 1
    }
    
    func minusHH() {
        heartCount -= 1
    }
}
