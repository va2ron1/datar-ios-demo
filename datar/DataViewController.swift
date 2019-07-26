//
//  SecondViewController.swift
//  datar
//
//  Created by va2ron1 on 7/25/19.
//  Copyright © 2019 va2ron1. All rights reserved.
//

import UIKit

class DataViewController: UIViewController{
    
    @IBOutlet var textView: UITextView!
    var dataText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.text = self.dataText
    }
}

