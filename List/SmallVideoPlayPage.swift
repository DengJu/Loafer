
import UIKit
import AVFoundation

class SmallVideoPlayPage: LoaferPage, SourceProtocol {
    
    func setSourceData(_ data: (SessionResponseHostListModel, SessionResponseHostVideoModel)) {
        hostModel = data.0
        videoModel = data.1
        nameView.loafer_text(data.0.nickname)
        descView.loafer_text(data.0.signature)
        nameView.setShadowText()
        descView.setShadowText()
        likeButton.loafer_isSelect(data.1.isLike)
        likePersonLabel.loafer_text("\(data.1.likeNum)")
        if data.1.cover.isEmpty {
            videoView.preImageView.loadImage(url: data.0.avatar, blur: 30.FIT)
        }else {
            videoView.preImageView.loadImage(url: data.1.cover, blur: 30.FIT)
        }
        connectBtn.loafer_isSelect(data.0.onlineStatus == 0)
        if data.1.isPay {
            blurStackView.loafer_isHidden(true)
            if let url = LoaferStorage.queryObject(name: "LoaferAnchorVideo_\(data.0.userId)_\(data.1.videoId)", type: .AnchorVideo) {
                playVideo(of: url)
            } else {
                LoaferStorage.saveObject(urlString: data.1.videoUrl, name: "LoaferAnchorVideo_\(data.0.userId)_\(data.1.videoId)", type: .AnchorVideo) {[weak self] aUrl in
                    if let url = aUrl {
                        self?.playVideo(of: url)
                    }
                }
            }
        }else {
            lockLabel.loafer_text("\(data.1.coin) coins to unlock.")
            lockLabel.setShadowText()
        }
    }
    
    private var videoModel: SessionResponseHostVideoModel?
    private var hostModel: SessionResponseHostListModel = SessionResponseHostListModel()
    private let videoView = LoaferVideoView()
    private let nameView = UILabel()
    private let nameStackView = UIStackView()
    private let statusView = UIView()
    private let descView = UILabel()
    private let funcStackView = UIStackView()
    private let connectBtn = UIButton(type: .custom)
    private let giftButton = UIButton(type: .custom)
    private let likeView = UIView()
    private let likeButton = UIButton(type: .custom)
    private let likePersonLabel = UILabel()
    private let blurStackView = UIStackView()
    private let lockLabel = UILabel()
    private let unlockBtn = UIButton(type: .custom)
    var unlockVideoClosure: ((_ video: SessionResponseHostVideoModel) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews {
            videoView
            blurStackView
            nameStackView
            descView
            funcStackView
        }
        likeView.subviews {
            likeButton
            likePersonLabel
        }
        likeView.layout {
            0
            |likeButton.size(50.FIT)|
            0
            |likePersonLabel|
            0
        }
        videoView.fillContainer()
        blurStackView.centerHorizontally().centerVertically(offset: -80.FIT)
        descView.bottom(UIDevice.safeBottom).leading(20.FIT).trailing(20.FIT)
        nameStackView.leading(20.FIT).height(30.FIT)
        nameStackView.Bottom == descView.Top - 5.FIT
        funcStackView.Bottom == nameStackView.Top
        funcStackView.trailing(15.FIT).width(50.FIT)
        
        lockLabel.height(20.FIT)
        blurStackView.addArrangedSubview(lockLabel)
        unlockBtn.width(UIDevice.screenWidth-70.FIT).height(50.FIT)
        blurStackView.addArrangedSubview(unlockBtn)
        
        nameStackView
            .loafer_axis(.horizontal)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalCentering)
        descView
            .loafer_font(14, .medium)
            .loafer_textColor("FFFFFF")
            .loafer_numberOfLines(0)
        funcStackView
            .loafer_axis(.vertical)
            .loafer_spacing(15.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalSpacing)
        likeView.width(50.FIT).height(70.FIT)
        giftButton.size(50.FIT)
        connectBtn.size(50.FIT)
        funcStackView.addArrangedSubview(likeView)
        funcStackView.addArrangedSubview(giftButton)
        funcStackView.addArrangedSubview(connectBtn)
        nameStackView.addArrangedSubview(nameView)
        statusView.size(14.FIT)
        nameStackView.addArrangedSubview(statusView)
        nameView
            .loafer_font(24, .bold)
            .loafer_textColor("FFFFFF")
        statusView
            .loafer_backColor("29DD52")
            .loafer_cornerRadius(7.FIT)
            .loafer_border("FFFFFF", 1.FIT)
        connectBtn
            .loafer_image("Loafer_SmallVideoPlayPage_Chat")
            .loafer_image("Loafer_SmallVideoPlayPage_VideoCall", .selected)
            .loafer_target(self, selector: #selector(loaferSmallVideoPlayConnectPage(_:)))
        giftButton
            .loafer_image("Loafer_SmallVideoPlayPage_Gift")
            .loafer_target(self, selector: #selector(loaferSmallVideoPlayGiftPage))
        likeButton
            .loafer_image("Loafer_SmallVideoPlayPage_Like_Normal")
            .loafer_image("Loafer_SmallVideoPlayPage_Like_Select", .selected)
            .loafer_target(self, selector: #selector(loaferSmallVideoPlayLikePage(_:)))
        likePersonLabel
            .loafer_font(12, .bold)
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
        lockLabel
            .loafer_font(16, .bold)
            .loafer_textColor("FFFFFF", 0.8)
        blurStackView
            .loafer_axis(.vertical)
            .loafer_spacing(20.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalSpacing)
        unlockBtn
            .loafer_cornerRadius(25.FIT)
            .loafer_titleColor("FFFFFF")
            .loafer_text("Unlock")
            .loafer_font(20, .bold)
            .loafer_target(self, selector: #selector(loaferSmallVideoPlayPageUnlockBtn(_:)))
            .setGrandient(color: .themeColor(direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: UIDevice.screenWidth-70.FIT, height: 50.FIT))
    }
    
    @objc private func loaferSmallVideoPlayPageUnlockBtn(_ sender: UIButton) {
        guard let videoModel else { return }
        if LoaferAppSettings.UserInfo.user.coinBalance < videoModel.coin {
            InsufficientPolicy.insufficientPop(type: .UnlockVideo(hostModel: hostModel, videoModel: videoModel))
            return
        }
        ToastTool.show()
        sender.isUserInteractionEnabled = false
        URLSessionProvider.request(.URLInterfaceUnlockVideo(model: SessionRequestBuyVideoModel(videoId: videoModel.videoId)), type: SessionResponseHostVideoModel.self)
            .compactMap({ $0.data })
            .done {[weak self] result in
                ToastTool.dismiss()
                if let closure = self?.unlockVideoClosure {
                    closure(result)
                }
                self?.videoModel = result
                self?.blurStackView.isHidden = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VIDEO-UNLOCK-NOTIFICATION"), object: nil, userInfo: ["userId": self?.hostModel.userId ?? 0, "videoModel": videoModel])
                if let url = LoaferStorage.queryObject(name: "LoaferAnchorVideo_\(self?.hostModel.userId ?? 0)_\(videoModel.videoId)", type: .AnchorVideo) {
                    self?.playVideo(of: url)
                } else {
                    if let url = videoModel.videoUrl.toURL {
                        self?.playVideo(of: url)
                    }
                }
                sender.isUserInteractionEnabled = true
            }
            .catch { error in
                error.handle()
                sender.isUserInteractionEnabled = true
            }
    }
    
    private func playVideo(of url: URL) {
        videoView.url = url
        videoView.removeReachEndObserver()
        videoView.play()
    }
    
    @objc private func loaferSmallVideoPlayConnectPage(_ sender: UIButton) {
        if sender.isSelected {
            if LoaferAppSettings.UserInfo.user.coinBalance < hostModel.callPrice {
                InsufficientPolicy.insufficientPop(type: .CallPre(hostModel: hostModel))
            }else {
                videoView.pause()
                LoaferAppSettings.AOP.callSource = "小视频列表"
                CallUtil.call(to: hostModel.userId)
            }
        }else {
            videoView.pause()
            let chatPage = ChatPage()
            let finalModel = IMSocketConversationSaveItem()
            if let conversation = RealmProvider.share.queryConversation(from: LoaferAppSettings.URLSettings.IMPRE + "\(hostModel.userId)&" + "\(LoaferAppSettings.UserInfo.user.userId)"), !conversation.userInfo.isEmpty {
                finalModel.conversationId = conversation.conversationId
                finalModel.times = conversation.times
                finalModel.sendId = conversation.sendId
                finalModel.recvId = conversation.recvId
                finalModel.latestMessageType = conversation.latestMessageType
                finalModel.latestMessageContent = conversation.latestMessageContent
                finalModel.userInfo = conversation.userInfo
            }else {
                finalModel.conversationId = LoaferAppSettings.URLSettings.IMPRE + "\(hostModel.userId)&" + "\(LoaferAppSettings.UserInfo.user.userId)"
                finalModel.times = Int64(Date().timeIntervalSince1970 * 1000)
                finalModel.sendId = LoaferAppSettings.UserInfo.user.userId
                finalModel.recvId = hostModel.userId
                finalModel.userInfo = IMSocketConversationUserInfoItem(userId: hostModel.userId, avatar: hostModel.avatar, nickname: hostModel.nickname, gender: Int(hostModel.gender), onlineStatus: Int(hostModel.onlineStatus), signature: hostModel.signature, callPrice: hostModel.callPrice).kj.JSONString()
            }
            chatPage.setSourceData(finalModel)
            navigationController?.pushViewController(chatPage, animated: true)
        }
    }
    
    @objc private func loaferSmallVideoPlayGiftPage() {
        PopUtil.pop(show: SendGiftView(hostModel: model(from: hostModel.kj.JSONObject(), IMSocketConversationUserInfoItem.self), policy: .default))
    }
    
    @objc private func loaferSmallVideoPlayLikePage(_ sender: UIButton) {
        guard let videoModel else { return }
        sender.isUserInteractionEnabled = false
        URLSessionProvider.request(.URLInterfaceLikeVideo(model: SessionRequestLikeVideoModel(videoId: videoModel.videoId)), type: SessionResponseHostVideoModel.self)
            .compactMap({ $0.data })
            .done {[weak self] result in
                guard let `self` = self else { return }
                sender.isUserInteractionEnabled = true
                sender.loafer_isSelect(result.isLike)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VIDEO-LIKE-NOTIFICATION"), object: nil, userInfo: ["videoModel": videoModel, "isLike": result.isLike, "personNum": result.likeNum])
                self.likePersonLabel.loafer_text("\(result.likeNum)")
            }
            .catch { error in
                error.handle()
                sender.isUserInteractionEnabled = true
            }
    }
    
}

class LoaferVideoView: UIView {
    public var player: AVPlayer {
        guard let player = playerLayer.player else {
            return AVPlayer()
        }
        return player
    }

    let preImageView = UIImageView(image: "Loafer_Basic_Empty".toImage)
    let videoView = UIView()
    let pauseImageView = UIImageView(image: "Loafer_SmallVideoPlayPage_Play".toImage)
    var playerItem: AVPlayerItem?
    let playerLayer = AVPlayerLayer()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let activityView = UIActivityIndicatorView(style: .medium)
    private var videoDuration: Float64 = 0.0
    
    var isHiddenProgressView: Bool = false

    var url: URL? {
        didSet {
            guard let videoUrl = url else { return }
            activityView.color = "FFFFFF".toColor
            activityView.startAnimating()
            playerItem = AVPlayerItem(url: videoUrl)
            let player = AVPlayer(url: videoUrl)
            playerLayer.player = player
            let asset = AVAsset(url: videoUrl)
            let durationInSeconds = CMTimeGetSeconds(asset.duration)
            videoDuration = durationInSeconds
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        clipsToBounds = true
        let singleTapGR = UITapGestureRecognizer(target: self,
                                                 action: #selector(singleTap))
        singleTapGR.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapGR)

        subviews {
            preImageView
            videoView
            pauseImageView
            progressView
            activityView
        }
        activityView.centerInContainer()
        preImageView.fillContainer()
        videoView.fillContainer()
        pauseImageView.fillContainer()
        progressView.leading(0).trailing(0).bottom(UIDevice.safeBottom+10.FIT).height(3.FIT)
        progressView.trackTintColor = "FAFAFA".toColor.withAlphaComponent(0.6)
        progressView.progressTintColor = "FAFAFA".toColor
        progressView.isHidden = true
        preImageView.contentMode = .scaleAspectFit
        videoView.backgroundColor = .clear
        pauseImageView.contentMode = .center
        pauseImageView.isHidden = true
        addReachEndObserver()
        playerLayer.videoGravity = .resizeAspectFill
        videoView.layer.addSublayer(playerLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    func addPeriodicTimeObserver() {
        if isHiddenProgressView {
            activityView.stopAnimating()
            return
        }
        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            DispatchQueue.main.async {
                if currentTime > 0 {
                    self?.activityView.stopAnimating()
                }
                self?.progressView.isHidden = currentTime == 0
                self?.progressView.setProgress(Float(currentTime/(self?.videoDuration ?? 0.0)), animated: true)
            }
        }
    }

    public func pauseUnpause() {
        (player.rate == 0.0) ? play() : pause()
    }

    @objc func singleTap() {
        pauseUnpause()
    }

    public func play() {
        player.play()
        addReachEndObserver()
        pauseImageView.isHidden = true
    }

    public func pause() {
        player.pause()
        pauseImageView.isHidden = false
    }

    public func stop() {
        player.pause()
        player.seek(to: CMTime.zero)
        removeReachEndObserver()
    }

    public func deallocate() {
        playerLayer.player = nil
    }

    func addReachEndObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.player.play()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.player.pause()
        }
        addPeriodicTimeObserver()
    }

    @objc func playToEndTime() {
        player.actionAtItemEnd = .none
        player.seek(to: .zero)
        player.play()
    }

    func removeReachEndObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: nil)
    }
}
