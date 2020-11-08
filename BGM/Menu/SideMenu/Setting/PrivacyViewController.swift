//
//  PrivacyViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/10.
//

import UIKit

class PrivacyViewController: UIViewController {

    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.title = "プライバシー設定"
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let privacyBackButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(tapprivacy))
        navigationItem.leftBarButtonItem = privacyBackButton
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        
    }
    
    //  戻るボタンが押された時の処理
    @objc func tapprivacy() {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
