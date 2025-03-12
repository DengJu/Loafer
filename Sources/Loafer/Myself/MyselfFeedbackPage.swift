
import UIKit

class MyselfFeedbackPage: LoaferPage, UITextViewDelegate {
    
    private let stackView = UIStackView()
    private let scrollView = UIScrollView()
    private let iconView = UIImageView(image: "Loafer_Feedback_Icon".toImage)
    private let descView = UILabel()
    private let reasonTextView = UITextView()
    private var reason: String = ""
    private let submitBtn = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Feedback"
        view.subviews {
            scrollView.subviews {
                stackView
            }
        }
        scrollView.followEdges(view)
        scrollView.layout {
            0
            |stackView|
            0
        }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIDevice.safeBottom, right: 0)
        stackView.width(UIDevice.screenWidth)
        stackView
            .loafer_axis(.vertical)
            .loafer_spacing(30.FIT)
            .loafer_alignment(.center)
            .loafer_distribution(.equalCentering)
        descView
            .loafer_font(15, .medium)
            .loafer_text("If you have any questions, you can contact Customer service email, we will get in touch with you as soon as possible.")
            .loafer_textAligment(.center)
            .loafer_textColor("FFFFFF")
            .loafer_numberOfLines(0)
        reasonTextView
            .loafer_font(16, .semiBold)
            .loafer_tintColor("#C7B0CE")
            .loafer_textColor("#C7B0CE")
            .loafer_cornerRadius(18.FIT)
            .loafer_backColor("FFFFFF", 0.14)
            .loafer_textContainerInset(15.FIT, 5.FIT, 5.FIT, 5.FIT)
            .loafer_text("Reason:")
            .delegate = self
        submitBtn
            .loafer_font(21, .bold)
            .loafer_cornerRadius(25.FIT)
            .loafer_titleColor("FFFFFF")
            .loafer_text("Submit")
            .loafer_target(self, selector: #selector(loaferFeedbackPageSubmit))
            .setGrandient(color: .themeColor(direction: .left2Right), bounds: CGRect(x: 0, y: 0, width: UIDevice.screenWidth-40.FIT, height: 50.FIT))
        iconView.size(100.FIT)
        descView.width(<=(UIDevice.screenWidth-40.FIT)).height(<=100.FIT)
        reasonTextView.width(UIDevice.screenWidth-30.FIT).height(150.FIT)
        submitBtn.width(UIDevice.screenWidth-40.FIT).height(50.FIT)
        stackView.addArrangedSubview(UIView().height(30.FIT).width(20.FIT))
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(descView)
        stackView.addArrangedSubview(reasonTextView)
        stackView.addArrangedSubview(submitBtn)
    }
    
    @objc private func loaferFeedbackPageSubmit() {
        ToastTool.show()
        URLSessionProvider.request(.URLInterfaceFeedBack(model: SessionRequestFeedbackModel(reason: reasonTextView.text)))
            .compactMap { $0.data }
            .done {[weak self] _ in
                DispatchQueue.main.async {
                    ToastTool.show(.success, "Feedback Successfully! We'll deal with your suggestion as soon as possible!")
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            .catch { error in
                error.handle()
            }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        reason = textView.text
    }
    
}
