//
//  FirstViewController.swift
//  datar
//
//  Created by va2ron1 on 7/25/19.
//  Copyright © 2019 va2ron1. All rights reserved.
//

import UIKit

struct SubmitResponseData: Codable {
    let status: String
    let message: String
}

class SubmitViewController: UIViewController, UITextViewDelegate  {
    @IBOutlet var textView: UITextView!
    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var loading: UIActivityIndicatorView!
    @IBOutlet var loadingBackdrop: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        self.textView.layer.cornerRadius = 2.0
        self.textView.layer.masksToBounds = false
        self.textView.layer.shadowColor = UIColor.black.cgColor
        self.textView.layer.shadowOpacity = 0.1
        self.textView.layer.shadowOffset = .zero
        self.textView.layer.shadowRadius = 5
        self.textView.layer.shouldRasterize = true
        self.textView.layer.rasterizationScale = UIScreen.main.scale
        
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeEditingAction)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitDataAction))]
        numberToolbar.sizeToFit()
        self.textView.inputAccessoryView = numberToolbar
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let alpha = CGFloat(textView.text.isEmpty ? 1.0 : 0.0)
        if alpha != self.placeholderLabel.alpha {
            self.placeholderLabel.alpha = alpha
        }
    }
    
    func showLoading() {
        self.textView.isEditable = false
        self.textView.isSelectable = false
        self.textView.isScrollEnabled = false
        self.loadingBackdrop.isHidden = false
        self.loading.isHidden = false
    }
    
    func hideLoading() {
        self.textView.isEditable = true
        self.textView.isSelectable = true
        self.textView.isScrollEnabled = true
        self.loadingBackdrop.isHidden = true
        self.loading.isHidden = true
    }

    @objc func closeEditingAction() {
        self.textView.resignFirstResponder()
    }
    @objc func submitDataAction() {
        self.showLoading()
        self.submitData(text: self.textView.text)

    }

    func submitData(text: String) {
        var components = URLComponents(string: "https://api.datar.online/v1/data")!
        components.queryItems = [
            URLQueryItem(name: "auth_key", value: Bundle.main.object(forInfoDictionaryKey: "DATAR_API_KEY") as? String)
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var json = Dictionary<String, Any>()
        json["data"] = text
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // Unknown Error
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "DATAR", message:
                        error as? String, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    
                    self.present(alertController, animated: true, completion: {
                        self.hideLoading()
                    })
                }
            } else {
                let decoder = JSONDecoder()
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                }
                let response = response as? HTTPURLResponse
                if response?.statusCode == 200 {
                    let data = try! decoder.decode(SubmitResponseData.self, from: data!)
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "DATAR", message: data.message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        
                        self.present(alertController, animated: true, completion: {
                            self.hideLoading()
                        })
                    }
                } else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "DATAR", message: "Something wrong with request", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        
                        self.present(alertController, animated: true, completion: {
                            self.hideLoading()
                        })
                    }
                }

            }
        }
        task.resume()
    }


}

