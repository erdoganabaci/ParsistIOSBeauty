//
//  detailsVC.swift
//  ParsistIos
//
//  Created by Erdo on 21.01.2019.
//  Copyright © 2019 Erdo. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SDWebImage
class detailsVC: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate {
    var selectedPlace = ""
    var chosenLatitute = ""
    var chosenLongitute = ""
    var anotationname = ""
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeAtmosphereLabel: UILabel!
    @IBOutlet weak var placeTypeLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
     var poiCoodinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
     var nameArray = [String]()
     var typeArray = [String]()
     var atmosphereArray = [String]()
     var latituteArray = [String]()
     var longituteArray = [String]()
     var imageArray = [String]()
    
    var manager = CLLocationManager()
    var requestCLlocation = CLLocation()
    override func viewDidLoad(){
        super.viewDidLoad()
        mapView.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        findPlaceFromFirebase()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //locasyon update edildiğinde  kullanıcıya focus atması için
        let location = CLLocationCoordinate2D(latitude: poiCoodinates.latitude, longitude: poiCoodinates.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        manager.stopUpdatingLocation()
    
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("pinwiew çalıştı")
        //fonksiyonu override ediyruz ve harita pinlerini özelleştirebiliyoruz.
        if annotation is MKUserLocation { //lokasyonla ilgili anatasyonsa hiçbirşey yapma.
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true //yanına buton eklenebilir mi evet diyoruz
            let button = UIButton(type: .detailDisclosure)
            //let button1 = UIButton(type: .infoLight)
            pinView?.rightCalloutAccessoryView = button
            //pinView?.leftCalloutAccessoryView = button1
            
        }else{
            pinView?.annotation = annotation //böylece pinviewı customize ettik.
        }
        
        
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //pinlerin butonuna tıklayınca navigasyona yollucaz
        print("mapview çalıştı")
        if self.chosenLatitute != "" && self.chosenLongitute != ""{
            self.requestCLlocation = CLLocation(latitude: Double(self.chosenLatitute)!, longitude: Double(self.chosenLongitute)!)
            CLGeocoder().reverseGeocodeLocation(requestCLlocation) { (placemarks, error) in
                if let placemark = placemarks{
                    if placemark.count > 0 { //diziden adres alabildiysem
                        let mkPlaceMark = MKPlacemark(placemark: placemark[0])
                        let mapItem = MKMapItem(placemark: mkPlaceMark)
                        mapItem.name = self.nameArray.last?.capitalized as! String
                        //navigyonu kullandığım kısım
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        mapItem.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
    }
    
    
    func findPlaceFromFirebase()  {
        self.nameArray.removeAll(keepingCapacity: false)
        self.typeArray.removeAll(keepingCapacity: false)
        self.atmosphereArray.removeAll(keepingCapacity: false)
        self.latituteArray.removeAll(keepingCapacity: false)
        self.longituteArray.removeAll(keepingCapacity: false)
        self.imageArray.removeAll(keepingCapacity: false)
        print("Fonksiyon çalıştırıldı")
        let databaseReference = Database.database().reference().child("Locations").child("post")
        databaseReference.queryOrdered(byChild: "parkname").queryEqual(toValue: self.selectedPlace).observe(DataEventType.childAdded, with: { (snapshot) in
            if snapshot.exists(){
                let values = snapshot.value! as! NSDictionary
                self.nameArray.append(values["parkname"] as! String)
                self.typeArray.append(values["parkdetail"] as! String)
                self.atmosphereArray.append(values["situation"] as! String)
                self.latituteArray.append(values["latitute"] as! String)
                self.longituteArray.append(values["longitute"] as! String)
                self.imageArray.append(values["downloadurl"] as! String)
                self.chosenLatitute = self.latituteArray.last as! String
                self.chosenLongitute = self.longituteArray.last as! String
                
                self.placeName.text = self.nameArray.last?.capitalized as! String
                self.placeTypeLabel.text = self.typeArray.last as! String
                self.placeAtmosphereLabel.text = self.atmosphereArray.last as! String
                self.placeImage.sd_setImage(with: URL(string: self.imageArray.last as! String))
                
               
                print(self.selectedPlace)
                
                
                
                self.poiCoodinates.latitude = CDouble(values["latitute"] as! String)!
                self.poiCoodinates.longitude = CDouble(values["longitute"] as! String )!
                //print("name \(name)")
                // annotations.coordinate = CLLocationCoordinate2D(latitude: doubleLat as! Double, longitude: self.doubleLongitute as! Double)
                let location = CLLocationCoordinate2D(latitude:self.poiCoodinates.latitude , longitude:self.poiCoodinates.longitude)
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: location, span: span)
                self.mapView.setRegion(region, animated: true)
                self.manager.stopUpdatingLocation()
             
                let annotations = MKPointAnnotation()
                annotations.title = self.nameArray.last?.capitalized as! String
                annotations.subtitle = self.typeArray.last?.capitalized as! String
                annotations.coordinate = location
                self.mapView.addAnnotation(annotations)
                print(self.latituteArray)
                print(self.nameArray.last as! String)
                
            }else{
                let alert = UIAlertController(title: "Error", message: "Database Connection Failed", preferredStyle: UIAlertController.Style.alert   )
                let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
        }) { (error) in
        
             let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert   )
             let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
             alert.addAction(okButton)
             self.present(alert, animated: true, completion: nil)
            
        }
       
       
    }
    
    
    
}
    




