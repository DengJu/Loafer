
import UIKit

class CallRemoteVideoCloseView: UIView {

    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loafer_backColor("DBDBDB")
        subviews {
            stackView
        }
        stackView.centerInContainer().width(UIDevice.screenWidth)
        stackView.addArrangedSubview(UIImageView(image: "VideoCallPage.RemoteVideoClose".toImage))
        let descView = UILabel()
        descView
            .loafer_font(17, .medium)
            .loafer_text("The other party has turned off the camera.You can prompt the other party to turn on the camera.")
            .loafer_textColor("FFFFFF", 0.6)
            .loafer_textAligment(.center)
            .loafer_numberOfLines(0)
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(35.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalCentering)
        descView.width(UIDevice.screenWidth-40.FIT)
        stackView.addArrangedSubview(descView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CallLocalVideoCloseView: UIView {
    
    private let imageView = UIImageView(image: "VideoCallPage.LocalVideoClose".toImage)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviews {
            imageView
        }
        imageView.fillContainer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
