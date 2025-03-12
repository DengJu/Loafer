
import PromiseKit
import KakaJSON
import UIKit
import CryptoSwift
//import Alamofire

protocol URLSesstionProviderWrapper {
    
    associatedtype Target: SessionInterfaceType
    
    /// Use this API when response is ** String **
    /// - Parameter target: Target
    /// - Returns: ** Any Object **
    func request(_ target: Target) -> Promise<SessionResponseResult<Any>>
    
    /// Use this API when response is ** Dictionary **
    /// - Parameters:
    ///   - target: Interface API
    ///   - type: Parse Type Data
    /// - Returns: ** Element **
    func request<Element: Convertible>(_ target: Target, type: Element.Type) -> Promise<SessionResponseResult<Element>>
    
    /// Use this API when response is ** Array **
    /// - Parameters:
    ///   - target: Interface API
    ///   - type: Parse Type Data
    /// - Returns: ** Array<[Element]> **
    func request<Element: Convertible>(_ target: Target, type: [Element].Type) -> Promise<SessionResponseResult<[Element]>>
    
    
    /// Upload file
    /// - Parameter target: Interface API
    /// - Returns: ** [String: Any] **
    func uploadFile(_ target: Target, mediaType: SessionTransportFileType) -> Promise<SessionResponseResult<SessionResponseUploadFileModel>>
}

let URLSessionProvider = URLSesstionProvider<URLSessionInterface>()

struct URLSesstionProvider<T: SessionInterfaceType>: URLSesstionProviderWrapper {
    
    typealias Target = T
    init() {}
    
    /// Use this API when response is ** String **
    /// - Parameter target: Target
    /// - Returns: ** Any Object **
    @discardableResult
    func request(_ target: Target) -> Promise<SessionResponseResult<Any>> {
        return Promise { seal in
            guard let request = target.sessionRequest else { return }
            if target.sessionIsHideLogButTokenNil {
                UIApplication.mainWindow.rootViewController = BasicNavigationPage(rootViewController: RegisterPage())
                return
            }
            AF.request(request).responseString { response in
                if case .success(let responseObject) = response.result {
                    if let data = Data(base64Encoded: responseObject, options: .ignoreUnknownCharacters), let decodeArrayData = try? AES(key: LoaferAppSettings.URLSettings.PUBLICKEY, iv: LoaferAppSettings.URLSettings.IV, padding: .pkcs5).decrypt(data.bytes), let decodeString = String(data: Data(decodeArrayData), encoding: .utf8) {
                        guard let decryptModel = model(from: decodeString, SessionResponse<Any>.self) else { return }
                        guard decryptModel.code == 200 else {
                            defer {
                                seal.reject(EMError.HttpResponseError.httpResponse(code: decryptModel.code, message: decryptModel.msg))
                            }
                            if decryptModel.code == 401 || decryptModel.code == 1004 {
                                UIApplication.mainWindow.rootViewController = BasicNavigationPage(rootViewController: RegisterPage())
                            }
                            if decryptModel.code == 1005 {
                                // TODO: -
//                                PopUtil.pop(show: GetGemsPage())
                            }
                            return
                        }
                        seal.fulfill(.success(models: decryptModel.data))
                    }else {
                        seal.reject(EMError.HttpResponseError.decryptFailure)
                    }
                }
                if case .failure(let error) = response.result {
                    if let underlyingError = error.underlyingError, let urlError = underlyingError as? URLError {
                        if urlError.code == .networkConnectionLost || urlError.code == .cannotLoadFromNetwork || urlError.code == .timedOut {
                            AF.cancelAllRequests()
                            ToastTool.show(.failure, "Network Connection Lost")
                            seal.reject(error)
                        }
                    }else {
                        seal.reject(error)
                    }
                }
            }
        }
    }
    
    /// Use this API when response is ** Dictionary **
    /// - Parameters:
    ///   - target: Interface API
    ///   - type: Parse Type Data
    /// - Returns: ** Element **
    @discardableResult
    func request<Element: Convertible>(_ target: Target, type: Element.Type) -> Promise<SessionResponseResult<Element>> {
        return Promise { seal in
            guard let request = target.sessionRequest else { return }
            if target.sessionIsHideLogButTokenNil {
                UIApplication.mainWindow.rootViewController = BasicNavigationPage(rootViewController: RegisterPage())
                return
            }
            AF.request(request).responseString { response in
                if case .success(let responseObject) = response.result {
                    if let data = Data(base64Encoded: responseObject, options: .ignoreUnknownCharacters), let decodeArrayData = try? AES(key: LoaferAppSettings.URLSettings.PUBLICKEY, iv: LoaferAppSettings.URLSettings.IV, padding: .pkcs5).decrypt(data.bytes), let decodeString = String(data: Data(decodeArrayData), encoding: .utf8) {
                        guard let decryptModel = model(from: decodeString, SessionResponse<Element>.self) else { return }
                        guard decryptModel.code == 200 else {
                            defer {
                                seal.reject(EMError.HttpResponseError.httpResponse(code: decryptModel.code, message: decryptModel.msg))
                            }
                            if decryptModel.code == 401 || decryptModel.code == 1004 {
                                UIApplication.mainWindow.rootViewController = BasicNavigationPage(rootViewController: RegisterPage())
                            }
                            if decryptModel.code == 1005 {
                                // TODO: -
//                                PopUtil.pop(show: GetGemsPage())
                            }
                            return
                        }
                        seal.fulfill(.success(models: decryptModel.data))
                    }else {
                        seal.reject(EMError.HttpResponseError.decryptFailure)
                    }
                }
                if case .failure(let error) = response.result {
                    if let underlyingError = error.underlyingError, let urlError = underlyingError as? URLError {
                        if urlError.code == .networkConnectionLost || urlError.code == .cannotLoadFromNetwork || urlError.code == .timedOut {
                            AF.cancelAllRequests()
                            ToastTool.show(.failure, "Network Connection Lost")
                            seal.reject(error)
                        }
                    }else {
                        seal.reject(error)
                    }
                }
            }
        }
    }
    
    /// Use this API when response is ** Array **
    /// - Parameters:
    ///   - target: Interface API
    ///   - type: Parse Type Data
    /// - Returns: ** Array<[Element]> **
    @discardableResult
    func request<Element: Convertible>(_ target: Target, type: [Element].Type) -> Promise<SessionResponseResult<[Element]>> {
        return Promise { seal in
            guard let request = target.sessionRequest else { return }
            if target.sessionIsHideLogButTokenNil {
                UIApplication.mainWindow.rootViewController = BasicNavigationPage(rootViewController: RegisterPage())
                return
            }
            AF.request(request).responseString { response in
                if case .success(let responseObject) = response.result {
                    if let data = Data(base64Encoded: responseObject, options: .ignoreUnknownCharacters), let decodeArrayData = try? AES(key: LoaferAppSettings.URLSettings.PUBLICKEY, iv: LoaferAppSettings.URLSettings.IV, padding: .pkcs5).decrypt(data.bytes), let decodeString = String(data: Data(decodeArrayData), encoding: .utf8) {
                        guard let decryptModel = model(from: decodeString, SessionResponse<[Element]>.self) else { return }
                        guard decryptModel.code == 200 else {
                            defer {
                                seal.reject(EMError.HttpResponseError.httpResponse(code: decryptModel.code, message: decryptModel.msg))
                            }
                            if decryptModel.code == 401 || decryptModel.code == 1004 {
                                UIApplication.mainWindow.rootViewController = BasicNavigationPage(rootViewController: RegisterPage())
                            }
                            if decryptModel.code == 1005 {
                                // TODO: -
//                                PopUtil.pop(show: GetGemsPage())
                            }
                            return
                        }
                        seal.fulfill(.success(models: decryptModel.data))
                    }else {
                        seal.reject(EMError.HttpResponseError.decryptFailure)
                    }
                }
                if case .failure(let error) = response.result {
                    if let underlyingError = error.underlyingError, let urlError = underlyingError as? URLError {
                        if urlError.code == .networkConnectionLost || urlError.code == .cannotLoadFromNetwork || urlError.code == .timedOut {
                            AF.cancelAllRequests()
                            ToastTool.show(.failure, "Network Connection Lost")
                            seal.reject(error)
                        }
                    }else {
                        seal.reject(error)
                    }
                }
            }
        }
    }
    
    @discardableResult
    func uploadFile(_ target: Target, mediaType: SessionTransportFileType) -> Promise<SessionResponseResult<SessionResponseUploadFileModel>> {
        return Promise { seal in
            request(target, type: SessionResponseUploadFileModel.self)
                .compactMap { $0.data }
                .done { fileModel in
                    beginUpload(media: mediaType, model: fileModel) { error in
                        if let error {
                            seal.reject(error)
                        } else {
                            seal.fulfill(.success(models: fileModel))
                        }
                    }
                }
                .catch { error in
                    seal.reject(error)
                }
        }
    }
    
    private func beginUpload(media: SessionTransportFileType, model: SessionResponseUploadFileModel, completion: ((_ error: Error?) -> Void)?) {
        DispatchQueue.global().sync {
            if case let .imageFile(data) = media {
                putFile(model: model, fileData: data, completion: completion)
            } else if case let .audioFile(fileUrl) = media {
                guard let fileData = try? NSData(contentsOf: fileUrl) as Data else { return }
                putFile(model: model, fileData: fileData, completion: completion)
            } else if case let .videoFile(fileUrl) = media {
                guard let fileData = try? NSData(contentsOf: fileUrl) as Data else { return }
                putFile(model: model, fileData: fileData, completion: completion)
            }
        }
    }
    
    private func putFile(model: SessionResponseUploadFileModel, fileData: Data, completion: ((_ error: Error?) -> Void)?) {
        guard let uploadUrl = URL(string: model.preUrl) else { return }
        AF.upload(fileData, to: uploadUrl, method: .put, headers: [HTTPHeader(name: "Content-Type", value: model.contentType)])
            .response { response in
                switch response.result {
                case .success:
                    completion?(nil)
                case let .failure(error):
                    completion?(error)
                }
            }
    }
    
}
