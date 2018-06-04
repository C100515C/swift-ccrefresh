//
//  CCRefreshNavView.swift
//  JiayiWorld-Swift
//
//  Created by 123 on 2018/6/1.
//  Copyright © 2018年 123. All rights reserved.
//

import UIKit

class CCRefreshNavView: UIView {
    var circleImage:UIImageView?
    private var title:UILabel?
    var titleStr:String{
        get{
            return title?.text ?? ""
        }
        set(newStr){
            title?.text = newStr
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        title = UILabel.init(frame: CGRect(x: 0, y:0 , width: SCREEN_WIDTH, height: 20.0))
        title!.backgroundColor = UIColor.clear
        title!.textColor = UIColor.black
        title!.textAlignment = NSTextAlignment.center
        title!.numberOfLines = 0
        title!.font = UIFont.systemFont(ofSize: 16)
        title!.text = "下拉刷新"
        self.addSubview(self.title!)
        
        circleImage =  UIImageView.init(frame: CGRect(x: (SCREEN_WIDTH-18.0)/2.0, y:NAV_HEIGHT-13.0-18.0 , width: 18.0, height: 18.0))
        self.addSubview(circleImage!)
        circleImage!.isHidden = true
        circleImage!.image = UIImage.init(named: "circle")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveCircleImageCenter() {
        title?.isHidden = true;
        circleImage?.isHidden = false;
    }
    
    func resetCircleImageFrame() {
        title?.isHidden = false;
        circleImage?.isHidden = true;
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
