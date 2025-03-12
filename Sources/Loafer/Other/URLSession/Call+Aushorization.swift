
import AVFoundation
import UIKit

struct AuthorizationCheck {
    
    enum PermissionTipManager {
        enum PermissionTipType {
            case Audio
            case Video
            case Photo

            var desc: String {
                switch self {
                case .Audio: return "please go to settings to open your Audio permissions."
                case .Video: return "please go to settings to open your Video permissions."
                case .Photo: return "please go to settings to open your Photo permissions."
                }
            }

            var title: String { "Permission denied" }
        }

        static func alertAuthorizationStatus(type: PermissionTipType) -> UIAlertController {
            let alertController = UIAlertController(title: type.title, message: type.desc, preferredStyle: .alert)
            let actionSetting = UIAlertAction(title: "Setting", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(actionSetting)
            alertController.addAction(actionCancel)
            return alertController
        }
    }
    
    static func authorizationStatusCheck(_ completion: @escaping (()->Void)) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized && AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
            completion()
        } else {
            ToastTool.dismiss()
            if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
                let alertController = PermissionTipManager.alertAuthorizationStatus(type: .Video)
                UIApplication.rootViewController?.present(alertController, animated: true)
                return
            }
            if AVCaptureDevice.authorizationStatus(for: .audio) == .denied {
                let alertController = PermissionTipManager.alertAuthorizationStatus(type: .Audio)
                UIApplication.rootViewController?.present(alertController, animated: true)
                return
            }
            if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted && AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                }
            }
            if AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined {
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    if granted && AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                }
            }
        }
    }
}

struct CallUtil {
    
    static func call(to userId: Int64) {
        AuthorizationCheck.authorizationStatusCheck {
            IMCallProvider.sendIMSocket(.CALL_REQUEST(model: IMSocketCallRequestModel(recvId: userId)))
        }
    }
    
}
