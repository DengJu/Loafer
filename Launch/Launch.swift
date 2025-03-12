
import UIKit

public struct LoaferLaunch {
    
    static public func launch(with url: String, package: String) async -> Bool {
        guard !url.isEmpty else { fatalError("\n*** [Loafer - [\(#file)] - [ \(#function) ]] - {The url can not empty!}") }
        guard !package.isEmpty else { fatalError("\n*** [Loafer - [\(#file)] - [ \(#function) ]] - {The package can not empty!}") }
        LoaferAppSettings.LaunchOptions.URL = url
        LoaferAppSettings.LaunchOptions.Package = package
        guard await LoaferStorage.awaitDownloadFile(name: "LoaferResource", url: "https://file.soulrelase.com/prod/res/LoaferSource.zip") else {
            return false
        }
        let canEnter = await withCheckedContinuation { checkResult in
            URLSessionProvider.request(.URLInterfaceInit(model: SessionRequestInitModel()), type: SessionResponseInit.self)
                .compactMap { $0.data }
                .done { result in
                    LoaferStorage.initialize(model: result.configs)
                    checkResult.resume(returning: result.configs.DEF_OPERATIONAL_STATUS > 1)
                }
                .catch { error in
                    checkResult.resume(returning: false)
                }
        }
        if canEnter {
            MainNavAppearance().configure()
            URLSessionProvider.request(.URLInterfaceDict(model: SessionRequestInitModel(dictTypes: ["feedback_type", "report_type", "follow_status", "black_status", "online_status"])), type: [SessionResponseInitDict].self)
                .compactMap { $0.data }
                .then { result in
                    result.forEach {
                        if $0.dictType == "feedback_type" {
                            LoaferAppSettings.Config.feedbackDicts = $0.dictItems
                        }
                        if $0.dictType == "report_type" {
                            LoaferAppSettings.Config.reportDicts = $0.dictItems
                        }
                    }
                    return URLSessionProvider.request(.URLInterfaceHiddenLogin, type: SessionResponseUserInfoModel.self)
                }
                .then { result in
                    return URLSessionProvider.request(.URLInterfacePonyList, type: [SessionResponsePonyModel].self)
                }
                .then { result in
                    if let data = result.data {
                        LoaferAppSettings.Pony.data = data
                    }
                    return URLSessionProvider.request(.URLInterfaceGemsList, type: [SessionResponseGemsListModel].self)
                }
                .done { result in
                    if let data = result.data {
                        LoaferAppSettings.Gems.data = data
                    }
                    DispatchQueue.main.async {
                        UIApplication.mainWindow.rootViewController = LoaferTabBarPage()
                    }
                }
                .catch { error in
                    error.handle()
                }
        }
        return canEnter
    }
    
}

