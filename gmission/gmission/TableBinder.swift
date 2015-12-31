//
//  TableBinder.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

class ArrayForTableView<T>{
    var array:[T] = [T]()
    subscript (index:Int) -> T{
        get {return array[index]}
        set (newValue) { array[index] = newValue}
    }
    func appendContentsOf(arr:[T]){
        array.appendContentsOf(arr)
    }
    
    func removeAll(){
        array.removeAll()
    }
}


class TableBinder<T>: NSObject,UITableViewDataSource, UITableViewDelegate {
    weak var items:ArrayForTableView<T>!
//    init(items:ArrayForTableView<T>?=nil) {
//        self.items = items ?? ArrayForTableView<T>()
//    }
    weak var tableView:UITableView!
    var refreshControl:UIRefreshControl = UIRefreshControl()
    
    func bind(tableView:UITableView, items:ArrayForTableView<T>, refreshFunc:F->Void){
        tableView.dataSource  = self
        tableView.delegate = self
        self.items = items
        self.tableView = tableView
        self.refreshFunc = refreshFunc
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refreshTableContent:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    var cellFunc: ((NSIndexPath)->UITableViewCell)!
    var selectionFunc: ((NSIndexPath)->Void)!
    var refreshFunc: (F->Void)!
    
    func refreshTableContent(e:AnyObject?=nil){
        self.refreshFunc{() in
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectionFunc?(indexPath)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellFunc(indexPath)
    }
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        selectionFunc(indexPath)
//    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.array.count
    }
    
}
