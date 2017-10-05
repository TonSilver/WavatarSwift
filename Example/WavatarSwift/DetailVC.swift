//
//  DetailVC.swift
//  WavatarSwift_Example
//
//  Created by anton.serebryakov on 30/09/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import WavatarSwift

class DetailVC: UIViewController {
    
    let string: String
    
    init(string: String) {
        self.string = string
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail"
        view.backgroundColor = .white
        view.addSubview(innerView)
        
        innerView.onImageSideUpdated = {
            [weak self]
            side in
            if let this = self {
                WavatarSwift.generate(string: this.string, size: WavatarSwift.maxSize) {
                    [weak self]
                    string, image in
                    if  let this = self,
                        string == this.string {
                        this.innerView.imageView.image = image
                    }
                }
            }
        }
        innerView.textLabel.attributedText = NSAttributedString(string: string, attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: 16),
        ])
    }
    
    private lazy var innerView: InnerView = {
        let v = InnerView(frame: self.view.bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return v
    }()
    
    private class InnerView: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var onImageSideUpdated: ((CGFloat) -> Void)? = nil
        
        func setupUI() {
            addSubview(scrollView)
            scrollView.addSubview(imageView)
            scrollView.addSubview(textLabel)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let wdt = bounds.width
            scrollView.frame = bounds
            let side = wdt - 10*2
            let imageSideChanged = (side - imageView.frame.width) > 0.5
            imageView.frame = CGRect(x: 10, y: 10, width: side, height: side)
            let hgt = ceil(textLabel.attributedText?.boundingRect(with: CGSize(width: side, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height ?? 0)
            textLabel.frame = CGRect(x: 10, y: imageView.frame.maxY + 10, width: side, height: hgt)
            scrollView.contentSize = CGSize(width: wdt, height: textLabel.frame.maxY + 10)
            
            if imageSideChanged {
                onImageSideUpdated?(side)
            }
        }
        
        lazy var scrollView: UIScrollView = {
            let v = UIScrollView()
            return v
        }()
        
        lazy var imageView: UIImageView = {
            let v = UIImageView()
            return v
        }()
        
        lazy var textLabel: UILabel = {
            let v = UILabel()
            v.numberOfLines = 0
            return v
        }()
        
    }
    
}
