import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapContainerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let map = Map()
        let mapView = map.initialize()
        
        self.view = mapView
        
        
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }
}