//
//  CCRefreshVC.swift
//  JiayiWorld-Swift
//
//  Created by 123 on 2018/6/1.
//  Copyright © 2018年 123. All rights reserved.
//

import UIKit

class CCRefreshVC: UIViewController {
    
    enum CCRefreshStatus:NSInteger{
        case REFRESH_Normal = 0,     //正常状态
        REFRESH_MoveDown ,     //手指下拉
        REFRESH_MoveUp,         //手指上拉
        REFRESH_BeginRefresh   //刷新状态
    }
    
    private let MaxDistance:CGFloat  = 64; //向下拖拽最大点-刷新临界值
    private let MaxScroll:CGFloat  = 100; //向上拖拽最大点-到达最大点就动画让tableview滚动到第二个cell
    
    private var refreshStatus:CCRefreshStatus = .REFRESH_Normal
    private var refreshCallBack:(()->Void)?
    
    private var startPoint:CGPoint? = CGPoint.zero
    private var mainViewNavigitionView:UIView? = nil
    private var isDouble:Bool? = false
    private var refreshNavigitionView:CCRefreshNavView? = nil
    private lazy var clearView:UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
    private var scrollView:UIScrollView? = nil
    
    private var getRefreshView:CCRefreshNavView{
        get{
            refreshNavigitionView = CCRefreshNavView.init(frame: CGRect(x: 0, y: NAV_HEIGHT, width: SCREEN_WIDTH, height: NAV_HEIGHT))
            refreshNavigitionView!.backgroundColor = UIColor.gray
            refreshNavigitionView!.alpha = 0
            return refreshNavigitionView!
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if  ((self.scrollView?.contentOffset.y)! >= 0.0) && (self.refreshStatus == .REFRESH_Normal) {
            //当tableview停在第一个cell并且是正常状态才记录起始触摸点，防止页面在刷新时用户再次向下拖拽页面造成多次下拉刷新
            let touch = (touches as NSSet).anyObject() as AnyObject
            startPoint = touch.location(in: self.view)
        }else{
            //否则就隐藏透明视图，让页面能响应tableview的拖拽手势
            self.clearView.isHidden = true
        }
        print("begin")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if startPoint!.equalTo(CGPoint.zero){
            //没记录到起始触摸点就返回
            return
        }
        print("move")
        //获得当前的触摸点 计算滑动 距离
        let touch = (touches as NSSet).anyObject() as AnyObject
        let currentPoint = touch.location(in: self.view)
        var moveDistance = currentPoint.y-startPoint!.y
        
        if (self.scrollView?.contentOffset.y) ?? 0.0 <= CGFloat(0.0){
            //根据触摸点的移动 判断是上滑还是下滑
            if moveDistance > 0 && moveDistance < MaxDistance {
                //移动距离大于零 向下滑
                self.refreshStatus = .REFRESH_MoveDown
                //只判断当前触摸点与起始触摸点y轴方向的移动距离，只要y比起始触摸点的y大就证明是下拉，这中间可能存在先下拉一段距离没松手又上滑了一点的情况
                let alpha = moveDistance/MaxDistance
                //moveDistance>0则是下拉刷新，在下拉距离小于MaxDistance的时候对_refreshNavigitionView和_mainViewNavigitionView进行透明度、frame移动操作
                self.refreshNavigitionView?.alpha = alpha
                var frame = self.refreshNavigitionView?.frame
                frame?.origin.y = moveDistance
                self.refreshNavigitionView?.frame = frame ?? CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: NAV_HEIGHT)
                if let tmp = mainViewNavigitionView{
                    tmp.alpha = 1-alpha
                    frame = tmp.frame
                    frame?.origin.y = moveDistance
                    tmp.frame = frame ?? CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: NAV_HEIGHT)
                }
                
                 //在整体判断为下拉刷新的情况下，还需要对上一个触摸点和当前触摸点进行比对，判断圆圈旋转方向，下移逆时针，上移顺时针
                let tmpTouch = (touches as NSSet).anyObject() as AnyObject
                let previousPoint = tmpTouch.previousLocation(in: self.view)
                if currentPoint.y >= previousPoint.y{
                    self.refreshNavigitionView?.circleImage!.transform = CGAffineTransform.init(rotationAngle: -0.08)
                }else{
                    self.refreshNavigitionView?.circleImage!.transform = CGAffineTransform.init(rotationAngle: 0.08)
                }
                self.refreshNavigitionView?.titleStr = "下拉刷新"
            }else if moveDistance >= MaxDistance{
                //下拉超过最大距离
                self.refreshStatus = .REFRESH_MoveDown
                
                //下拉到最大点之后，_refreshNavigitionView和_mainViewNavigitionView就保持透明度和位置，不再移动
                self.refreshNavigitionView?.alpha = 1
                self.refreshNavigitionView?.titleStr = "松开刷新"
                
                if let tmp = mainViewNavigitionView{
                    tmp.alpha = 0
                }
                
            }else if moveDistance < 0{
                self.refreshStatus = .REFRESH_MoveUp
                //moveDistance<0则是上拉 根据移动距离修改tableview.contentOffset，模仿tableview的拖拽效果，一旦执行了这行代码，下个触摸点就会走外层else代码
                self.scrollView?.contentOffset = CGPoint(x: 0, y: -moveDistance)
            }
        }else{
            self.refreshStatus = .REFRESH_MoveUp
             //tableview被上拉了
            moveDistance = startPoint!.y - currentPoint.y;//转换为正数
            if moveDistance >= MaxScroll{
                //上拉距离超过MaxScroll，就让tableview滚动到第二个cell，模仿tableview翻页效果, 隐藏上面的透明view
                self.clearView.isHidden = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.scrollView?.contentOffset = CGPoint(x: 0, y: SCREEN_HEIGHT)
                }) { (finish) in
                    if self.scrollView?.contentOffset.y == SCREEN_HEIGHT{
                        print("第二个cell了")
                    }
                }
            }else if moveDistance > 0.0 && moveDistance < MaxScroll{
                self.scrollView?.contentOffset = CGPoint(x: 0, y: moveDistance)
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("end")
        //获得滑动结束触摸点 计算滑动 距离
        let touch = (touches as NSSet).anyObject() as AnyObject
        let currentPoint = touch.location(in: self.view)
        let moveDistance = currentPoint.y-startPoint!.y
        if moveDistance == 0 && !isDouble!{
            print("不是双击")
        }
        isDouble = false
        
        //清除起始触摸点
        startPoint = CGPoint.zero
        
        //触摸结束恢复原位-松手回弹
        UIView.animate(withDuration: 0.3, animations: {
            var frame:CGRect
            if self.refreshNavigitionView?.alpha != 1{
                frame = self.refreshNavigitionView?.frame ?? CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: NAV_HEIGHT)
                frame.origin.y = 0
                self.refreshNavigitionView?.frame = frame
            }
            
            if let tmp = self.mainViewNavigitionView{
                frame = tmp.frame
                frame.origin.y = 0
                tmp.frame = frame
            }
            
            if (self.scrollView?.contentOffset.y) ?? 0.0 < self.MaxScroll{
                 //没滚动到最大点，就复原tableview的位置
                self.scrollView?.contentOffset = CGPoint(x: 0, y: 0)
            }
            
        }) { (finish) in
            
        }
        
        if (self.scrollView?.contentOffset.y ?? 0.0 == SCREEN_HEIGHT){
            print("第二个cell")
        }
        
        if self.refreshNavigitionView?.alpha == 1 {
            if self.refreshStatus == .REFRESH_BeginRefresh {
               return
            }
            
            self.refreshStatus = .REFRESH_BeginRefresh
            
            //刷新开始图片的动画
            self.startAnimation()
            if let tmp = self.refreshCallBack{
                tmp()
            }
        }else{
            //没下拉到最大点，alpha复原
            self.resumeNormal()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    func startAnimation() {
        //要先将transform复位-因为CABasicAnimation动画执行完毕后会自动复位，就是没有执行transform之前的位置，跟transform之后的位置有角度差，会造成视觉上旋转不流畅
        self.refreshNavigitionView?.circleImage?.transform = CGAffineTransform.identity
        
        self.refreshNavigitionView?.moveCircleImageCenter()
        
        let rotationAnimation:CABasicAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber.init(value: Double.pi * 2.0)
        rotationAnimation.duration = 0.5
        rotationAnimation.isCumulative = true
        //重复旋转的次数，如果你想要无数次，那么设置成MAXFLOAT
        rotationAnimation.repeatCount = MAXFLOAT;
        self.refreshNavigitionView?.circleImage?.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func addRefresh(refreshScollView scroll:UIScrollView!, navView nav:UIView?, endRefeshCallBack callBack:(()->Void)?) {
        refreshCallBack = callBack
        scrollView = scroll
        scrollView!.bounces = false
        scrollView!.isPagingEnabled = true
        
        self.view.addSubview(clearView)
        clearView.backgroundColor = UIColor.clear
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(doubleAction(_:)))
        tap.numberOfTapsRequired = 2
        clearView.addGestureRecognizer(tap)
        
        self.view.addSubview(getRefreshView)
        
        mainViewNavigitionView = nav ?? nil
        self.view.addSubview(mainViewNavigitionView!)
        
        scrollView!.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
        scrollView!.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.old, context: nil)

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (self.scrollView?.contentOffset.y)! <=  0 {
            self.clearView.isHidden = false
        }
    }
    
    @objc func endRefresh(){
        self.resumeNormal()
        refreshNavigitionView?.circleImage?.layer.removeAnimation(forKey: "rotationAnimation")
        refreshNavigitionView?.resetCircleImageFrame()
        clearView.isHidden = false;
    }
    
    @objc func doubleAction(_ sender:UITapGestureRecognizer){
        isDouble = true
        print("clear view doule")
    }
    
    private func resumeNormal(){
        refreshStatus = .REFRESH_Normal
        UIView.animate(withDuration: 0.3) {
            self.refreshNavigitionView?.alpha = 0
            var frame = self.refreshNavigitionView?.frame
            frame?.origin.y = 0
            self.refreshNavigitionView?.frame = frame ?? CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 20)
            if let tmp = self.mainViewNavigitionView {
                tmp.alpha = 1
            }
        }
    }
}
