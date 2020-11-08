//
//  Comments.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class Comments {
    let name: String
    let profileImage: String
    let messageText: String
    let uid: String
    var heartCount = 0
    
    var documentsId: String?
    
    init(dic: [String : Any]) {
        self.name = dic["name"] as? String ?? ""
        self.profileImage = dic["profileImage"] as? String ?? ""
        self.messageText = dic["messageText"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.heartCount = dic["heartCount"] as? Int ?? Int()
        }
}
extension Comments {
    func plusComentHeart() {
        heartCount += 1
    }

    func minusComentHeart() {
        heartCount -= 1
    }
}
