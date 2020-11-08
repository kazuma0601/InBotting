//
//  ManagementBlogViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/10.
//

import UIKit
import WebKit
import PKHUD

class ManagementBlogViewController: UIViewController {
    
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = NSURL(string: "https://www.tiktok.com/@yin_chara.inyo?lang=ja") {
            let request = NSURLRequest(url: url as URL)
            webView.load(request as URLRequest)
        }
       
        
        navigationItem.title = "運営ブログ"
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let managementBlogBackButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(tapmanagementBlog))
        navigationItem.leftBarButtonItem = managementBlogBackButton
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        
    }
    
    //  戻るボタンが押された時の処理
    @objc func tapmanagementBlog() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // HUDを表示
        HUD.show(.progress)
        // HUDを表示して指定時間後に非表示にする
        HUD.flash(.progress, delay: 1)
    }
    

}
