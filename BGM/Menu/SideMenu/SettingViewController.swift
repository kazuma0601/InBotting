//
//  SettingViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/09.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Nuke

class SettingViewController: UIViewController {
    
    private let cellId = "cellId"
    
    private let setting = [
        ["プロフィール設定", "プライバシー設定", "背景画像設定", "利用規約", "プライバシーポリシー", "運営のアカウント", "運営ブログ", "お問い合わせ"]
    ]
    
    
    @IBOutlet weak var settingTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.backgroundColor = .black
//        settingTableView.separatorColor = .white
        settingTableView.isScrollEnabled = false
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
    }
    
    //  ログアウトボタンを押した時の処理
    @IBAction func tappedLogoutButton(_ sender: Any) {
        //アラート(ログアウト)
        showAlert()
        
    }
    //  アラート(ログアウト)
    func showAlert() {
        //  アラートテキスト
        let alert = UIAlertController(title: "本当にログアウトしますか？", message: "", preferredStyle: .alert)
        //  キャンセルした場合
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { action in
        }))
        //  続行した場合
        alert.addAction(UIAlertAction(title: "続行", style: .destructive, handler: { action in
            //  ログアウト処理
            do {
                try Auth.auth().signOut()
                let signUpVC = UIStoryboard(name: "SignUp", bundle: nil)
                let signUpViewController = signUpVC.instantiateViewController(withIdentifier: "SignUpViewController")
                let nav = UINavigationController(rootViewController: signUpViewController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            } catch {
                print("ログアウトに失敗しました。\(error)")
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return setting.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.backgroundColor = UIColor.black
        label.textColor = UIColor.black
        label.font = .boldSystemFont(ofSize: 15)


        return label
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setting[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.backgroundColor = .white
        cell.textLabel?.text = setting[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let profileSettingVC = UIStoryboard(name: "Setting", bundle: nil)
            let profileSetting = profileSettingVC.instantiateViewController(withIdentifier: "ProfileSettingViewController")
            let nav = UINavigationController(rootViewController: profileSetting)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        }else if indexPath.row == 1{
            let PrivacyVC = UIStoryboard(name: "Setting", bundle: nil)
            let Privacy = PrivacyVC.instantiateViewController(withIdentifier: "PrivacyViewController")
            let nav = UINavigationController(rootViewController: Privacy)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        }else if indexPath.row == 2{
            let BlockAccountVC = UIStoryboard(name: "Setting", bundle: nil)
            let blockAccount = BlockAccountVC.instantiateViewController(withIdentifier: "BlockAccountViewController")
            let nav = UINavigationController(rootViewController: blockAccount)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        }else if indexPath.row == 3{
            let TermsOfServiceVC = UIStoryboard(name: "Setting", bundle: nil)
            let TermsOfService = TermsOfServiceVC.instantiateViewController(withIdentifier: "TermsOfServiceViewController")
            let nav = UINavigationController(rootViewController: TermsOfService)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        }else if indexPath.row == 4{
            let PrivacyPolicyVC = UIStoryboard(name: "Setting", bundle: nil)
            let PrivacyPolicy = PrivacyPolicyVC.instantiateViewController(withIdentifier: "PrivacyPolicyViewController")
            let nav = UINavigationController(rootViewController: PrivacyPolicy)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        }else if indexPath.row == 5{
            let OperatingAccountVC = UIStoryboard(name: "Setting", bundle: nil)
            let OperatingAccount = OperatingAccountVC.instantiateViewController(withIdentifier: "OperatingAccountViewController")
            let nav = UINavigationController(rootViewController: OperatingAccount)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        }else if indexPath.row == 6{
            let ManagementBlogVC = UIStoryboard(name: "Setting", bundle: nil)
            let ManagementBlog = ManagementBlogVC.instantiateViewController(withIdentifier: "ManagementBlogViewController")
            let nav = UINavigationController(rootViewController: ManagementBlog)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        }else if indexPath.row == 7{
            let ContactUsVC = UIStoryboard(name: "Setting", bundle: nil)
            let ContactUs = ContactUsVC.instantiateViewController(withIdentifier: "ContactUsViewController")
            let nav = UINavigationController(rootViewController: ContactUs)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        }
        
    }
}

class SettingTableViewCell: UITableViewCell {
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setEditing(selected, animated: true)
        
        
    }
}
