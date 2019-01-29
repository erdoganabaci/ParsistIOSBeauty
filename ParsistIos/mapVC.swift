//
//  ViewController.swift
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
class mapVC: UIViewController,MKMapViewDelegate , CLLocationManagerDelegate {
    @IBOutlet weak var indicatorActivity: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    var manager = CLLocationManager()
    var requestCLlocation = CLLocation()
    var location = CLLocationCoordinate2D()
    var chosenLatitute = [String]()
    var chosenLongitute = [String]()
    var poiCoodinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var nameArray = [String]()
    var typeArray = [String]()
    var situationArray = [String]()
    var latituteArray = [String]()
    var longituteArray = [String]()
    var imageArray = [String]()
    var doubleLatitute = [Double]()
    var doubleLongitute = [Double]()
    var resimUrl = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorActivity.isHidden = false
        indicatorActivity.startAnimating()
        mapView.delegate = self
        manager.delegate = self
        getDataFromFirebase()
        //newTestFirebase()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        mapView.showsUserLocation = true
        //manager.startUpdatingLocation() //veriler yokken güncellemek mantıksız veriler olduğunda güncelle.
        //locasyon update durdurmayı unutma locationmanager çağrılınca iptal etsin güncellemeyi.
        createLocation()
      
       
    }
  
    func getDataFromFirebase(){
        //güvenli kod için fonksiyon her açıldığında içi boş array gelip doldurcak.
        self.nameArray.removeAll(keepingCapacity: false)
        self.typeArray.removeAll(keepingCapacity: false)
        self.situationArray.removeAll(keepingCapacity: false)
        self.latituteArray.removeAll(keepingCapacity: false)
        self.longituteArray.removeAll(keepingCapacity: false)
        self.imageArray.removeAll(keepingCapacity: false)
        
        let databaseReference = Database.database().reference()
        databaseReference.child("Locations").observe(DataEventType.childAdded, with: { (snapshot) in
            let values = snapshot.value as! NSDictionary
            // print("Değerler : \(values)")
            
            //let post = values["post"] as! NSDictionary
            let locationID = values.allKeys //all keys taken
            //print("Tüm locasyon idleri : \(locationID)")
            for id in locationID{
                let singleLocation = values[id] as! NSDictionary
                //print(singleLocation["parkname"] as! String) //her birinin değerleri getirildi.
                // print(singleLocation["downloadurl"] as! String )
                self.nameArray.append(singleLocation["parkname"] as! String)
                self.typeArray.append(singleLocation["parkdetail"] as! String)
                self.situationArray.append(singleLocation["situation"] as! String)
                self.latituteArray.append(singleLocation["latitute"] as! String)
                self.longituteArray.append(singleLocation["longitute"] as! String)
                self.imageArray.append(singleLocation["downloadurl"] as! String)
                self.doubleLatitute = self.latituteArray.map{ Double($0)! }
                self.doubleLongitute = self.longituteArray.map{ Double($0)! }
                //print(self.doubleLatitute)
                ////////////////
            /*    for lat in self.latituteArray{
                    self.chosenLatitute.append(lat)
                }
                //print("choosen lat array : \(self.chosenLatitute)")
                for long in self.longituteArray{
                    self.chosenLongitute.append(long)
                }
          */
               
            }
          
            //print("Lat datası \(self.latituteArray)")
         
            for id in locationID{
                let singleLocation = values[id] as! NSDictionary
                let annotations = MKPointAnnotation()
                let annotTitle = singleLocation["parkname"] as! String
                self.resimUrl = singleLocation["downloadurl"] as! String
                annotations.title = annotTitle
               
                
                self.poiCoodinates.latitude = CDouble(singleLocation["latitute"] as! String)!
                self.poiCoodinates.longitude = CDouble(singleLocation["longitute"] as! String )!
                //print("name \(name)")
               // annotations.coordinate = CLLocationCoordinate2D(latitude: doubleLat as! Double, longitude: self.doubleLongitute as! Double)
                annotations.coordinate = CLLocationCoordinate2D(latitude:self.poiCoodinates.latitude , longitude:self.poiCoodinates.longitude)
                self.mapView.addAnnotation(annotations)
            }
            
            /*
            for name in self.nameArray{
                let annotations = MKPointAnnotation()
                annotations.title = name
                print("name \(name)")
                // annotations.coordinate = CLLocationCoordinate2D(latitude: doubleLat as! Double, longitude: self.doubleLongitute as! Double)
                annotations.coordinate = CLLocationCoordinate2D(latitude:CDouble(exactly: self.latituteArray), longitude:self.doubleLongitute as! Double)
                self.mapView.addAnnotation(annotations)
            }
            
            
         */
            
        }) { (error) in
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert   )
            let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
      
    }
    func createLocation(){
     
        
    }
 
    
    func allMapAnnotation(){
        for doubleLat in self.doubleLatitute{
            
            for doubleLong in self.doubleLongitute {
                
                let annotations = MKPointAnnotation()
                
                annotations.coordinate = CLLocationCoordinate2D(latitude: doubleLat, longitude: doubleLong)
                
                //annotations.title = nameArray as! String  //bunu ekleyince çalışmıyor loopta yok diye yada loopda dönerken hata veriyor.
                
                self.mapView.addAnnotation(annotations)
                
            }
    }
}
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //locasyon update edildiğinde  kullanıcıya focus atması için
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        
            
            
            manager.stopUpdatingLocation()
            
            
        
    
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        var selectedAnnotation = view.annotation
        print("başlığı seçtim \(selectedAnnotation?.title)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //fonksiyonu override ediyruz ve harita pinlerini özelleştirebiliyoruz.
        if annotation is MKUserLocation { //lokasyonla ilgili anatasyonsa hiçbirşey yapma.
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true //yanına buton eklenebilir mi evet diyoruz
            //pinView?.image = UIImage(named: "cat.png")
            ///let button = UIButton(type: .detailDisclosure)
            //let button1 = UIButton(type: .infoLight)
            ///pinView?.rightCalloutAccessoryView = button
            //pinView?.leftCalloutAccessoryView = button1
            
        }else{
            pinView?.annotation = annotation //böylece pinviewı customize ettik.
        }
        
        let databaseReference = Database.database().reference().child("Locations").child("post")
        databaseReference.queryOrdered(byChild: "parkname").queryEqual(toValue: pinView?.annotation?.title as! String).observe(DataEventType.childAdded) { (snapshot) in
            if snapshot.exists(){
 
                let values = snapshot.value! as! NSDictionary
                self.resimUrl =  values["downloadurl"] as! String
                print("filtreli resim:\(pinView?.annotation?.title) ---> \(self.resimUrl)")
                if let url = NSURL(string: self.resimUrl){
                    if let data = NSData(contentsOf: url as! URL){
                       // let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                        //let myImage = imageView.sd_setImage(with: URL(string: self.resimUrl as! String))
                        //pinView?.detailCalloutAccessoryView = UIImageView(image: UIImage(data: data as! Data, scale: 50))
                       // pinView?.detailCalloutAccessoryView = UIImageView(frame: CGRect()
                        let width = 100
                        let height = 100
                        
                        let snapshotView = UIView()
                        let views = ["snapshotView": snapshotView]
                        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[snapshotView(100)]", options: [], metrics: nil, views: views))
                        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[snapshotView(100)]", options: [], metrics: nil, views: views))
                        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                        let myImage = imageView.sd_setImage(with: URL(string: self.resimUrl as! String))
                        snapshotView.addSubview(imageView)
                        pinView?.detailCalloutAccessoryView = snapshotView
                    }
                }
            }
            self.indicatorActivity.isHidden = true
            self.indicatorActivity.stopAnimating()
            
        }
        
        print("pinview annot title \(pinView?.annotation?.title) )")
        
        
        //print("Benim image arraylerim : \(resimUrl)")
        //left
        let leftAccessory = UILabel(frame: CGRect(x: 0,y: 0,width: 50,height: 30))
        leftAccessory.text = "sol taraf"
        leftAccessory.font = UIFont(name: "Verdana", size: 10)
        pinView?.leftCalloutAccessoryView = leftAccessory
        
        // Right accessory view
        let image = UIImage(named: "nav.png")
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(image, for: UIControl.State())
        pinView?.rightCalloutAccessoryView = button
        
       
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //pinlerin butonuna tıklayınca navigasyona yollucaz
        self.requestCLlocation = CLLocation(latitude: Double(self.poiCoodinates.latitude), longitude: Double(self.poiCoodinates.longitude))
            CLGeocoder().reverseGeocodeLocation(requestCLlocation) { (placemarks, error) in
                if let placemark = placemarks{
                    if placemark.count > 0 { //diziden adres alabildiysem
                        let mkPlaceMark = MKPlacemark(placemark: placemark[0])
                        let mapItem = MKMapItem(placemark: mkPlaceMark)
                        mapItem.name = self.nameArray[0].capitalized as! String
                        //navigyonu kullandığım kısım
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        mapItem.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        
    }
    @IBAction func parkListClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "frommapVCtoplacesVC", sender: nil)
    }
    
}

