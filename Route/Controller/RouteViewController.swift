//
//  RouteViewController.swift
//  Route
//
//  Created by Terry Jason on 2024/1/13.
//

import UIKit
import MapKit

class RouteViewController: UIViewController {
    
    private var annotations = [MKPointAnnotation]()
    
    // MARK: - @IBOulet
    
    @IBOutlet var mapView: MKMapView!
}

// MARK: - Life Cycle

extension RouteViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longpressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinLocation))
        longpressGestureRecognizer.minimumPressDuration = 1
        
        mapView.delegate = self
        mapView.addGestureRecognizer(longpressGestureRecognizer)
    }
    
}

// MARK: - Action Methods

extension RouteViewController {
    
    @IBAction func drawPolyline() {
        mapView.removeOverlays(mapView.overlays)
        
        var coordinates = [CLLocationCoordinate2D]()
        
        for annotation in annotations {
            coordinates.append(annotation.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        
        mapView.addOverlay(polyline)
    }
    
    @IBAction func drawRoute() {
        mapView.removeOverlays(mapView.overlays)
        
        var coordinates = [CLLocationCoordinate2D]()
        
        for annotation in annotations {
            coordinates.append(annotation.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        
        let visibleMapRect = mapView.mapRectThatFits(polyline.boundingMapRect, edgePadding : UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        
        self.mapView.setRegion(MKCoordinateRegion(visibleMapRect), animated: true)
        
        var index = 0
        
        while index < annotations.count - 1 {
            drawDirection(startPoint: annotations[index].coordinate, endPoint: annotations[index + 1].coordinate)
            index += 1
        }
        
    }
    
    @IBAction func removeAnnotations() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(annotations)
        
        annotations.removeAll()
    }
    
}

// MARK: - @objc Methods

extension RouteViewController {
    
    @objc func pinLocation(sender: UILongPressGestureRecognizer) {
        if sender.state != .ended { return }
        
        let tappedPoint = sender.location(in: mapView)
        let tappedCoordinate = mapView.convert(tappedPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = tappedCoordinate
        
        annotations.append(annotation)
        
        mapView.showAnnotations([annotation], animated: true)
    }
    
}

// MARK: - Methods

extension RouteViewController {
    
    func drawDirection(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D) {
        
        let startPlacemark = MKPlacemark(coordinate: startPoint, addressDictionary: nil)
        let endPlacemark = MKPlacemark(coordinate: endPoint, addressDictionary: nil)
        
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let endMapItem = MKMapItem(placemark: endPlacemark)
        
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = startMapItem
        directionRequest.destination = endMapItem
        directionRequest.transportType = MKDirectionsTransportType.automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { res, err in
            guard let res = res else {
                if let err = err {
                    print("Error: \(err)")
                }
                
                return
            }
            
            let route = res.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
        }
        
    }
    
}

// MARK: - MKMapViewDelegate

extension RouteViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let annotationView = views.first!
        let endFrame = annotationView.frame
        
        annotationView.frame = endFrame.offsetBy(dx: 0, dy: -600)
        
        UIView.animate(withDuration: 0.3) {
            annotationView.frame = endFrame
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.lineWidth = 3.0
        renderer.strokeColor = UIColor.systemOrange
        renderer.alpha = 0.5
        
        let visibleMapRect = mapView.mapRectThatFits(renderer.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        
        mapView.setRegion(MKCoordinateRegion(visibleMapRect), animated: true)
        
        return renderer
    }
    
}
