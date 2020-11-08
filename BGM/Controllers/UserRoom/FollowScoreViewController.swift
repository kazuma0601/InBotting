//
//  FollowScoreViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/27.
//

//import UIKit
//import XLPagerTabStrip
//import FirebaseFirestore
//import FirebaseAuth
//import FirebaseStorage
//import Nuke
//
//class FollowScoreViewController: UIViewController, IndicatorInfoProvider {
//
//    //  Menu "ニュース"の変数
//    var itemInfo: IndicatorInfo = "フォロー"
//    
//    private let followCell = "followCell"
//    
//    
//    @IBOutlet weak var followTableView: UITableView!
//    
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        followTableView.delegate = self
//        followTableView.dataSource = self
//        
//    }
//    
//    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
//        return itemInfo
//    }
//
//}
//
//
//extension FollowScoreViewController: UITableViewDelegate, UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 86
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 50
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = followTableView.dequeueReusableCell(withIdentifier: followCell, for: indexPath) as! FollowScoreTableViewCell
//        return cell
//    }
//    
//    
//}
//
//class FollowScoreTableViewCell: UITableViewCell {
//    
//    
//    @IBOutlet weak var followProfileImageView: UIImageView!
//    @IBOutlet weak var followUserNameLabel: UILabel!
//    @IBOutlet weak var followTextView: UITextView!
//    
//    
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        followProfileImageView.layer.cornerRadius = 30
//        
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//}
