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
    let DEFAULT_VIEW_HEIGHT:CGFloat = 0.0
    
    var centerPoint:CGPoint = CGPoint(x:0, y:0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenBound = UIScreen.main.bounds
        let widht = screenBound.width/2
        let height = (screenBound.height/2) - 50.0
        centerPoint = CGPoint(x: widht, y: height)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /**
     Shows a Toast message with given duration & position
     - parameters:
        - text: message to be shown as toast
        - position: options are bottom, center & top
        - duration: for how long toast should be visible
    */
    func makeBasicToastWith(text:String, position:ToastPosition = .bottom, duration:Double = 3) {
        view.makeToast(text, duration: duration, position:.bottom)
    }
    
    /**
     Shows a Toast message in tableviews with given duration at bottom
     - parameters:
        - text: message to be shown as toast
        - duration: for how long toast should be visible
     */
    func makeBasicToastWithForTableViews(text:String, duration:Double = 3) {
        view.window?.makeToast(text, duration: duration, position: .bottom)
    }
    
    /// show Loading Activity at the center
    func makeActivityToastAtCenter() {
        view.makeToastActivity(centerPoint)
    }
    
    /// hides the Loading Activity
    func hideToastActivity(){
        view.hideToastActivity()
    }
}

extension BaseViewController {
        @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == DEFAULT_VIEW_HEIGHT {
                    self.view.frame.origin.y -= (keyboardSize.height)
                }
            }
        }
        
        @objc func keyboardWillHide(notification: NSNotification) {
            
            if self.view.frame.origin.y != DEFAULT_VIEW_HEIGHT {
                self.view.frame.origin.y = DEFAULT_VIEW_HEIGHT
            }
        }
}
