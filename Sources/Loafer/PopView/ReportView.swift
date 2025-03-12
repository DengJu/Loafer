
import UIKit

class ReportView: UIView {
    
    private let titleView = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let cancelBtn = UIButton(type: .custom)
    private let submitBtn = UIButton(type: .custom)
    private(set) var userId: Int64 = 0
    private var currentIndex: Int = 0
    
    init(userId: Int64) {
        super.init(frame: .zero)
        self.userId = userId
        loafer_cornerRadius(27.FIT)
        loafer_backColor("46133E")
        subviews {
            titleView
            tableView
            cancelBtn
            submitBtn
        }
        layout {
            0
            |titleView| ~ 50.FIT
            0
            |tableView|
            20.FIT
            |-20.FIT-cancelBtn-15.FIT-submitBtn-20.FIT-| ~ 50.FIT
            20.FIT
        }
        equal(widths: [cancelBtn, submitBtn])
        titleView
            .loafer_font(20, .bold)
            .loafer_text("Report user")
            .loafer_textColor("FFFFFF")
            .loafer_textAligment(.center)
        cancelBtn
            .loafer_font(21, .bold)
            .loafer_text("Cancel")
            .loafer_cornerRadius(25.FIT)
            .loafer_border("FE269C", 2.FIT)
            .loafer_titleColor("FE269C")
            .loafer_target(self, selector: #selector(loaferReportViewCancenBtn))
        submitBtn
            .loafer_font(21, .bold)
            .loafer_text("Submit")
            .loafer_cornerRadius(25.FIT)
            .loafer_titleColor("FFFFFF")
            .loafer_target(self, selector: #selector(loaferReportViewSubmitBtn))
            .setGrandient(color: .themeColor(direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: (UIDevice.screenWidth-85.FIT)/2, height: 50.FIT))
        tableView
            .loafer_register(ReportCell.self, ReportCell.description())
            .loafer_delegate(self)
            .loafer_dataSource(self)
            .loafer_backColor(.clear)
            .loafer_showsVerticalScrollIndicator(false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fatalError("init(userId:) has not been implemented")
    }
    
    @objc private func loaferReportViewSubmitBtn() {
        ToastTool.show()
        URLSessionProvider.request(.URLInterfaceReport(model: SessionRequestReportModel(reportType: LoaferAppSettings.Config.reportDicts[currentIndex].value, reportedId: userId)))
            .compactMap { $0.data }
            .done { _ in
                ToastTool.show(.success, "Report Successfully! We'll deal with your report as soon as possible!")
            }
            .catch { error in
                error.handle()
            }
    }
    
    @objc private func loaferReportViewCancenBtn() {
        PopUtil.dismiss(from: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ReportView: UITableViewDelegate & UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        LoaferAppSettings.Config.reportDicts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportCell.description()) as? ReportCell else { return UITableViewCell() }
        cell.setSourceData((LoaferAppSettings.Config.reportDicts[indexPath.row].label, currentIndex == indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentIndex == indexPath.row { return }
        currentIndex = indexPath.row
        tableView.reloadData()
    }
    
}

extension ReportView: PopProtocol {
    func popViewSize() -> CGSize { CGSize(width: UIDevice.screenWidth-30.FIT, height: (UIDevice.screenWidth-30.FIT)*(444/345)) }
    func popViewStyle() -> PopType { .center }
    func popScreenInteraction() -> EKAttributes.UserInteraction { .init() }
    func popScroll() -> EKAttributes.Scroll { .disabled }
}

private class ReportCell: UITableViewCell, SourceProtocol {
    
    typealias SourceData = (String, Bool)
    
    private let titleLabel = UILabel()
    private let chooseView = UIButton(type: .custom)
    
    func setSourceData(_ data: (String, Bool)) {
        titleLabel.loafer_text(data.0)
        chooseView.loafer_isSelect(data.1)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loafer_backColor(.clear)
        selectionStyle = .none
        contentView.subviews {
            titleLabel
            chooseView
        }
        |-20.FIT-titleLabel.centerVertically()-10.FIT-chooseView.size(20.FIT).centerVertically()-20.FIT-|
        titleLabel
            .loafer_font(18, .semiBold)
            .loafer_textColor("EFEFEF")
        chooseView
            .loafer_image("Loafer_ReportView_Normal", .normal)
            .loafer_image("Loafer_ReportView_Select", .selected)
            .loafer_isUserInteractionEnabled(false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
