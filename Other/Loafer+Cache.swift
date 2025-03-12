
import UIKit
import PromiseKit
import ZIPFoundation
//import Alamofire

struct LoaferStorage {
    enum LoaferStorageType: String {
        case mp3
        case mp4
        case otf
        case ttf
        case png
        case zip
        case json
        case AnchorVideo

        var fileName: String {
            rawValue
        }

        var ext: String {
            return self == .AnchorVideo ? "mp4" : rawValue
        }
    }

    /// Download files
    /// - Parameters:
    ///   - name: fileName
    ///   - url: file url
    ///   - isRetryFile: Indicate whether to enable repeated downloads until successful download. default *true*
    static func awaitDownloadFile(name: String, url: String, isRetryFile: Bool = true) async -> Bool {
        if FileManager.default.fileExists(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(name).path) {
            let fontArray = getCachedFiles(fileName: "Font")
            fontArray.filter {
                $0.path.hasSuffix("ttf")
            }.forEach {
                let fontData = NSData(contentsOfFile: $0.path) ?? NSData()
                var error: Unmanaged<CFError>?
                guard let ref = CGDataProvider(data: fontData) else { return }
                guard let font = CGFont(ref) else { return }
                CTFontManagerRegisterGraphicsFont(font, &error)
            }
            return true
        }
        let result = await withCheckedContinuation { continuation in
            loadSource(name: name, url: url)
                .done { result in
                    continuation.resume(returning: result)
                }
                .catch { _ in
                    continuation.resume(returning: false)
                }
        }
        if isRetryFile {
            /// open retry download
            return result ? result : await awaitDownloadFile(name: name, url: url, isRetryFile: isRetryFile)
        } else {
            return result
        }
    }

    static func loadSource(name: String, url: String) -> Promise<Bool> {
        Promise { seal in
            if let urlPath = filePath(name: name, type: .zip), let url = url.toURL {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(name)
                if getCachedFiles(fileName: name).isEmpty {
                    AF.download(url, to: { _, _ in
                        (urlPath, [.removePreviousFile, .createIntermediateDirectories])
                    }).responseURL { response in
                        let fileManager = FileManager()
                        do {
                            try fileManager.unzipItem(at: urlPath, to: documentsDirectory)
                            let fontArray = getCachedFiles(fileName: "Font")
                            fontArray.filter {
                                $0.path.hasSuffix("ttf")
                            }.forEach {
                                let fontData = NSData(contentsOfFile: $0.path) ?? NSData()
                                var error: Unmanaged<CFError>?
                                guard let ref = CGDataProvider(data: fontData) else { return }
                                guard let font = CGFont(ref) else { return }
                                CTFontManagerRegisterGraphicsFont(font, &error)
                            }
                            seal.fulfill(true)
                        } catch {
                            print("Extraction of ZIP archive failed with error:\(error)")
                            seal.fulfill(false)
                        }
//                        try? Zip.unzipFile(urlPath, destination: documentsDirectory, overwrite: true, password: nil, progress: { progress in
//                            let fontArray = getCachedFiles(fileName: "Font")
//                            fontArray.filter {
//                                $0.path.hasSuffix("ttf")
//                            }.forEach {
//                                let fontData = NSData(contentsOfFile: $0.path) ?? NSData()
//                                var error: Unmanaged<CFError>?
//                                guard let ref = CGDataProvider(data: fontData) else { return }
//                                guard let font = CGFont(ref) else { return }
//                                CTFontManagerRegisterGraphicsFont(font, &error)
//                            }
//                            seal.fulfill(true)
//                        })
                    }
                } else {
                    let fileManager = FileManager()
                    do {
                        try fileManager.unzipItem(at: urlPath, to: documentsDirectory)
                        let fontArray = getCachedFiles(fileName: "Font")
                        fontArray.filter {
                            $0.path.hasSuffix("ttf")
                        }.forEach {
                            let fontData = NSData(contentsOfFile: $0.path) ?? NSData()
                            var error: Unmanaged<CFError>?
                            guard let ref = CGDataProvider(data: fontData) else { return }
                            guard let font = CGFont(ref) else { return }
                            CTFontManagerRegisterGraphicsFont(font, &error)
                        }
                        seal.fulfill(true)
                    } catch {
                        print("Extraction of ZIP archive failed with error:\(error)")
                        seal.fulfill(false)
                    }
//                    try? Zip.unzipFile(urlPath, destination: documentsDirectory, overwrite: true, password: nil, progress: { progress in
//                        if progress == 1 {
//                            let fontArray = getCachedFiles(fileName: "Font")
//                            fontArray.filter {
//                                $0.path.hasSuffix("ttf")
//                            }.forEach {
//                                let fontData = NSData(contentsOfFile: $0.path) ?? NSData()
//                                var error: Unmanaged<CFError>?
//                                guard let ref = CGDataProvider(data: fontData) else { return }
//                                guard let font = CGFont(ref) else { return }
//                                CTFontManagerRegisterGraphicsFont(font, &error)
//                            }
//                            seal.fulfill(true)
//                        }
//                    })
                }
            } else {
                seal.fulfill(false)
            }
        }
    }

    static func initialize(model: SessionResponseInitConfigModel) {
        saveObject(urlString: model.DEF_SDK_RES_COUNTRY_JSON, name: "Region", type: .json)
        saveObject(urlString: model.LoginResource, name: "LoginResource", type: .mp4)
        saveObject(urlString: model.NewuserResource, name: "NewuserResource", type: .mp4)
    }

    static func saveObject(urlString: String, name: String, type: LoaferStorageType, completion: ((_ url: URL?) -> Void)? = nil) {
        guard !checkFileExists(name: name, type: type) else { return }
        guard let urlPath = filePath(name: name, type: type) else { return }
        if let url = urlString.toURL {
            _ = AF.download(url, to: { _, _ in
                (urlPath, [.removePreviousFile, .createIntermediateDirectories])
            }).responseURL { response in
                switch response.result {
                case .success(let url):
                    completion?(url)
                default:
                    completion?(nil)
                }
            }
        }
    }

    static func queryObject(name: String, type: LoaferStorageType) -> URL? {
        guard let urlPath = filePath(name: name, type: type) else { return nil }
        if FileManager.default.fileExists(atPath: urlPath.path) { return urlPath }
        return nil
    }

    private static func checkFileExists(name: String, type: LoaferStorageType) -> Bool {
        guard let urlPath = filePath(name: name, type: type) else { return false }
        if FileManager.default.fileExists(atPath: urlPath.path) { return true }
        return false
    }

    private static func filePath(name: String, type: LoaferStorageType) -> URL? {
        guard let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                      appropriateFor: nil, create: true).appendingPathComponent(type.fileName, isDirectory: true) else { return nil }
        return path.appendingPathComponent(name + "." + type.ext)
    }

    static func getCachedFiles(fileName: String) -> [URL] {
        let fileManager = FileManager.default
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("LoaferResource").appendingPathComponent("LoaferSource").appendingPathComponent(fileName)

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            return fileURLs
        } catch {
            return []
        }
    }
}
