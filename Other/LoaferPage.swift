
import UIKit
@_exported import Stevia

class LoaferPage: UIViewController {
    
    let loadingStatus = Status(isLoading: true)
    let backGroundImageView = UIImageView(image: "Loafer_Basic_BackgroundImage".toImage)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = "000000".toColor
        backGroundImageView.frame = view.bounds
        backGroundImageView
            .loafer_clipsToBounds(true)
            .loafer_contentMode(.scaleAspectFill)
        view.insertSubview(backGroundImageView, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    fileprivate func setGradientColors() {
        let pastelView = PastelView(frame: view.bounds)
        pastelView.startPastelPoint = .topRight
        pastelView.endPastelPoint = .bottomLeft
        pastelView.animationDuration = 3.0
        pastelView.setColors(["2F0021".toColor, "2D0555".toColor, "5D0059".toColor])
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
    }
    
}
