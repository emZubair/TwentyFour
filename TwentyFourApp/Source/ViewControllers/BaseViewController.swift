//
//  BaseViewController.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/17/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import UIKit
import ToastSwiftFramework

class BaseViewController : UIViewController {
    var centerPoint:CGPoint = CGPoint(x:0, y:0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenBound = UIScreen.main.bounds
        let widht = screenBound.width/2
        let height = (screenBound.height/2) - 50.0
        centerPoint = CGPoint(x: widht, y: height)
    }
    
    func makeBasicToastWith(text:String) {
        view.makeToast(text, position:.bottom)
    }
    
    func makeBasicToastWithForTableViews(text:String) {
        view.window?.makeToast(text, position: .bottom)
    }
    
    func makeTimedToastWith(text:String, duration:Double = 3) {
        view.makeToast(text, duration: duration, position: .bottom)
    }
    
    func makeActivityToastAtCenter() {
        view.makeToastActivity(centerPoint)
    }
    
    func hideToastActivity(){
        view.hideToastActivity()
    }
}
