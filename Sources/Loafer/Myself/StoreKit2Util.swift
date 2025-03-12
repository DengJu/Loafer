import Foundation
import StoreKit
import KakaJSON
import RealmSwift

enum StrorePurchaseStatus: String, PersistableEnum {
    case Pending
    case Success
    case Failure
}

class StroreOrderModel: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var originalID: String = ""
    @Persisted var appAccountToken: String = ""
    @Persisted var status: StrorePurchaseStatus = .Pending
    
    convenience init(
        id: String,
        originalID: String,
        appAccountToken: String,
        status: StrorePurchaseStatus)
    {
        self.init()
        self.id = id
        self.originalID = originalID
        self.appAccountToken = appAccountToken
        self.status = status
    }
    
}

extension StoreKit2Util {
    
    static func queryOrderInfo(id: String) -> StroreOrderModel? {
        RealmProvider.share.aRealm.objects(StroreOrderModel.self)
            .where { $0.id == id }
            .first
    }
    
    static func updateOrderStatus(id: String, status: StrorePurchaseStatus) {
        guard let order = queryOrderInfo(id: id) else { return }
        RealmProvider.share.openTransaction { _ in
            order.status = status
        }
    }
    
}


struct StoreKit2Util {
    
    static var rechargeType: InsufficientBalanceType = .default
    
    static private var currentProduct: SessionResponseGemsListModel = SessionResponseGemsListModel()
    
    static func purchase(_ productModel: SessionResponseGemsListModel) async {
        do {
            ToastTool.show()
            let productIds: Set<String> = [productModel.productCode]
            let products = try await Mercato.retrieveProducts(productIds: productIds)
            guard let product = products.first else {
                ToastTool.show(.failure, "Product is not exist!")
                return
            }
            currentProduct = productModel
            let result = try await Mercato.purchase(product: product, quantity: 1, finishAutomatically: false, appAccountToken: UUID(uuidString: "\(LoaferAppSettings.UserInfo.user.userId)"), simulatesAskToBuyInSandbox: false)
            checkOrderIsNeedToVerificationFromService(transaction: result.transaction)
        }catch let error {
            if error == MercatoError.purchaseCanceledByUser || error == StoreKitError.userCancelled {
                ToastTool.show(.failure, "Cancelled")
            }else {
                ToastTool.show(.failure, error.localizedDescription)
            }
        }
    }
    
    static func restore() async {
        do {
            ToastTool.show()
            try await Mercato.restorePurchases()
            ToastTool.dismiss()
        }catch {
            ToastTool.show(.failure, error._domain)
        }
    }
    
    static func refund(_ productId: String) async {
        guard let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        do {
            try await Mercato.beginRefundProcess(for: productId, in: scene)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    static func checkOrderIsNeedToVerificationFromService(transaction: Transaction) {
        DispatchQueue.main.async {
            if let order = queryOrderInfo(id: "\(transaction.id)") {
                if order.status == .Success {
                    return
                }
            }else {
                let orderModel = StroreOrderModel(id: "\(transaction.id)", originalID: "\(transaction.originalID)", appAccountToken: "\(LoaferAppSettings.UserInfo.user.userId)", status: .Pending)
                RealmProvider.share.openTransaction { realm in
                    realm.add(orderModel)
                }
            }
            verifyReceiptFromServer(transaction: transaction)
        }
    }
    
    static func verifyReceiptFromServer(transaction: Transaction) {
        URLSessionProvider.request(.URLInterfaceVerifyData(model: SessionRequestVerifyDataModel(transactionId: "\(transaction.id)", originalTransactionId: "\(transaction.originalID)")), type: SessionResponseTransactionResponse.self)
            .compactMap({ $0.data })
            .done { result in
                Task {
                    await transaction.finish()
                }
                LoaferAppSettings.Gems.avtiveItems = nil
                if !LoaferAppSettings.UserInfo.user.isRecharge {
                    LoaferAppSettings.UserInfo.user.isRecharge = true
                    NotificationCenter.default.post(name: NSNotification.Name("REFRESH-HOST-ONLINESTATUS"), object: nil)
                }
                LoaferAppSettings.UserInfo.user.coinBalance = Int32(result.totalCoin)
                if StoreKit2Util.currentProduct.rechargeCount == 1 {
                    LoaferAppSettings.Gems.data.removeAll(where: {$0.productCode == StoreKit2Util.currentProduct.productCode})
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REFRESH-USER-BALANCE"), object: result.totalCoin)
                ToastTool.show(.success, "Buy Successfully!")
                DispatchQueue.main.async {
                    updateOrderStatus(id: "\(transaction.id)", status: .Success)
                    if let aView = StoreKit2Util.rechargeType.lastPopView {
                        PopUtil.pop(show: aView)
                    }
                    if case let .CallPre(hostModel) = StoreKit2Util.rechargeType {
                        CallUtil.call(to: hostModel.userId)
                    }
                    StoreKit2Util.rechargeType = .default
                }
            }
            .catch { error in
                DispatchQueue.main.async {
                    StoreKit2Util.rechargeType = .default
                    updateOrderStatus(id: "\(transaction.id)", status: .Failure)
                }
                ToastTool.show(.failure, error.localizedDescription)
            }
    }
}
