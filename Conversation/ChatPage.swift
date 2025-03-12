
import UIKit
import RealmSwift

class ChatPage: LoaferPage, SourceProtocol {
    
    typealias SourceData = IMSocketConversationSaveItem
    
    func setSourceData(_ t: IMSocketConversationSaveItem) {
        conversation = t
        if let hostInfo = t.anchorModel {
            titleView.setSourceData(hostInfo)
            responderView.setSourceData(hostInfo)
        }
        RealmProvider.share.clearAllUnreadMessageCount(from: t.conversationId)
        messages = RealmProvider.share.queryMessages(from: t.conversationId)
        debugPrint(messages)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            guard self.messages.count > 0, self.tableView.numberOfRows(inSection: 0) > 0 else { return }
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .none, animated: false)
        }
        observeMessageChange()
    }
    
    override var prefersNavigationBarHidden: Bool { true }
    
    private let titleView = ChatTitleView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let responderView = ChatResponderView()
    private var messages: [IMSocketMessageSaveItem] = []
    var conversation: IMSocketConversationSaveItem?
    private var messageToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews {
            titleView
            tableView
            responderView
        }
        view.layout {
            UIDevice.safeTop
            |titleView| ~ 44.FIT
            0
            |tableView|
            0
            |responderView| ~ 80.FIT
            0
        }
        tableView
            .loafer_backColor(.clear)
            .loafer_separatorStyle(.none)
            .loafer_delegate(self)
            .loafer_dataSource(self)
            .loafer_register(ChatTextCell.self, ChatTextCell.description())
            .loafer_register(ChatPhotoCell.self, ChatPhotoCell.description())
            .loafer_register(ChatCallCell.self, ChatCallCell.description())
            .loafer_register(ChatGiftCell.self, ChatGiftCell.description())
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "BLOCK-USER-NOTIFICATION"), object: nil, queue: .main) {[weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func observeMessageChange() {
        guard let conversation else { return }
        let result = RealmProvider.share.aRealm
            .objects(IMSocketMessageSaveItem.self)
            .where { $0.conversationId == conversation.conversationId }
            .sorted(by: \.times)
        messageToken = result.observe { [weak self] changes in
            guard let `self` = self else { return }
            switch changes {
            case .initial: break
            case .update(_, _, _, _):
                RealmProvider.share.clearAllUnreadMessageCount(from: conversation.conversationId)
                self.messages = RealmProvider.share.queryMessages(from: conversation.conversationId)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    guard self.messages.count > 0, self.tableView.numberOfRows(inSection: 0) > 0 else { return }
                    self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .none, animated: false)
                }
                if let page = UIApplication.mainWindow.rootViewController as? LoaferTabBarPage {
                    page.refreshUnreadCount()
                }
            case let .error(error):
                debugPrint(error)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.enable = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - observe keyboard

    @objc private func keyboard(notification: Notification) {
        let userInfo = notification.userInfo
        let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let value = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if notification.name == UIResponder.keyboardWillShowNotification {
            responderView.bottomConstraint?.constant = -value.height
            UIView.animate(withDuration: duration) { [weak self] in
                self?.view.layoutIfNeeded()
            }
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self, strongSelf.messages.count > 0, strongSelf.tableView.numberOfRows(inSection: 0) > 0 else { return }
                strongSelf.tableView.scrollToRow(at: IndexPath(row: strongSelf.messages.count - 1, section: 0), at: .none, animated: false)
            }
        } else {
            responderView.bottomConstraint?.constant = 0
            UIView.animate(withDuration: duration) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
}

extension ChatPage: UITableViewDelegate & UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = messages[indexPath.row]
        var appearTime = 0
        if indexPath.row == 0 {
            appearTime = Int(model.times)
        } else {
            let lastTime = messages[indexPath.row - 1].times
            if model.times >= lastTime + 300_000 {
                appearTime = Int(model.times)
            } else {
                appearTime = 0
            }
        }
        if model.contentType == IMSocketMessageBodyType.TEXT.rawValue {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatTextCell.description()) as? ChatTextCell else { return UITableViewCell() }
            cell.setSourceData((model, conversation?.anchorModel))
            cell.appearTime = appearTime
            return cell
        }
        if model.contentType == IMSocketMessageBodyType.IMAGE.rawValue {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatPhotoCell.description()) as? ChatPhotoCell else { return UITableViewCell() }
            cell.setSourceData((model, conversation?.anchorModel))
            cell.appearTime = appearTime
            return cell
        }
        if model.contentType == IMSocketMessageBodyType.CALLEVENT.rawValue {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCallCell.description()) as? ChatCallCell else { return UITableViewCell() }
            cell.setSourceData((model, conversation?.anchorModel))
            cell.appearTime = appearTime
            return cell
        }
        if model.contentType == IMSocketMessageBodyType.GIFT.rawValue {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatGiftCell.description()) as? ChatGiftCell else { return UITableViewCell() }
            cell.setSourceData((model, conversation?.anchorModel))
            cell.appearTime = appearTime
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = messages[indexPath.row]
        if model.contentType == IMSocketMessageBodyType.CALLEVENT.rawValue {
            guard let hostModel = conversation?.anchorModel else { return }
            if LoaferAppSettings.UserInfo.user.coinBalance < hostModel.callPrice {
                // TODO: -
//                PopuoSession.popup(show: InsufficientBalanceView(callCoins: hostModel.callPrice), isFloating: false)
            }else {
                CallUtil.call(to: hostModel.userId)
            }
        }
    }
    
}
