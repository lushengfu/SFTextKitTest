//
//  ViewController.swift
//  SFTextKitTest
//
//  Created by happy on 2018/2/9.
//  Copyright © 2018年 happy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lable: SFLable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lable.text = "七田真: http://www.qitianzhen.cn";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

