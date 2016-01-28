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
        let q = [ "filters" : [ ["name":"campaign_id","op":"is_null","val":"null"],  ["name":"location_id","op":"is_not_null","val":"null"] ], "limit":100,  "order_by":[ ["field":"created_on", "direction":"desc"] ] ]
        
        Hit.query(q){ (hits:[Hit])->Void in
            self.hits.appendContentsOf(hits)
            done?()
        }
    }
    
    var currentLocation:CLLocation! = nil
    var currentLocationName:String = "Earth"
}


private var myContext = 0
class MapVC: EnhancedVC, GMSMapViewDelegate {
    
    var vm = MapVM()

    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map"
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "HIT List", style: UIBarButtonItemStyle.Plain, target: self, action: "gotoHitList"), animated: true)
        // Do any additional setup after loading the view.
        
        self.mapView.myLocationEnabled = true
        initMapWithFireBird()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        vm.refresh { () -> Void in
            self.addHitsToMap()
        }
        super.viewWillAppear(animated)
    }
    
    func initMapWithFireBird(){
        let camera = GMSCameraPosition.cameraWithLatitude(22.337522, longitude: 114.262969, zoom: 15)
        mapView.camera = camera;
        mapView.myLocationEnabled = true
        mapView.delegate = self;
        mapView.settings.myLocationButton = true
        mapView.settings.rotateGestures = false
        
        mapView.addObserver(self, forKeyPath: "myLocation", options: .New, context: &myContext)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print("observed")
        
        if context == &myContext {
            if let newValue = change?[NSKeyValueChangeNewKey] {
                if let location:CLLocation = newValue as? CLLocation{
                    print("got location")
                    self.vm.currentLocation = location
                    LocationManager.global.currentLoc = location
                    LocationManager.global.getCurrentLocationName({ (name:String) -> () in
                        self.vm.currentLocationName = name
                        self.title = name
                    })
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    
    func addHitsToMap(){
        self.mapView.clear()
        for hit in self.vm.hits.array{
            hit.refreshLocation{
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.addHitToMap(hit)
                })
            }
        }
    }

    func addHitToMap(hit:Hit){
//        println("add task  \(task.location.lon) \(task.location.lat)")
        let position = CLLocationCoordinate2DMake(hit.location!.lat, hit.location!.lon)
        let marker = GMSMarker(position: position)
        let uid = UserManager.currentUser?.id
        let icon = UIImage(named: hit.requester_id == uid ? "HitMarkerOwn" : "HitMarker")
        
        marker.icon = icon
        marker.userData = hit
        marker.snippet = hit.description
        marker.title = hit.title
        marker.map = self.mapView
    }
    
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        let hit = marker.userData as! Hit
        pushHitView(hit)
    }
    
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        print("try to ask location")
        let marker = GMSMarker(position: coordinate)
        marker.icon = UIImage(named: "HitMarkerOwn")
        marker.map = self.mapView
        
        self.showHUD("Loading..")
        LocationManager.global.getLocationNameByCoord(coordinate, callback: { (var name) -> () in
            print("ask location \(name)")
            if name == "" {
                name = "Unknown place"
            }
            self.askAboutLocation(name, coord: coordinate, onCancel: {()->() in
                marker.map = nil
            })
            self.hideHUD()
//            }else{
//                self.flashHUD("Cannot get any info about this locaiton!", 1)
//                dispatch_async(dispatch_get_main_queue() , { () -> Void in marker.map = nil })
//            }
//            }) { () -> () in
//                self.flashHUD("Cannot get any info about this locaiton!", 1)
//                dispatch_async(dispatch_get_main_queue() , { () -> Void in marker.map = nil })
        })
    }

    func askAboutLocation(name:String, coord:CLLocationCoordinate2D, onCancel:(()->())? = nil){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc : AskVC = mainStoryboard.instantiateViewControllerWithIdentifier("AskVC") as! AskVC
        vc.locName = name
        vc.clLoc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        self.navigationController?.pushViewController(vc, animated: true)
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
