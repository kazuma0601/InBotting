//
//  ContactUsViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/10.
//

import UIKit

class ContactUsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.title = "お問い合わせ"
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let contactBackButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(tapcontactBackButton))
        navigationItem.leftBarButtonItem = contactBackButton
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    //  戻るボタンが押された時の処理
    @objc func tapcontactBackButton() {
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
