//
//  LocationManager.swift
//  gmission
//
//  Created by CHEN Zhao on 6/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps


func log(message: String = "called", function: String = __FUNCTION__) {
    print("\(function): \(message)")
}


class PositionTrace:JsonEntity{
    
}

class LocationManager: NSObject, CLLocationManagerDelegate{
    static let global = LocationManager()
    
    let m:CLLocationManager = CLLocationManager()
    
    dynamic var lastPostedLoc:CLLocation!
    
    dynamic var lastNamedLoc:CLLocation!
    dynamic var lastLocNameUpdatedTime:NSDate?
    dynamic var currentLoc:CLLocation!
    
    dynamic var name:String = "Earth"
    
    func applicationLaunched(){
        log()
        m.delegate = self
        m.distanceFilter = 10.0 //meters
        m.pausesLocationUpdatesAutomatically = true
        //        m.requestAlwaysAuthorization() //no iOS 7 support yet..
        
        if CLLocationManager.locationServicesEnabled() {
            if m.respondsToSelector("requestAlwaysAuthorization") {
                m.requestAlwaysAuthorization()
            }
        }
        
        m.startUpdatingLocation()
    }
    
    func gotoBackground(){
        log()
        m.stopUpdatingLocation()
        m.startMonitoringSignificantLocationChanges()
        m.allowDeferredLocationUpdatesUntilTraveled(50, timeout: 60)
    }
    
    func gotoForeground(){
        log()
        m.startUpdatingLocation()
        m.stopMonitoringSignificantLocationChanges()
        m.disallowDeferredLocationUpdates()
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        log("loc auth status \(status.rawValue)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        log()
        self.currentLoc = locations.first!
        postIfNeeded(self.currentLoc)
    }
    
    func postIfNeeded(loc:CLLocation){
        if let u = UserManager.currentUser{
            if self.needToPostLocation(loc){
                let p = PositionTrace( dict:[ "created_on":loc.timestamp, "latitude": loc.coordinate.latitude, "longitude": loc.coordinate.longitude, "z": Int(loc.course), "user_id": u.id])
                PositionTrace.postOne(p, done: { () -> Void in
                    log("location posted")
                })
                self.lastPostedLoc = loc // location updates may be faster than post
            }
        }
    }
    
    static func coordDict(loc:CLLocation)->[String:AnyObject]{
        return ["latitude":loc.coordinate.latitude, "longitude":loc.coordinate.longitude, "altitude":loc.altitude]
    }
    
    func newLocation(done:(Location)->()){
        self.getCurrentLocationName { (locName) -> () in
            var location:CLLocation
            if self.currentLoc != nil {
                location = self.currentLoc
            }else{
                location = CLLocation(latitude: 0, longitude: 0)
            }
            let coord = Coordinate(dict:LocationManager.coordDict(location))
            Coordinate.postOne(coord, done: { (coord:Coordinate) -> Void in
                let loc = Location(dict: ["name":locName, "coordinate_id":coord.id])
                Location.postOne(loc, done: { (loc:Location) -> Void in
                    done(loc)
                })
            })
        }
    }
    
    func newCustomLocation(locName:String, clLoc:CLLocation, done:(Location)->()){
        let coord = Coordinate(dict:LocationManager.coordDict(clLoc))
        Coordinate.postOne(coord, done: { (coord:Coordinate) -> Void in
            let loc = Location(dict: ["name":locName, "coordinate_id":coord.id])
            Location.postOne(loc, done: { (loc:Location) -> Void in
                done(loc)
            })
        })
    }
    
    func needToPostLocation(loc:CLLocation)->Bool{
        var need = true
        if let lastloc = self.lastPostedLoc{
            let MinTimeDiff: NSTimeInterval = 30 //seconds
            let MinDistDiff: CLLocationDistance = 10.0 //meters
            let dis = GMSGeometryDistance(lastloc.coordinate, loc.coordinate)
            need = loc.timestamp.timeIntervalSinceDate(lastloc.timestamp) > MinTimeDiff || dis>MinDistDiff
            if need{
                log("last exists but still need")
            }
        }else{
            log("no last, will try now")
        }
        return need
    }
    
    
    func needToUpdateName(loc:CLLocation!)->Bool{
        if loc  != nil {
        var need = true
        if let lastNamedloc = self.lastNamedLoc{
            let MinTimeDiff: NSTimeInterval = 10 //seconds
            let MinDistDiff: CLLocationDistance = 50.0 //meters
            let dis = GMSGeometryDistance(lastNamedloc.coordinate, loc.coordinate)
            need = loc.timestamp.timeIntervalSinceDate(lastNamedloc.timestamp) > MinTimeDiff || dis>MinDistDiff
            if need{
                log("last named exists but still need")
            }
        }else{
            log("no last named, will try now")
        }
        return need
        }
        return false
    }
    
    func validNameFromAddresses(addresses:[GMSAddress])->String{
        var validName = ""
        if let address = addresses.first as GMSAddress?{
            validName = address.lines.first as! String!
        }
        if validName == ""{
            validName = addresses.last!.lines.first as! String!
        }
        return validName
    }
    
    
    func getLocationNameByCoord(coord:CLLocationCoordinate2D, callback:(String)->(), failed:F=nil){
        let coder = GMSGeocoder()
        coder.reverseGeocodeCoordinate(coord, completionHandler: { (r:GMSReverseGeocodeResponse!, e:NSError!) -> Void in
            if let response = r{
                let name = self.validNameFromAddresses(response.results() as! [GMSAddress])
                print("location name: \(name)");
                callback(name)
            }else {
                log("get location name failed\(e)")
                callback("")
                failed?()
            }
        })
    }
    
    func getCurrentLocationName(callback:(String)->()){
        if needToUpdateName(currentLoc){
            self.getLocationNameByCoord(self.currentLoc.coordinate, callback: { (name:String) -> () in
                self.name = name
                self.lastNamedLoc = self.currentLoc
                callback(name)
                }, failed: { () -> () in
                    print("current location name failed... Let's say you are still on the earth.")
                    self.name = "Earth"
                    callback("Earth")
            })
        }else{
            callback(self.name)
        }
    }
    
}