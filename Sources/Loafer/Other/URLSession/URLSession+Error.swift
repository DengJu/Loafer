
import Foundation

public enum EMError: Error {
    
    public enum HttpResponseError: Error {
        case httpResponse(code: Int, message: String)
        case decryptFailure
    }
    
    public enum AppleLoginError: Error {
        case CancelAuthorization
        case AuthorizationRequestFailed
        case InvalidAuthorizationRequest
        case FailedToProcessAuthorizationRequest
        case PrivilegeGrantFailed
        case identityTokenIsNULL
    }
    
}

extension Error {
    
    func handle() {
        DispatchQueue.main.async {
            if let e = self as? EMError.HttpResponseError {
                ToastTool.show(.failure, e.desc)
            }else if let e = self as? EMError.AppleLoginError {
                ToastTool.show(.failure, e.desc)
            }else {
                ToastTool.show(.failure, localizedDescription)
            }
        }
    }
    
}

struct EMErrorInfo<Element: Error> {

    private(set) var info: Element

    init(_ error: Element) {
        self.info = error
    }
    
}

enum SessionResponseResult<Base> {
    
    case success(models: Base?)
    case failure(error: EMErrorInfo<EMError.HttpResponseError>)

    var data: Base? {
        switch self {
        case let .success(str):
            return str
        default: return nil
        }
    }
    
    var error: EMErrorInfo<EMError.HttpResponseError>? {
        switch self {
        case .failure(let error):
            return error
        default: return nil
        }
    }
}

extension EMError.HttpResponseError {
    
    var code: Int {
        switch self {
        case .httpResponse(let code, _):
            return code
        case .decryptFailure:
            return 999
        }
    }
    
    var desc: String {
        switch self {
        case .httpResponse(_, let message):
            return message
        case .decryptFailure:
            return "Response Body Decrypt Failure!"
        }
    }
    
}

extension EMError.AppleLoginError {
    
    var code: Int {
        switch self {
        case .CancelAuthorization: return 9001
        case .AuthorizationRequestFailed: return 9002
        case .InvalidAuthorizationRequest: return 9003
        case .FailedToProcessAuthorizationRequest: return 9004
        case .PrivilegeGrantFailed: return 9005
        case .identityTokenIsNULL: return 9006
        }
    }
    
    var desc: String {
        switch self {
        case .CancelAuthorization: return "Cancel authorization!"
        case .AuthorizationRequestFailed: return "Authorization request failed!"
        case .InvalidAuthorizationRequest: return "Invalid authorization request!"
        case .FailedToProcessAuthorizationRequest: return "Failed to process authorization request!"
        case .PrivilegeGrantFailed: return "Privilege grant failed!"
        case .identityTokenIsNULL: return "identity token is NULL!"
        }
    }
    
}
