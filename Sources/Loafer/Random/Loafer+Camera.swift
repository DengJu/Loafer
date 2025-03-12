
import UIKit
import AVFoundation

class LoaferCaptureView: UIView, AVCapturePhotoCaptureDelegate {
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var deviceInput: AVCaptureDeviceInput?
    private(set) var finalImage: UIImage?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeCamera()
    }

    private func initializeCamera() {
        captureSession.sessionPreset = .photo
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        initDevice(device: device)
    }

    private func initDevice(device: AVCaptureDevice) {
        guard let cameraInput = try? AVCaptureDeviceInput(device: device) else { return }
        if captureSession.canAddInput(cameraInput) && captureSession.canAddOutput(photoOutput) {
            captureSession.addInput(cameraInput)
            captureSession.addOutput(photoOutput)
        }
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = CGRect(x: 0, y: 0, width: UIDevice.screenWidth-20.FIT, height: UIDevice.screenHeight-UIDevice.topFullHeight-UIDevice.bottomFullHeight-10.FIT)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.cornerRadius = 30.FIT
        layer.addSublayer(previewLayer!)
        beginRunning()
    }

    func resetRunning() {
        finalImage = nil
        beginRunning()
    }

    func beginRunning() {
        if !captureSession.isRunning {
            DispatchQueue.global().async {
                self.captureSession.startRunning()
            }
        }
    }

    func stopRunning() {
        if captureSession.isRunning {
            DispatchQueue.global().async {
                self.captureSession.stopRunning()
            }
        }
    }

    func takePhoto() {
        guard let _ = photoOutput.connection(with: .video) else { return }
        beginRunning()
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error _: Error?) {
        if let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) {
            stopRunning()
            finalImage = capturedImage
        }
    }
}
