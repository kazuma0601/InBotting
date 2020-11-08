//
//  LoginViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/10.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PKHUD

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 8
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        //  キーボードの色
        emailTextField.keyboardAppearance = .dark
        passwordTextField.keyboardAppearance = .dark
        
    }
    
    
    //  ログインボタンを押した時の処理
    @IBAction func tappedLoginButton(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        HUD.show(.progress)
        
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("ログインに失敗しました。\(err)")
                HUD.hide()
                return
            }
            HUD.hide()
            print("ログインに成功しました。")
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    //  まだアカウントをお持ちでない方ボタンを押した時の処理
    @IBAction func tappedDontHaveAccountButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    //  タッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 画面(どこでも可)をタッチすればキーボードを閉じる
        self.view.endEditing(true)
        
    }
    
    
}
