//
//  FollowerScoreViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/27.
//

//import UIKit
//import XLPagerTabStrip
//
//class FollowerScoreViewController: UIViewController, IndicatorInfoProvider {
//
//
//    @IBOutlet weak var followerTableView: UITableView!
//
//    private let followerCell = "followerCell"
//
//    //  Menu "ニュース"の変数
//    var itemInfo: IndicatorInfo = "フォロワー"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        followerTableView.delegate = self
//        followerTableView.dataSource = self
//
//    }
//
//    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
//        return itemInfo
//    }
//
//}
//
//extension FollowerScoreViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 86
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = followerTableView.dequeueReusableCell(withIdentifier: followerCell, for: indexPath) as! FollowerScoreTableViewCell
//
//        return cell
//    }
//
//
//
//
//}
//
//class FollowerScoreTableViewCell: UITableViewCell {
//
//
//    @IBOutlet weak var followerProfileImageView: UIImageView!
//    @IBOutlet weak var followerNameLabel: UILabel!
//    @IBOutlet weak var followerTextView: UITextView!
//
//
//
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        followerProfileImageView.layer.cornerRadius = 30
//
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//}
