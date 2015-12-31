//
//  MapVC.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit
import GoogleMaps


class MapVM{
    let hits = ArrayForTableView<Hit>()
    
    init(){
    }
    
    func refresh(done:F = nil){
        self.hits.removeAll()
        let q = [ "filters" : [ ["name":"location_id","op":"neq","val":"null"] ] ]
        
        Hit.query(q){ (hits:[Hit])->Void in
            self.hits.appendContentsOf(hits)
            done?()
        }
    }
}

class MapVC: EnhancedVC {
    
    var vm = MapVM()

    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "HIT List", style: UIBarButtonItemStyle.Plain, target: self, action: "gotoHitList"), animated: true)
        // Do any additional setup after loading the view.
        vm.refresh { () -> Void in
            self.addHitsToMap()
        }
    }
    
    
    func addHitsToMap(){
        
    }
    
    
    func gotoHitList(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let hitListVC = storyboard.instantiateViewControllerWithIdentifier("hitListVC") as! HitListVC
        self.navigationController?.pushViewController(hitListVC, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
