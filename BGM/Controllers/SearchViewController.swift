//
//  SearchViewController.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/05.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    
    
    //  データ
//    let data = ["Apples", "Orenge", "Pear", "Banas", "Plum"]
    let data = [""]
    //
    var filtereData: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        
        filtereData = data
        
        searchBar.tintColor = .white
        searchBar.layer.cornerRadius = 16
        searchBar.showsCancelButton = true
        
        //  画面表示時にキーボードが自動的に出る処理
        self.searchBar.becomeFirstResponder()
        
    }
    
    
    
    // MARK: - Table view data source
    //  cell の数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtereData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = filtereData[indexPath.row]
        
        return cell
    }
    
    
    
    // MARK: - SearchBar
    
    // キャンセルボタンが押されたらキャンセルボタンを無効にしてフォーカスを外す
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //  戻る処理
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    //  検索テキストが変更された時、検索文字列が空であれば..
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtereData = []
        
        if searchText == "" {
            filtereData = data
        }else{
            //  for 変数 in 開始値 ..< 終了値 {  繰り返し文
            for fruit in data {
                //  大文字小文字を区別せずに判定。　　　　　　　⬇︎検索したい文字
                if fruit.lowercased().contains(searchText.lowercased()) {
                    //  追加される
                    filtereData.append(fruit)
                }
            }
            
            self.searchTableView.reloadData()
        }
        
    }
}
    

