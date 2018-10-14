//
//  ApiService.swift
//  WSFA
//
//  Created by 高野翔 on 2018/10/13.
//  Copyright © 2018 高野翔. All rights reserved.
//

import UIKit
import VisualRecognition

/// Watson VR APIを扱うクラス
class ApiService {
    
    /// API連携
    ///
    /// - Parameter image: 解析対象画像イメージ
    func callApi(image: UIImage, completionHandler: @escaping () -> Void) {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let APIKey = fetchApiKey() else {
            print("API Key取得エラー")
            fatalError()
        }
        
        
        guard let resizedImage = image.fixedOrientation()?.resizeImage(maxSize: 2097152) else {
            print("画像リサイズエラー")
            fatalError()
        }
        
        let visualRecognition = VisualRecognition(version: "2018-03-19", apiKey: APIKey)
        
        visualRecognition.detectFaces(image: resizedImage, failure: {error in
            print(error)
            fatalError()
        }, success: {(detectedFaces: DetectedFaces) in
            print(["imagesProcessed:",detectedFaces.imagesProcessed])
            print(["images:",detectedFaces.images])
            let faceData = detectedFaces
            appDelegate.analyzedFaces = self.interpret(image: resizedImage, parsedData: faceData)
            completionHandler();
        })
    }
    
    /// 解析結果のJSONを解釈してAnalyzedFace型の配列で返す
    ///
    /// - parameter image: 元画像
    /// - parameter parsedData: パース後データ
    /// - returns: AnalyzedFace型の配列
    private func interpret(image: UIImage, parsedData: DetectedFaces) -> [AnalyzedFace] {
        let parsedFaces = parsedData.images[0].faces
        // レスポンスのimageFaces要素は配列となっている（複数人が映った画像の解析が可能）。それを抽出しながらAnalyzedFace型の配列に変換する
        return parsedFaces.map {
            let analyzedFace = AnalyzedFace()
            // 性別およびスコア
            if $0.gender!.gender == "MALE" {
                analyzedFace.gender = "男性"
            } else {
                analyzedFace.gender = "女性"
            }
            analyzedFace.genderScore = String(floor($0.gender!.score! * 1000) / 10)
            // 年齢およびスコア
            analyzedFace.ageMin = String($0.age!.min!)
            if let max = $0.age!.max {
                analyzedFace.ageMax = String(max)
            }
            analyzedFace.ageScore = String(floor($0.age!.score! * 1000) / 10)
            // Identity
            if let identity = $0.identity?.name {
                analyzedFace.identity = identity
            }
            let left = $0.faceLocation!.left
            let top = $0.faceLocation!.top
            let width = $0.faceLocation!.width
            let height = $0.faceLocation!.height
            // 元画像から切り抜いて変数にセット
            analyzedFace.image = cropping(image: image, left: CGFloat(left), top: CGFloat(top), width: CGFloat(width), height: CGFloat(height))
            // 抽出完了
            return analyzedFace
        }
    }
    
    /// 元画像から矩形を切り抜く
    ///
    /// - parameter image: 元画像
    /// - parameter left: x座標
    /// - parameter top: y座標
    /// - parameter width: 幅
    /// - parameter height: 高さ
    /// - returns: UIImage
    private func cropping(image: UIImage, left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) -> UIImage? {
        let imgRef = image.cgImage?.cropping(to: CGRect(x: left, y: top, width: width, height: height))
        return UIImage(cgImage: imgRef!, scale: image.scale, orientation: image.imageOrientation)
    }
    
    /// plistからWatson VRのAPIキーを取得する
    ///
    /// - Returns: APIキーの文字列
    private func fetchApiKey() -> String? {
        // API Keyをapikey.plistに設定しておく必要があります。キー名は"apikey"
        guard let keyFilePath = Bundle.main.path(forResource: "apikey", ofType: "plist") else {
            return nil
        }
        guard let keys = NSDictionary(contentsOfFile: keyFilePath) else {
            return nil
        }
        print("API Keyテェック＝ \(String(describing: keys["apikey"]!))")
        
        return keys["apikey"] as? String
    }
    
}

