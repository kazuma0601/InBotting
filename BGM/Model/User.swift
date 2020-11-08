//
//  User.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/07.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class User {
    
    let email: String
    let username: String
    let createdAt: Timestamp
    let profileImageUrl: String
    let profilecomment: String
    let percent: Int
    let backgroundProfileImageUrl: String
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.profilecomment = dic["profilecomment"] as? String ?? ""
        self.percent = dic["percent"] as? Int ?? Int()
        self.backgroundProfileImageUrl = dic["backgroundProfileImageUrl"] as? String ?? ""
    }
    
}
