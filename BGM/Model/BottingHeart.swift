//
//  BottingHeart.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/11/02.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class BottingHeart {
    
    var userName: String
    var profileImage: String
    var textView: String
    var postImage: String
    let myUser: [String]     //  ぼっちング投稿者のUID( [String]にすることで識別ができる)
    var heartCount = 0
    var commentCount = 0
    
    var Uid: String?
    
    init(dic: [String: Any]) {
        self.userName = dic["userName"] as? String ?? ""
        self.profileImage = dic["profileImage"] as? String ?? ""
        self.textView = dic["textView"] as? String ?? ""
        self.postImage = dic["postImage"] as? String ?? ""
        self.myUser = dic ["myUser"] as? [String] ?? [String]()
        self.heartCount = dic["heartCount"] as? Int ?? Int()
        self.commentCount = dic["commentCount"] as? Int ?? Int()
    }
}
extension BottingHeart {
    func plusBottingHeartComments() {
        
        commentCount += 1
    }
    func plusBottingHeartHearts() {
        
        heartCount += 1
    }
    
    func minusBottingHeartComments() {
        commentCount -= 1
    }
    
    func minusBottingHeartHearts() {
        heartCount -= 1
    }
}

