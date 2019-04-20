//
//  ProgressLoader.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/15/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import Foundation
import GradientCircularProgress

fileprivate struct ProgressLoaderStyle : StyleProperty {
    
    // Progress Size
    public var progressSize: CGFloat = 200
    
    // Gradient Circular
    public var arcLineWidth: CGFloat = 18.0
    public var startArcColor: UIColor = UIColor.clear
    public var endArcColor: UIColor = UIColor.orange
    
    // Base Circular
    public var baseLineWidth: CGFloat? = 19.0
    public var baseArcColor: UIColor? = UIColor.darkGray
    
    // Ratio
    public var ratioLabelFont: UIFont? = UIFont(name: "Verdana-Bold", size: 16.0)
    public var ratioLabelFontColor: UIColor? = UIColor.white
    
    // Message
    public var messageLabelFont: UIFont? = UIFont.systemFont(ofSize: 16.0)
    public var messageLabelFontColor: UIColor? = UIColor.black
    
    // Background
    public var backgroundStyle: BackgroundStyles = .dark
    
    // Dismiss
    public var dismissTimeInterval: Double? = 0.0 // 'nil' for default setting.
    
    
    public init() {}
}

final class ProgressLoader {
    fileprivate static let progressIndicator = GradientCircularProgress()
    
    /**
     Show Progress Loader
     - parameters:
     - text: optional text to display
     */
    static func showProgressLoader(with text:String) {
        progressIndicator.show(message: text, style: ProgressLoaderStyle())
    }
    
    static func isShowing() -> Bool {
        return progressIndicator.isAvailable
    }
    
    static func showProgressLoader() {
        progressIndicator.show(style: ProgressLoaderStyle())
    }
    
    static func hideProgressLoader() {
        progressIndicator.dismiss()
    }
}
