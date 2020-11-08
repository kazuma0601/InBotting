//
//  ZeroViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/05.
//

//import UIKit
//import XLPagerTabStrip
//
//class ZeroViewController: ButtonBarPagerTabStripViewController {
//
//    override func viewDidLoad() {
//        //  Menuデザイン設定
//        self.loadDesign()
//
//        super.viewDidLoad()
//
//
//
//    }
//
//
//    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
//        let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ぼっちんぐ")
//        let secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "おすすめ陰キャ")
////        let thirdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "陰キャランキング")
//        let ChildViewControllers:[UIViewController] = [firstVC, secondVC]
//
//        return ChildViewControllers
//    }
//
//    //  デザイン設定
//    func loadDesign() {
//
////        self.settings.style.selectedBarBackgroundColor = UIColor.black
//        self.settings.style.buttonBarBackgroundColor = .black
//        self.settings.style.buttonBarItemBackgroundColor = .rgb(red: 0, green: 0, blue: 116)
//        self.settings.style.selectedBarBackgroundColor = .white
//        self.settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 16)
//        self.settings.style.selectedBarHeight = 4.0      //  スライドする下線の太さ細さ調整
//        self.settings.style.buttonBarMinimumLineSpacing = 0
//        self.settings.style.buttonBarItemTitleColor = .white
//        self.settings.style.buttonBarItemsShouldFillAvailableWidth = true
//        //  セレクトバーの全体幅(左)の調整
//        self.settings.style.buttonBarLeftContentInset = 0
//        //  セレクトバーの全体幅(右)の調整
//        self.settings.style.buttonBarRightContentInset = -20
//
//        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?,ProgressReporting: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
//            //  選択された時の変色
//            guard changeCurrentIndex == true else { return }
//            oldCell?.label.textColor = UIColor.gray
//            newCell?.label.textColor = UIColor.white
//
//        }
//
//    }
//
//}
