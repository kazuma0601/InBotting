//
//  TimeLines.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/18.
//

import Foundation
import Firebase
import FirebaseDatabase

class TimeLines {
    var username: String = ""
    var profileImage: String = ""
    var textView: String = ""
    var uid: String = ""
    var commentCount = 0
    var heartCount = 0
    let postRef: DatabaseReference!
    
    init(username: String, profileImage: String, uid: String, textView: String, commentCount: Int, heartCount: Int) {
        self.username = username
        self.profileImage = profileImage
        self.textView = textView
        self.uid = uid
        self.commentCount = commentCount
        self.heartCount = heartCount
        postRef = Database.database().reference().child("timeLines").childByAutoId()
    }
    
    
    init(snapshop: DataSnapshot) {
        postRef = snapshop.ref
        if let value = snapshop.value as? [String : Any] {
            username = value["username"] as! String
            profileImage = value["profileImage"] as! String
            uid = value["uid"] as! String
            textView = value["textView"] as! String
            commentCount = value["commentCount"] as! Int
            heartCount = value["heartCount"] as! Int
        }
    }
}

extension TimeLines {
    func plusComment() {
        
        commentCount += 1
        postRef.child("commentCount").setValue(commentCount)
    }
    func plusHeart() {
        
        heartCount += 1
        postRef.child("heartCount").setValue(heartCount)
    }
    
    func minusComment() {
        commentCount -= 1
        postRef.child("commentCount").setValue(commentCount)
    }
    
    func minusHeart() {
        heartCount -= 1
        postRef.child("heartCount").setValue(heartCount)
    }
}
