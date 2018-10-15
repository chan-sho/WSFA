//
//  SubViewController.swift
//  WSFA
//
//  Created by 高野翔 on 2018/10/13.
//  Copyright © 2018 高野翔. All rights reserved.
//

import UIKit
import SceneKit
import SVProgressHUD

class SubTableViewController: UITableViewController {
    
    @IBOutlet weak var StrageResults: UIBarButtonItem!
    
    // 解析結果はAppDelegateの変数に入っている
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    /// セルの数を返す
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate.analyzedFaces.count
    }
    
    /// セルの項目をセット
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = self.appDelegate.analyzedFaces[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultTableViewCell
        cell.setData(data: result)
        return cell
    }
    
    
    @IBAction func StrageResults(_ sender: Any) {
        //コンテキスト開始
        UIGraphicsBeginImageContextWithOptions(CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), false, 0.0)
        //viewを書き出す
        self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        // imageにコンテキストの内容を書き出す
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        //コンテキストを閉じる
        UIGraphicsEndImageContext()
        // imageをカメラロールに保存
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        SVProgressHUD.showSuccess(withStatus: "フォトライブラリに\n追加されました！")
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.sectionHeaderHeight = CGFloat(25.0)
        
        let headerView = UITableViewHeaderFooterView()
        headerView.backgroundColor = UIColor.lightGray
        headerView.textLabel?.text = "顔解析の結果発表〜！！"
        headerView.textLabel?.textColor = UIColor.white
        headerView.textLabel?.textAlignment = NSTextAlignment.center
        
        return headerView
    }
    
    
}
