//
//  SignUpViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/06.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PKHUD


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyHeveAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageButton.layer.cornerRadius = 65
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        
        registerButton.layer.cornerRadius = 10
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        //  キーボードの色
        emailTextField.keyboardAppearance = .dark
        passwordTextField.keyboardAppearance = .dark
        usernameTextField.keyboardAppearance = .dark
        
        //  登録ボタンが押せない処理
        registerButton.isEnabled = false
        registerButton.backgroundColor = .rgb(red: 200, green: 200, blue: 200)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    //  既にアカウントをお持ちの方ボタンが押された時の処理
    @IBAction func tappedAlreadyHeveAccountButton(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(loginViewController, animated: true)
        
        
    }
    
    
    //  プロフィール画像ボタンが押された時の処理
    @IBAction func tappedProfileImageButton(_ sender: Any) {
        //  アルバム表示をする処理
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        //  写真及び、画像の拡大等可能にする処理
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    //  登録ボタンが押された時の処理
    @IBAction func tappedRegisterButtno(_ sender: Any) {
        //  画像を Storage に保存する処理
        guard let image = profileImageButton.imageView?.image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        
        HUD.show(.progress)
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firestorageへ情報の保存が失敗しました。\(err)")
                HUD.hide()
                return
            }
            print("Firestorageへ情報の保存が成功しました。")
            //  Firestorageから、ダウンロードする処理
            storageRef.downloadURL { (url, err) in
                if  let err = err {
                    print("Firestorageからのダウンロードに失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                //  Firestorageから、ダウンロードした url を String型に変換する処理
                guard let urlString = url?.absoluteString else { return }
                //  ユーザーの情報をデータベースを Firestore に保存する処理をまとめたメソッドを付け加える。
                self.createUserToFirestore(profileImageUrl: urlString)
            }
        }
        
        
    }
    //  ユーザーの情報をデータベースを Firestore に保存する処理をまとめたメソッド
    private func createUserToFirestore(profileImageUrl: String) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        //  ユーザーの情報(認証情報)を保存
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("認証情報の保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            print("認証情報の保存に成功しました。")
            //  ユーザーの情報(UID: ユーザー個別のID)データベースを保存
            guard let uid = res?.user.uid else { return }
            guard let username = self.usernameTextField.text else { return }
            let docData = [
                "email": email,
                "username": username,
                "createdAt": Timestamp(),
                "profileImageUrl": profileImageUrl  //Firestorageから、ダウンロードした url を String型に変換した後付け加える。(Firestoreに保存)
            ] as [String : Any]
            
            Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                if let err = err {
                    print("Firestoreへの保存に失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                print("Firestoreへの保存が成功しました。")
                HUD.hide()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //  タッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 画面(どこでも可)をタッチすればキーボードを閉じる
        self.view.endEditing(true)
    }
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //  アルバム表示して、写真及び、画像の追加ができる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //  もし、⬇︎の情報が nil ではなかったら...
        if let editImage = info[.editedImage] as? UIImage {
            //  大きさなど編集した写真及び、画像。
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let originalImage = info[.editedImage] as? UIImage {
            //  無編集の写真及び、画像。
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        //  丸枠綺麗に収まるように処理
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        
        //  元の画面に戻る(画面遷移)処理
        dismiss(animated: true, completion: nil)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    //  常にTextFieldの変化を受け取る処理
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //  ⬇︎これらが、全て nil だったら...      を定義。
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        //  もし、⬇︎これらが、全て nil だったら...
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            //  登録ボタンが押せない処理
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 200, green: 200, blue: 200)
        } else {
            //  登録ボタンが押せる処理
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 0, green: 0, blue: 0)
        }
    }
}
