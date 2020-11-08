//
//  ChatRoom.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/08.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ChatRoom {
    
    let latestMessageId: String
    let members: [String]
    let createdAt: Timestamp
    
    var latestMessage: Message?
    var documentId: String?
    var partnerUser: User?
    
    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
