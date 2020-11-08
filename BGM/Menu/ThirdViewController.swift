//
//  ThirdViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/03.
//

import UIKit
import XLPagerTabStrip

class ThirdViewController: UIViewController, IndicatorInfoProvider {

    //  Menu "ニュース"の変数
    var itemInfo: IndicatorInfo = "陰キャランキング"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }


}
