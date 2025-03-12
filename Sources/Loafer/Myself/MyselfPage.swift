
import UIKit

class MyselfPage: LoaferPage {
    
    private let meTableView = UITableView(frame: .zero, style: .plain)
    private let editBtn = UIButton(type: .custom)
    private let data: [String] = ["Friends", "Blacklist", "Feedback", "Setting"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews {
            meTableView
        }
        meTableView.fillContainer()
        editBtn.size(45.FIT)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editBtn)
        meTableView
            .loafer_delegate(self)
            .loafer_dataSource(self)
            .loafer_separatorStyle(.none)
            .loafer_backColor(.clear)
            .loafer_showsVerticalScrollIndicator(false)
            .loafer_showsHorizontalScrollIndicator(false)
            .loafer_register(MyselfInfoCell.self, MyselfInfoCell.description())
            .loafer_register(MyselfGemsCell.self, MyselfGemsCell.description())
            .loafer_register(MyselfNormalCell.self, MyselfNormalCell.description())
        editBtn
            .loafer_image("Loafer_MyselfPage_Edit")
            .loafer_target(self, selector: #selector(loaferEnterEditUserInfoButton))
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "REFRESH-USER-BALANCE"), object: nil, queue: .main) {[weak self] _ in
            self?.meTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        meTableView.reloadData()
    }
    
    @objc private func loaferEnterEditUserInfoButton() {
        navigationController?.pushViewController(MyselfEditPage(), animated: true)
    }
    
}

extension MyselfPage: UITableViewDelegate & UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MyselfInfoCell.description()) as? MyselfInfoCell else { return UITableViewCell() }
            cell.setSourceData(LoaferAppSettings.UserInfo.user)
            return cell
        }
        if indexPath.row == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MyselfGemsCell.description()) as? MyselfGemsCell else { return UITableViewCell() }
            cell.setSourceData(LoaferAppSettings.UserInfo.user)
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyselfNormalCell.description()) as? MyselfNormalCell else { return UITableViewCell() }
        cell.setSourceData(data[indexPath.row-2])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            navigationController?.pushViewController(MyselfEditPage(), animated: true)
        }else if indexPath.row == 1 {
            PopUtil.pop(show: RechargeGemsView())
        }else if indexPath.row == 2 {
            navigationController?.pushViewController(MyselfFriendsPage(), animated: true)
        }else if indexPath.row == 3 {
            navigationController?.pushViewController(MyselfBlackListPage(), animated: true)
        }else if indexPath.row == 4 {
            navigationController?.pushViewController(MyselfFeedbackPage(), animated: true)
        }else if indexPath.row == 5 {
            navigationController?.pushViewController(MyselfSettingPage(), animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100.FIT
        }
        if indexPath.row == 1 {
            return 160.FIT
        }
        return 80.FIT
    }
    
}

private class MyselfInfoCell: UITableViewCell, SourceProtocol {
    
    func setSourceData(_ data: SessionResponseUserInfoModel) {
        iconView.loadImage(url: data.avatar)
        nameView.loafer_text(data.nickname)
        IDView.loafer_text("ID:\(data.userId)")
        descView.loafer_text(data.signature)
        descView.loafer_isHidden(data.signature.isEmpty)
    }
    
    private let iconView = UIImageView(image: "Loafer_Basic_EmptyIcon".toImage)
    private let stackView = UIStackView()
    private let nameView = UILabel()
    private let IDView = UILabel()
    private let descView = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.subviews {
            iconView
            stackView
        }
        iconView.leading(20.FIT).centerVertically().size(80.FIT)
        stackView.centerVertically().leading(110.FIT).trailing(15.FIT)
        nameView.height(25.FIT)
        IDView.height(20.FIT)
        stackView.addArrangedSubview(nameView)
        stackView.addArrangedSubview(IDView)
        stackView.addArrangedSubview(descView)
        iconView
            .loafer_contentMode(.scaleAspectFill)
            .loafer_cornerRadius(25.FIT)
            .loafer_backColor(.randomColor)
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.leading)
            .loafer_distribution(.equalCentering)
            .loafer_isUserInteractionEnabled(false)
        nameView
            .loafer_textColor("FFFFFF")
            .loafer_font(20, .bold)
            .loafer_text("Name")
        IDView
            .loafer_textColor("FFFFFF", 0.46)
            .loafer_font(16, .medium)
            .loafer_text("ID:00000001")
        descView
            .loafer_textColor("FFFFFF")
            .loafer_font(14, .medium)
            .loafer_text("Your money-saving tips ha have...")
            .loafer_numberOfLines(0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class MyselfGemsCell: UITableViewCell, SourceProtocol {
    
    func setSourceData(_ data: SessionResponseUserInfoModel) {
        gemsLabel.loafer_text("\(data.coinBalance)")
    }
    
    private let backImageView = UIImageView(image: "Loafer_MyselfPage_RechargeBack".toImage)
    private let rechargeBtn = UIButton(type: .custom)
    private let coinsLabel = UILabel()
    private let gemsLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.subviews {
            backImageView.subviews {
                coinsLabel
                gemsLabel
                rechargeBtn
            }
        }
        backImageView.followEdges(contentView, top: 23.FIT, bottom: 10.FIT, leading: 15.FIT, trailing: -15.FIT)
        rechargeBtn.top(30.FIT).trailing(15.FIT).height(40.FIT).width(110.FIT)
        gemsLabel.top(25.FIT).leading(15.FIT).height(36.FIT)
        coinsLabel.Top == gemsLabel.Bottom + 5.FIT
        coinsLabel.height(16.FIT).leading(15.FIT)
        gemsLabel
            .loafer_font(30, .bold)
            .loafer_text("0")
            .loafer_textColor("FFFFFF")
        coinsLabel
            .loafer_font(13, .medium)
            .loafer_text("My Coins")
            .loafer_textColor("FFFFFF")
        rechargeBtn
            .loafer_font(17, .bold)
            .loafer_cornerRadius(20.FIT)
            .loafer_backColor("FFFFFF")
            .loafer_text("Recharge")
            .loafer_titleColor("FF269C")
            .loafer_isUserInteractionEnabled(false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class MyselfNormalCell: UITableViewCell, SourceProtocol {
    
    typealias SourceData = String
    private let stackView = UIStackView()
    private let iconView = UIImageView()
    private let nameView = UILabel()
    private let nextView = UIImageView(image: "Loafer_MyselfPage_Next".toImage)
    
    func setSourceData(_ data: String) {
        iconView.loafer_image("Loafer_MyselfPage_" + data)
        nameView.loafer_text(data)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.subviews(stackView)
        stackView.followEdges(contentView, leading: 15.FIT, trailing: -15.FIT)
        iconView.size(40.FIT)
        nextView.width(12.FIT).height(22.FIT)
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(nameView)
        stackView.addArrangedSubview(nextView)
        stackView
            .loafer_axis(.horizontal)
            .loafer_spacing(5.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.fill)
            .loafer_isUserInteractionEnabled(false)
        nameView
            .loafer_textColor("FFFFFF")
            .loafer_font(19, .semiBold)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
