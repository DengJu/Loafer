
import AVFoundation
import PhotosUI
import UIKit

struct AssetsModel {
    enum AssetsFileType {
        case image, video
    }

    var localUrl: URL?
    var fileType: AssetsFileType = .image
    var image: UIImage?
    var identifier: String = ""
}

class AssetsSession: NSObject {
    static let session = AssetsSession()

    private var assetsCompletion: (([AssetsModel]) -> Void)?

    func filterPictureFromAlbum(type: PHPickerFilter? = .images, count: Int = 1, from: UIViewController, completion: (([AssetsModel]) -> Void)?) {
        assetsCompletion = completion

        var config = PHPickerConfiguration()
        config.filter = type
        config.selectionLimit = count
        config.preferredAssetRepresentationMode = .automatic
        if #available(iOS 15.0, *) {
            config.selection = count > 1 ? .ordered : .default
        }
        let pickerController = PHPickerViewController(configuration: config)
        pickerController.delegate = self
        from.present(pickerController, animated: true)
    }
    
    func filterPictureFromCamera(from: UIViewController, completion: (([AssetsModel]) -> Void)?) {
        assetsCompletion = completion
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .authorized {
            openCamera(from: from, completion: assetsCompletion)
        }else if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { finish in
                if finish {
                    self.openCamera(from: from, completion: self.assetsCompletion)
                }
            }
        }else {
            ToastTool.show(.failure, "Please open the camera permissions!")
        }
    }
    
    private func openCamera(from: UIViewController, completion: (([AssetsModel]) -> Void)?) {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                imagePicker.cameraDevice = .front
                from.present(imagePicker, animated: true, completion: nil)
            } else {
                ToastTool.show(.failure, "Camera is not available.")
            }
        }
    }
    
}

extension AssetsSession: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                var itemModel = AssetsModel()
                itemModel.fileType = .video
                itemModel.image = image
                DispatchQueue.main.async {
                    self.assetsCompletion?([itemModel])
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
     
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
}

extension AssetsSession: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if !results.isEmpty {
            Task {
                let infoModels = await parseAsset(results: results)
                DispatchQueue.main.async {
                    self.assetsCompletion?(infoModels)
                    picker.dismiss(animated: true)
                }
            }
        } else {
            picker.dismiss(animated: true)
        }
    }

    private func parseAsset(results: [PHPickerResult]) async -> [AssetsModel] {
        var models = [AssetsModel]()
        for result in results {
            let isImageInfo = result.itemProvider.canLoadObject(ofClass: UIImage.self)
            guard let fileUrl = await loadFileUrl(provider: result.itemProvider, type: isImageInfo ? .image : .movie) else {
                return models
            }
            var coverImage: UIImage?
            if isImageInfo {
                if let imageData = try? NSData(contentsOf: fileUrl) as Data {
                    coverImage = UIImage(data: imageData)
                }
            } else {
                coverImage = await loadVideoCover(url: fileUrl)
            }

            var itemModel = AssetsModel(localUrl: fileUrl)
            itemModel.fileType = isImageInfo ? .image : .video
            itemModel.image = coverImage
            itemModel.identifier = result.assetIdentifier ?? ""
            models.append(itemModel)
        }
        return models
    }

    private func loadFileUrl(provider: NSItemProvider, type: UTType) async -> URL? {
        await withCheckedContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: type.identifier) { url, error in
                if let error = error {
                    continuation.resume(returning: nil)
                } else {
                    continuation.resume(returning: url)
                }
            }
        }
    }

    private func loadVideoCover(url _: URL) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true

        let fetchResult = PHAsset.fetchAssets(with: .video, options: nil)
        if let asset = fetchResult.firstObject {
            return await withCheckedContinuation { continuation in
                PHCachingImageManager().requestImageDataAndOrientation(for: asset, options: options) { imageData, _, _, _ in
                    if let imageData {
                        continuation.resume(returning: UIImage(data: imageData))
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        } else {
            return nil
        }
    }
}
