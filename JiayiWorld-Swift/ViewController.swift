//
//  ViewController.swift
//  JiayiWorld-Swift
//
//  Created by 123 on 2018/5/31.
//  Copyright © 2018年 123. All rights reserved.
//

import UIKit

class ViewController: CCRefreshVC, UITableViewDelegate, UITableViewDataSource {
    let scroll:UITableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableViewStyle.plain)
    let navView:UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: NAV_HEIGHT))
    static let cellID = "cc"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //刷新测试
        allUIInit()
        self.addRefresh(refreshScollView: self.scroll, navView: self.navView) {
            print("刷新结束")
//            self.endRefresh()
            self.perform(#selector(self.endRefresh), with: nil, afterDelay: 3)
        }
        
        let btn = UIButton.init(type: UIButtonType.custom)
        self.view.addSubview(btn)
        btn.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//        let action1 = #selector(btnAction as ()->())
//        let action2 = #selector(btnAction as (UIButton)->())

        btn.addTarget(self, action: #selector(btnAction), for: UIControlEvents.touchUpInside)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func btnAction() {
        print("btn")
    }
//    @objc func btnAction(_ sender:UIButton){
//        print("btn1")
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func allUIInit() {
        self.scroll.delegate = self
        self.scroll.dataSource = self
        self.scroll.tableFooterView = UIView.init()
//        if @available(iOS 11.0, *) do {
            //ios 11 的设置为 不计算内边距 UIScrollViewContentInsetAdjustmentNever
            self.scroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
            //iOS 11 设置下面三个预算高度 回调执行即为滑到那个执行那个
            self.scroll.estimatedRowHeight = 0
            self.scroll.estimatedSectionHeaderHeight = 0
            self.scroll.estimatedSectionFooterHeight = 0
//        }
        
        self.navView.backgroundColor = UIColor.purple
        
        self.view.addSubview(self.scroll)
        self.view.addSubview(self.navView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SCREEN_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: ViewController.cellID)
        if cell==nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: ViewController.cellID)
        }
        
        cell!.textLabel!.text = "第\(indexPath.row)行"
        cell!.textLabel!.textColor = UIColor.red
        
        return cell!
    }
}
