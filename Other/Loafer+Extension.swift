
import UIKit

extension UIButton {
    
    func setShadowText(_ color: UIColor = "020202".toColor.withAlphaComponent(0.4), blur: CGFloat = 1, offsetX: CGFloat = 1, offsetY: CGFloat = 1) {
        guard let text = titleLabel?.text else { return }
        let shadow = NSShadow()
        shadow.shadowBlurRadius = blur
        shadow.shadowOffset = CGSize(width: offsetX, height: offsetY)
        shadow.shadowColor = color
        let attributeString = NSMutableAttributedString(string: text, attributes: [.shadow: shadow])
        setAttributedTitle(attributeString, for: .normal)
    }
    
}

extension UILabel {
    
    func setShadowText(_ color: UIColor = "020202".toColor.withAlphaComponent(0.4), blur: CGFloat = 1, offsetX: CGFloat = 1, offsetY: CGFloat = 1) {
        guard let text = text else { return }
        let shadow = NSShadow()
        shadow.shadowBlurRadius = blur
        shadow.shadowOffset = CGSize(width: offsetX, height: offsetY)
        shadow.shadowColor = color
        let attributeString = NSMutableAttributedString(string: text, attributes: [.shadow: shadow])
        attributedText = attributeString
    }
    
}

// MARK: - CACornerMask

extension CACornerMask {
    static let AllCorner: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
}

// MARK: - Font

extension UIFont {
    
    public enum FontType: String {
        case regular = "Montserrat-Regular"
        case bold = "Montserrat-Bold"
        case semiBold = "Montserrat-SemiBold"
        case medium = "Montserrat-Medium"
        case black = "Montserrat-Black"
        case italic = "Montserrat-Italic"
        case extraLight = "Montserrat-ExtraLight"
        case thin = "Montserrat-Thin"
        case extraLightItalic = "Montserrat-ExtraLightItalic"
        case ThinItalic = "Montserrat-ThinItalic"
        case light = "Montserrat-Light"
        case lightItalic = "Montserrat-LightItalic"
        case mediumItalic = "Montserrat-MediumItalic"
        case semiBoldItalic = "Montserrat-SemiBoldItalic"
        case boldItalic = "Montserrat-BoldItalic"
        case extraBold = "Montserrat-ExtraBold"
        case extraBoldItalic = "Montserrat-ExtraBoldItalic"
    }
    
    static func setFont(_ size: Double = 12, _ type: FontType = .regular) -> UIFont {
        guard let font = UIFont(name: type.rawValue, size: size.FIT) else { return UIFont.systemFont(ofSize: size) }
        return font
    }
}

// MARK: - UIColor

extension UIColor {

    static var randomColor: UIColor {
        let red = CGFloat(arc4random() % 256) / 255.0
        let green = CGFloat(arc4random() % 256) / 255.0
        let blue = CGFloat(arc4random() % 256) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

protocol Arbitrary {
    static func arbitrary() -> Self
}

extension Int: Arbitrary {
    static func arbitrary() -> Int {
        return Int(arc4random())
    }
}

extension String: Arbitrary {
    static func arbitrary() -> String {
        let randomLength = Int.random(from: 32, to: 33)
        let randomCharacters = tabulate(times: randomLength) { _ in
            Character.arbitrary()
        }
        return String(randomCharacters)
    }

    static func tabulate<A>(times: Int, transform: (Int) -> A) -> [A] {
        return (0 ..< 32).map(transform)
    }
}

extension Character: Arbitrary {
    static func arbitrary() -> Character {
        return Character(UnicodeScalar(Int.random(from: 65, to: 90))!)
    }
}

extension UIViewController: StatusController {
    
}

extension UIView: StatusController {
    
}

extension Int64 {
    
    var toChatTime: String {
        let currentTime = Date().timeIntervalSince1970
        let time = TimeInterval(self / 1000)
        let reduceTime = currentTime - time
        if reduceTime < 60 {
            return NSLocalizedString("Just Now", comment: "")
        }
        
        let mins = Int(reduceTime / 60)
        if mins < 60 {
            return "\(mins) " + NSLocalizedString("minutes ago", comment: "")
        }
        let hours = Int(reduceTime / 3600)
        if hours < 24 {
            return "\(hours) " + NSLocalizedString("hours ago", comment: "")
        }
        let days = Int(reduceTime / 3600 / 24)
        if days < 30 {
            return "\(days) " + NSLocalizedString("days ago", comment: "")
        }
        let date = NSDate(timeIntervalSince1970: time)
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy-MM-dd"
        return dfmatter.string(from: date as Date)
    }
}

extension Date {
    
    func transformChatTime(timeInterval: TimeInterval) -> String {
        let date = getNowDateFromatAnDate(Date(timeIntervalSince1970: timeInterval))
        let formatter = DateFormatter()
        if date.isToday() {
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        } else if date.isYesterday() {
            formatter.dateFormat = "HH:mm"
            return NSLocalizedString("Yesterday ", comment: "") + formatter.string(from: date)
        } else if date.isSameWeek() {
            let week = date.weekdayStringFromDate()
            formatter.dateFormat = "HH:mm"
            return week + formatter.string(from: date)
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            return formatter.string(from: date)
        }
    }
    
    private func isToday() -> Bool {
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        let selfComponents = calendar.dateComponents([.day, .month, .year], from: self as Date)
        return (selfComponents.year == nowComponents.year) && (selfComponents.month == nowComponents.month) && (selfComponents.day == nowComponents.day)
    }

    private func isYesterday() -> Bool {
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.day], from: Date())
        let selfComponents = calendar.dateComponents([.day], from: self as Date)
        let cmps = calendar.dateComponents([.day], from: selfComponents, to: nowComponents)
        return cmps.day == 1
    }
    
    private func weekdayStringFromDate() -> String {
        let weekdays: NSArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone.current
        calendar.timeZone = timeZone
        let theComponents = calendar.dateComponents([.weekday], from: self as Date)
        return NSLocalizedString(weekdays.object(at: theComponents.weekday!) as! String, comment: "")
    }
    
    private func isSameWeek() -> Bool {
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        let selfComponents = calendar.dateComponents([.weekday, .month, .year], from: self as Date)
        return (selfComponents.year == nowComponents.year) && (selfComponents.month == nowComponents.month) && (selfComponents.weekday == nowComponents.weekday)
    }
    
    private func getNowDateFromatAnDate(_ anyDate: Date?) -> Date {
        let sourceTimeZone = NSTimeZone.local
        let destinationTimeZone = NSTimeZone.local as NSTimeZone
        var sourceGMTOffset: Int? = nil
        if let aDate = anyDate {
            sourceGMTOffset = sourceTimeZone.secondsFromGMT(for: aDate)
        }
        var destinationGMTOffset: Int? = nil
        if let aDate = anyDate {
            destinationGMTOffset = destinationTimeZone.secondsFromGMT(for: aDate)
        }
        let interval = TimeInterval((destinationGMTOffset ?? 0) - (sourceGMTOffset ?? 0))
        var destinationDateNow: Date? = nil
        if let aDate = anyDate {
            destinationDateNow = Date(timeInterval: interval, since: aDate)
        }
        return destinationDateNow!
    }
    
}


// MARK: - String

extension String {
    var toAnimationPath: String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("LoaferResource").appendingPathComponent("LoaferSource").appendingPathComponent("Animations").appendingPathComponent(self).appendingPathComponent(self + ".json")
        return documentsDirectory.path
    }

    var toImage: UIImage {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("LoaferResource").appendingPathComponent("LoaferSource").appendingPathComponent("Pics").appendingPathComponent(self + "@2x.png")
        return UIImage(contentsOfFile: documentsDirectory.path) ?? UIImage()
    }
    
    var intValue: Int { return isEmpty ? 0 : (self as NSString).integerValue }
    
    var toURL: URL? { URL(string: self) }
    
    var isBlank: Bool { allSatisfy { $0.isWhitespace } }
    
    var isNewLine: Bool { allSatisfy { $0.isNewline } }
    
    var whitespaceFormat: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    
    var toColor: UIColor { color(hexString: self) }
    
    private func color(hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.count < 6 {
            return UIColor.black
        }
        if cString.hasPrefix("0X") {
            cString = NSString(string: cString).substring(from: 2)
        }
        if cString.hasPrefix("#") {
            cString = NSString(string: cString).substring(from: 1)
        }
        if cString.count != 6 {
            return UIColor.black
        }
        var range = NSRange(location: 0, length: 2)
        let rString = NSString(string: cString).substring(with: range)
        range.location = 2
        let gString = NSString(string: cString).substring(with: range)
        range.location = 4
        let bString = NSString(string: cString).substring(with: range)
        var r, g, b: UInt64?
        r = 0
        g = 0
        b = 0
        Scanner(string: rString).scanHexInt64(&r!)
        Scanner(string: gString).scanHexInt64(&g!)
        Scanner(string: bString).scanHexInt64(&b!)
        return UIColor(red: CGFloat(r!)/255.0, green: CGFloat(g!)/255.0, blue: CGFloat(b!)/255.0, alpha: alpha)
    }
    
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func caculateWidth(_ size: CGFloat!, _ font: UIFont) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: size), options: NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue | NSStringDrawingOptions.usesDeviceMetrics.rawValue | NSStringDrawingOptions.truncatesLastVisibleLine.rawValue), attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size.width
    }
    
    func ageFromBirthday(currentDate: Date = Date()) -> Int? {
        let birthdayDateFormatter = DateFormatter()
        birthdayDateFormatter.dateFormat = "yyyy-MM-dd"
        birthdayDateFormatter.locale = Locale.current
        birthdayDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let birthdayDate = birthdayDateFormatter.date(from: self) else { return nil }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthdayDate, to: currentDate)
        
        return ageComponents.year
    }
}

// MARK: - UIApplication

public extension UIApplication {
    class var mainWindow: UIWindow {
        queryWindow() ?? UIWindow(frame: UIScreen.main.bounds)
    }
    
    class var rootViewController: UIViewController? {
        mainWindow.rootViewController
    }
    
    class func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        queryTopController(controller: controller)
    }
    
    // query current window
    private class func queryWindow() -> UIWindow? {
        guard let appDelegate = UIApplication.shared.delegate?.window else { return nil }
        return appDelegate
    }
    
    // query current controller
    private class func queryTopController(controller: UIViewController? = nil) -> UIViewController? {
        var currentVC = controller
        if currentVC == nil {
            currentVC = queryWindow()?.rootViewController
        }
        if let navigationController = currentVC as? UINavigationController {
            return queryTopController(controller: navigationController.visibleViewController)
        }
        if let tabController = currentVC as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return queryTopController(controller: selected)
            }
        }
        if let presented = currentVC?.presentedViewController {
            return queryTopController(controller: presented)
        }
        return currentVC
    }
}

// MARK: - UIView

extension UIView {
    enum GradientDirection {
        case left2Right
        case top2Bottom
        case right2Left
        case bottom2Top
        case leftTop2RightBottom
        case rightTop2LeftBottom
        case leftBottom2RightTop
        case rightBottom2LeftTop
    }

    enum GradientColor: Equatable {
        case themeColor(direction: GradientDirection)
        case customColor(colors: [UIColor], direction: GradientDirection)
        
        static func == (lhs: GradientColor, rhs: GradientColor) -> Bool {
            return true
        }
        
        var finalColor: [CGColor]? {
            switch self {
            case .customColor(let colors, _):
                return colors.map { $0.cgColor }
            case .themeColor:
                return [#colorLiteral(red: 0.9960784314, green: 0.04705882353, blue: 0.8431372549, alpha: 1).cgColor, #colorLiteral(red: 0.9882352941, green: 0.1450980392, blue: 0.5725490196, alpha: 1).cgColor]
            }
        }
    }
    
    func removeGradient() {
        if let layers = layer.sublayers {
            layers.forEach { if $0 is CAGradientLayer { $0.removeFromSuperlayer() } }
        }
    }
    
    func setGrandient(
        color: GradientColor,
        bounds: CGRect = .zero)
    {
        clipsToBounds = true
        let gLayer = CAGradientLayer()
        if bounds == .zero {
            superview?.layoutIfNeeded()
            layoutIfNeeded()
            gLayer.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        } else {
            gLayer.frame = bounds
        }
        if case .customColor(_, let direction) = color {
            if direction == .left2Right {
                gLayer.startPoint = CGPoint(x: 0, y: 1)
                gLayer.endPoint = CGPoint(x: 1, y: 1)
            } else if direction == .right2Left {
                gLayer.startPoint = CGPoint(x: 1, y: 1)
                gLayer.endPoint = CGPoint(x: 0, y: 1)
            } else if direction == .top2Bottom {
                gLayer.startPoint = CGPoint(x: 1, y: 0)
                gLayer.endPoint = CGPoint(x: 1, y: 1)
            } else if direction == .bottom2Top {
                gLayer.startPoint = CGPoint(x: 1, y: 1)
                gLayer.endPoint = CGPoint(x: 1, y: 0)
            } else if direction == .leftTop2RightBottom {
                gLayer.startPoint = CGPoint(x: 0, y: 0)
                gLayer.endPoint = CGPoint(x: 1, y: 1)
            } else if direction == .rightTop2LeftBottom {
                gLayer.startPoint = CGPoint(x: 1, y: 0)
                gLayer.endPoint = CGPoint(x: 0, y: 1)
            } else if direction == .leftBottom2RightTop {
                gLayer.startPoint = CGPoint(x: 0, y: 1)
                gLayer.endPoint = CGPoint(x: 1, y: 0)
            } else if direction == .rightBottom2LeftTop {
                gLayer.startPoint = CGPoint(x: 1, y: 1)
                gLayer.endPoint = CGPoint(x: 0, y: 0)
            }
            gLayer.locations = [0, 1]
        }
        if case .themeColor(let direction) = color {
            if direction == .left2Right {
                gLayer.startPoint = CGPoint(x: 0, y: 1)
                gLayer.endPoint = CGPoint(x: 1, y: 1)
            } else if direction == .right2Left {
                gLayer.startPoint = CGPoint(x: 1, y: 1)
                gLayer.endPoint = CGPoint(x: 0, y: 1)
            } else if direction == .top2Bottom {
                gLayer.startPoint = CGPoint(x: 1, y: 0)
                gLayer.endPoint = CGPoint(x: 1, y: 1)
            } else if direction == .bottom2Top {
                gLayer.startPoint = CGPoint(x: 1, y: 1)
                gLayer.endPoint = CGPoint(x: 1, y: 0)
            } else if direction == .leftTop2RightBottom {
                gLayer.startPoint = CGPoint(x: 0, y: 0)
                gLayer.endPoint = CGPoint(x: 1, y: 1)
            } else if direction == .rightTop2LeftBottom {
                gLayer.startPoint = CGPoint(x: 1, y: 0)
                gLayer.endPoint = CGPoint(x: 0, y: 1)
            } else if direction == .leftBottom2RightTop {
                gLayer.startPoint = CGPoint(x: 0, y: 1)
                gLayer.endPoint = CGPoint(x: 1, y: 0)
            } else if direction == .rightBottom2LeftTop {
                gLayer.startPoint = CGPoint(x: 1, y: 1)
                gLayer.endPoint = CGPoint(x: 0, y: 0)
            }
            gLayer.locations = [0, 1]
        }
        gLayer.colors = color.finalColor
        layer.insertSublayer(gLayer, at: 0)
        if let btn = self as? UIButton {
            btn.bringSubviewToFront(btn.imageView ?? UIImageView())
        }
    }
}

// MARK: - Int

extension Int {
    
    var FIT: CGFloat {
        CGFloat(self) * (UIScreen.main.bounds.size.height/812)
    }
    
    static func random(from: Int, to: Int) -> Int {
        return from + (Int(arc4random()) % (to - from))
    }
}

// MARK: - Double

extension Double {
    var FIT: CGFloat {
        CGFloat(self) * (UIScreen.main.bounds.size.height/812)
    }
}

// MARK: - UIDevice

extension UIDevice {
    
    static var safeTop: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return 0 }
        guard let window = windowScene.windows.first else { return 0 }
        return window.safeAreaInsets.top
    }
    
    static var safeBottom: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return 0 }
        guard let window = windowScene.windows.first else { return 0 }
        return window.safeAreaInsets.bottom
    }
    
    static var statusBarCons: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return 0 }
        guard let statusBarManager = windowScene.statusBarManager else { return 0 }
        return statusBarManager.statusBarFrame.height
    }
    
    static let navigationBarCons: CGFloat = 44
    
    static let topFullHeight: CGFloat = UIDevice.statusBarCons + UIDevice.navigationBarCons
    
    static let tabBarHeight: CGFloat = 49
    
    static let bottomFullHeight: CGFloat = UIDevice.tabBarHeight + UIDevice.safeBottom
    
    static let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    
    static let screenHeight: CGFloat = UIScreen.main.bounds.size.height
    
    static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone8,4": return "iPhone SE"
        case "iPhone9,1": return "iPhone 7"
        case "iPhone9,2": return "iPhone 7 Plus"
        case "iPhone9,3": return "iPhone 7"
        case "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone10,1": return "iPhone 8"
        case "iPhone10,2": return "iPhone 8 Plus"
        case "iPhone10,3": return "iPhone X"
        case "iPhone10,4": return "iPhone 8"
        case "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,6": return "iPhone X"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4": return "iPhone XS Max"
        case "iPhone11,6": return "iPhone XS Max"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,4": return "iPhone 13 Mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
            
        case "iPad1,1": return "iPad"
        case "iPad2,1": return "iPad 2"
        case "iPad2,2": return "iPad 2"
        case "iPad2,3": return "iPad 2"
        case "iPad2,4": return "iPad 2"
        case "iPad2,5": return "iPad mini"
        case "iPad2,6": return "iPad mini"
        case "iPad2,7": return "iPad mini"
        case "iPad3,1": return "iPad (3rd generation)"
        case "iPad3,2": return "iPad (3rd generation)"
        case "iPad3,3": return "iPad (3rd generation)"
        case "iPad3,4": return "iPad (4th generation)"
        case "iPad3,5": return "iPad (4th generation)"
        case "iPad3,6": return "iPad (4th generation)"
        case "iPad4,1": return "iPad Air"
        case "iPad4,2": return "iPad Air"
        case "iPad4,3": return "iPad Air"
        case "iPad4,4": return "iPad mini 2"
        case "iPad4,5": return "iPad mini 2"
        case "iPad4,6": return "iPad mini 2"
        case "iPad4,7": return "iPad mini 3"
        case "iPad4,8": return "iPad mini 3"
        case "iPad4,9": return "iPad mini 3"
        case "iPad5,1": return "iPad mini 4"
        case "iPad5,2": return "iPad mini 4"
        case "iPad5,3": return "iPad Air 2"
        case "iPad5,4": return "iPad Air 2"
        case "iPad6,3": return "iPad Pro (9.7-inch)"
        case "iPad6,4": return "iPad Pro (9.7-inch)"
        case "iPad6,7": return "iPad Pro (12.9-inch)"
        case "iPad6,8": return "iPad Pro (12.9-inch)"
        case "iPad6,11": return "iPad (5th generation)"
        case "iPad6,12": return "iPad (5th generation)"
        case "iPad7,1": return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,2": return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,3": return "iPad Pro (10.5-inch)"
        case "iPad7,4": return "iPad Pro (10.5-inch)"
        case "iPad7,5": return "iPad (6th generation)"
        case "iPad7,6": return "iPad (6th generation)"
        case "iPad7,11": return "iPad (7th generation)"
        case "iPad7,12": return "iPad (7th generation)"
        case "iPad8,1": return "iPad Pro (11-inch)"
        case "iPad8,2": return "iPad Pro (11-inch)"
        case "iPad8,3": return "iPad Pro (11-inch)"
        case "iPad8,4": return "iPad Pro (11-inch)"
        case "iPad8,5": return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,6": return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,7": return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,8": return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,9": return "iPad Pro (11-inch) (2nd generation)"
        case "iPad8,10": return "iPad Pro (11-inch) (2nd generation)"
        case "iPad8,11": return "iPad Pro (12.9-inch) (4th generation)"
        case "iPad8,12": return "iPad Pro (12.9-inch) (4th generation)"
        case "iPad11,1": return "iPad mini (5th generation)"
        case "iPad11,2": return "iPad mini (5th generation)"
        case "iPad11,3": return "iPad Air (3rd generation)"
        case "iPad11,4": return "iPad Air (3rd generation)"
        case "iPad11,6": return "iPad (8th generation)"
        case "iPad11,7": return "iPad (8th generation)"
        case "iPad12,1": return "iPad (9th generation)"
        case "iPad12,2": return "iPad (9th generation)"
        case "iPad13,1": return "iPad Air (4th generation)"
        case "iPad13,2": return "iPad Air (4th generation)"
        case "iPad13,4": return "iPad Pro (11-inch) (3rd generation)"
        case "iPad13,5": return "iPad Pro (11-inch) (3rd generation)"
        case "iPad13,6": return "iPad Pro (11-inch) (3rd generation)"
        case "iPad13,7": return "iPad Pro (11-inch) (3rd generation)"
        case "iPad13,8": return "iPad Pro (12.9-inch) (5th generation)"
        case "iPad13,9": return "iPad Pro (12.9-inch) (5th generation)"
        case "iPad13,10": return "iPad Pro (12.9-inch) (5th generation)"
        case "iPad13,11": return "iPad Pro (12.9-inch) (5th generation)"
        case "iPad13,16": return "iPad Air (5th generation)"
        case "iPad13,17": return "iPad Air (5th generation)"
        case "iPad13,18": return "iPad (10th generation)"
        case "iPad13,19": return "iPad (10th generation)"
        case "iPad14,1": return "iPad mini (6th generation)"
        case "iPad14,2": return "iPad mini (6th generation)"
        case "iPad14,3": return "iPad Pro (11-inch) (4th generation)"
        case "iPad14,4": return "iPad Pro (11-inch) (4th generation)"
        case "iPad14,5": return "iPad Pro (12.9-inch) (6th generation)"
        case "iPad14,6": return "iPad Pro (12.9-inch) (6th generation)"
            
        case "i386": return "Simulator"
        case "x86_64": return "Simulator"
        case "arm64": return "Simulator"
        default: return ""
        }
    }
}
