//
//  CBExtensions.swift
//  Cobalt
//
//  Created by ingouackaz on 21/05/2018.
//  Copyright © 2018 ingouackaz. All rights reserved.
//

import UIKit
import Photos
import UserNotifications

class DVExtensions{
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func removeFileAtURL(_ file: URL){
        DispatchQueue.main.async {
            do{
                try FileManager.default.removeItem(at: file)
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    class func getLabelHeight(_ forText: String, font: UIFont, width: CGFloat, numberOfLines: Int = 0) -> CGFloat{
        let label: UILabel = UILabel()
        label.numberOfLines = numberOfLines
        label.font = font
        label.text = forText
        return label.sizeThatFits(CGSize(width: width, height: CGFloat(MAXFLOAT))).height
    }
    
    class func getLabelWidth(_ forText: String, font: UIFont, height: CGFloat, numberOfLines: Int = 0) -> CGFloat{
        let label: UILabel = UILabel()
        label.numberOfLines = numberOfLines
        label.font = font
        label.text = forText
        return label.sizeThatFits(CGSize(width: CGFloat(MAXFLOAT), height: height)).width
    }
    
    class func getLabelHeight(_ forAttributedText: NSAttributedString, width: CGFloat, numberOfLines: Int = 0) -> CGFloat{
        let label: UILabel = UILabel()
        label.numberOfLines = numberOfLines
        label.attributedText = forAttributedText
        return label.sizeThatFits(CGSize(width: width, height: CGFloat(MAXFLOAT))).height
    }
    
    class func getLabelWidth(_ forAttributedText: NSAttributedString, height: CGFloat, numberOfLines: Int = 0) -> CGFloat{
        let label: UILabel = UILabel()
        label.numberOfLines = numberOfLines
        label.attributedText = forAttributedText
        return label.sizeThatFits(CGSize(width: CGFloat(MAXFLOAT), height: height)).width
    }
    
    class func getAssetThumbnail(_ asset: PHAsset, size: CGSize) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    class func containSameElements<T: Comparable>(_ array1: [T], _ array2: [T]) -> Bool {
        guard array1.count == array2.count else {
            return false // No need to sorting if they already have different counts
        }
        
        return array1.sorted() == array2.sorted()
    }
    
    static var isPushNotificationEnabled: Bool {
        var isEnabled: Bool = false
        
        guard let settings = UIApplication.shared.currentUserNotificationSettings
            else {
                return isEnabled
        }
        
        isEnabled = UIApplication.shared.isRegisteredForRemoteNotifications
            && !settings.types.isEmpty
        
        return isEnabled
    }
    
    enum DVPushAuthorizationStatus: Int{
        case notDetermined = 0, denied, authorized
    }
    
    class func pushNotificationAuthorizationStatus(_ callback: @escaping (_ authorization: DVPushAuthorizationStatus)->Void){
        var authorization: DVPushAuthorizationStatus = DVPushAuthorizationStatus.notDetermined
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings: UNNotificationSettings) in
                authorization = DVExtensions.DVPushAuthorizationStatus(rawValue: settings.authorizationStatus.rawValue)!
                
                if settings.alertSetting == UNNotificationSetting.disabled{
                    authorization = DVPushAuthorizationStatus.denied
                }else if settings.notificationCenterSetting == UNNotificationSetting.disabled{
                    authorization = DVPushAuthorizationStatus.denied
                }
                DispatchQueue.main.async {
                    callback(authorization)
                }
            }
        } else {
            if let settings: UIUserNotificationSettings = UIApplication.shared.currentUserNotificationSettings{
                if settings.types == UIUserNotificationType.sound || settings.types == UIUserNotificationType.alert || settings.types == UIUserNotificationType.badge{
                    authorization = .authorized
                }else{
                    authorization = .denied
                }
            }
            DispatchQueue.main.async {
                callback(authorization)
            }
        }
    }
    
    static var isKeyboardPresented: Bool {
        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"), UIApplication.shared.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) {
            return true
        } else {
            return false
        }
    }
}

// MARK: - UIImageView
extension UIImageView {
    func downloadedFrom(link:String, contentMode mode: UIViewContentMode) {
        guard
            let url = URL(string: link)
            else {return}
        contentMode = mode
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
                let data = data , error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async { () -> Void in
                self.image = image
            }
        })
        task.priority = 1.0
        task.resume()
    }
    
    @IBInspectable var imageRenderingMode: Int{
        get {
            if let image: UIImage = self.image{
                return image.renderingMode.rawValue
            }
            return 0
        }
        set {
            if let image: UIImage = self.image{
                self.image = image.withRenderingMode(UIImageRenderingMode(rawValue: newValue)!)
            }
        }
    }
}

// MARK: - UIImage
extension UIImage {
    func resizeWith(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 1)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 1)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWith(height: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat(ceil(height * size.width / size.height)), height: height)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 1)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    enum ImageFormat: Int{
        case png = 0, jpeg
    }
    
    func imageDataThatFitSize(_ desiredSize: Int, compressionQuality: CGFloat = 1.0)->Data?{// returns image of particular size in KB
        let imageData: Data? = UIImageJPEGRepresentation(self, compressionQuality)
        if imageData != nil && imageData!.count / 1024 <= desiredSize{
            return imageData
        }else{
            return self.imageDataThatFitSize(desiredSize, compressionQuality: compressionQuality - 0.05)
        }
    }
    
    func imageInRect(rect: CGRect)->UIImage{
        UIGraphicsBeginImageContext(rect.size)
        let imageRect: CGRect = CGRect(
            x: (rect.width - self.size.width) / 2,
            y: (rect.height - self.size.height) / 2,
            width: self.size.width,
            height: self.size.height)
        self.draw(in: imageRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    struct RotationOptions: OptionSet {
        let rawValue: Int
        
        static let flipOnVerticalAxis = RotationOptions(rawValue: 1)
        static let flipOnHorizontalAxis = RotationOptions(rawValue: 2)
    }
    
    @available(iOS 10.0, *)
    func rotated(by rotationAngle: Measurement<UnitAngle>, options: RotationOptions = []) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let rotationInRadians = CGFloat(rotationAngle.converted(to: .radians).value)
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)
            
            let x = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
            let y = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
            renderContext.cgContext.scaleBy(x: CGFloat(x), y: CGFloat(y))
            
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
    
    func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        /*let radiansToDegrees: (CGFloat) -> CGFloat = {
         return $0 * (180.0 / CGFloat(Double.pi))
         }*/
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(Double.pi)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees))
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap!.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        
        //   // Rotate the image context
        bitmap!.rotate(by: degreesToRadians(degrees))
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        bitmap!.scaleBy(x: yFlip, y: -1.0)
        bitmap!.draw(self.cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
    func overlayImage(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        color.setFill()
        
        context!.translateBy(x: 0, y: self.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        
        context!.setBlendMode(CGBlendMode.colorBurn)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context!.draw(self.cgImage!, in: rect)
        
        context!.setBlendMode(CGBlendMode.sourceIn)
        context!.addRect(rect)
        context!.drawPath(using: CGPathDrawingMode.fill)
        
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return coloredImage
    }
}


// MARK: - UIColor
extension UIColor {
    convenience init(hex: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        var nrgba = hex
        if !nrgba.hasPrefix("#") {
            nrgba = "#\(hex)"
        }
        if nrgba.hasPrefix("#") {
            let index   = nrgba.index(nrgba.startIndex, offsetBy: 1)
            let hex     = String(nrgba[index...])
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
                switch (hex.count) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                print("Scan hex error")
            }
        }/* else {
         print("Invalid RGB string, missing '#' as prefix")
         }*/
        //println("red: \(red), green: \(green), blue \(blue), alpha: \(alpha)")
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    class func imageWithColor(_ color: UIColor, size: CGSize? = nil) -> UIImage{
        var height: CGFloat = 1.0
        var width: CGFloat = 1.0
        
        if size != nil{
            height = size!.height
            width = size!.width
        }
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: width, height: height)
        
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    static func randomColor() -> UIColor{
        return UIColor(red:   0.62,
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

// MARK: - CGFloat
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

// MARK: - Int

extension Int {
    static func random() -> Int {
        return Int(arc4random()) / Int.max
    }
    static func randomNumber(range: ClosedRange<Int>) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }
    static func randomNumber(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }
}

// MARK: - Character

extension Character {
    var asciiValue: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
}

// MARK: - String

extension String {
    var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
    
    // formatting text for currency textField
    func currencyFormattingRightToLeft() -> String? {
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return nil
        }
        
        return formatter.string(from: number)
    }
    
    func currencyFromFormattedString()->Double{
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        return NSNumber(value: (double / 100)).doubleValue
    }
    
    func widthWithConstrainedHeight(height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.width
    }
    
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return boundingBox.width
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return boundingBox.height
    }
    
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
    
    func matches(_ with: String)->Float{
        var matchingCount: Int = 0
        
        for c in self.lowercased(){
            for c1 in with.lowercased(){
                if c == c1{
                    matchingCount += 1
                    break
                }
            }
        }
        
        return 100.0 * (Float(matchingCount)/Float(with.count))
    }
}

// MARK: - UIView

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    func removeAllSubviews(){
        for __view in self.subviews{
            __view.removeFromSuperview()
        }
    }
    
    func addBorder(edges: UIRectEdge, color: UIColor = UIColor.white, thickness: CGFloat = 1) -> [UIView]{
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRect.zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            let top = border()
            addSubview(top)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bottom]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
    
    func removeBorder(borders: [UIView]){
        for _view in borders{
            _view.removeFromSuperview()
        }
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addDropShadow(_ color: UIColor? = nil, shadowRadius: CGFloat? = nil, shadowOffset: CGSize? = nil, shadowOpacity: Float? = nil) {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = color != nil ? color!.cgColor : UIColor.black.cgColor
        self.layer.shadowOpacity = shadowOpacity != nil ? shadowOpacity! : 0.5
        self.layer.shadowOffset = shadowOffset != nil ? shadowOffset! : CGSize(width: 0, height: 1)
        self.layer.shadowRadius = shadowRadius != nil ? shadowRadius! : 1.0
        
        //self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shouldRasterize = false
    }
    
    func startSpinning() {
        let spinAnimation = CABasicAnimation()
        spinAnimation.fromValue = 0
        spinAnimation.toValue = Double.pi * 2
        spinAnimation.duration = 2.5
        spinAnimation.repeatCount = Float.infinity
        spinAnimation.isRemovedOnCompletion = false
        layer.add(spinAnimation, forKey: "transform.rotation.z")
    }
    
    func stopSpinning() {
        layer.removeAllAnimations()
    }
}

// MARK: - UINavigationBar

extension UINavigationBar {
    
    func setBottomBorderColor(_ color: UIColor, height: CGFloat) {
        if let bottomBorderView: UIView = self.viewWithTag(268866){
            bottomBorderView.backgroundColor = color
            var oldFrame: CGRect = bottomBorderView.frame
            oldFrame.size.height = height
            bottomBorderView.frame = oldFrame
        }else{
            let bottomBorderRect = CGRect(x: 0, y: frame.height, width: 10000, height: height)
            let bottomBorderView = UIView(frame: bottomBorderRect)
            bottomBorderView.tag = 268866
            bottomBorderView.backgroundColor = color
            addSubview(bottomBorderView)
        }
    }
    
    func removeBottomBorderColor(){
        if let bottomBorderView: UIView = self.viewWithTag(268866){
            bottomBorderView.removeFromSuperview()
        }
    }
}

// MARK: - CALayer borderColorFromUIColor
extension CALayer{
    func setBorderColorFromUIColor(_ color: UIColor){
        self.borderColor = color.cgColor
    }
    
    func addGradientBorder(colors:[UIColor] = [UIColor.red,UIColor.blue], width:CGFloat = 1, isHorizontal: Bool = true) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =  CGRect(origin: CGPoint.zero, size: self.bounds.size)
        if isHorizontal{
            gradientLayer.startPoint = CGPoint(x:0.0, y:0.5)
            gradientLayer.endPoint = CGPoint(x:1.0, y:0.5)
        }
        gradientLayer.colors = colors.map({$0.cgColor})
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = width
        shapeLayer.path = UIBezierPath(rect: self.bounds).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        self.addSublayer(gradientLayer)
    }
    
    func addGradientBackground(colors: [CGColor], isSquare: Bool = false, isHorizontal: Bool = false){
        let gradient = CAGradientLayer()
        
        if isSquare{
            let maxWidth = max(self.bounds.size.height,self.bounds.size.width)
            let squareFrame = CGRect(origin: self.bounds.origin, size: CGSize(width: maxWidth, height: maxWidth))
            gradient.frame = squareFrame
        }else{
            gradient.frame = self.bounds
        }
        
        gradient.colors = colors
        
        if isHorizontal{
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        
        self.insertSublayer(gradient, at: 0)
    }
    
    func addGradientBackgroundShape(colors: [UIColor], isHorizontal: Bool = false, frame: CGRect? = nil, path: CGPath? = nil) -> CALayer {
        let gradientLayer = CAGradientLayer()
        if frame != nil{
            gradientLayer.frame = frame!
        }else{
            gradientLayer.frame =  self.frame
        }
        if isHorizontal{
            gradientLayer.startPoint = CGPoint(x:0.0, y:0.5)
            gradientLayer.endPoint = CGPoint(x:1.0, y:0.5)
        }
        gradientLayer.colors = colors.map({$0.cgColor})
        
        let shapeLayer = CAShapeLayer()
        //shapeLayer.lineWidth = 1.0
        if path != nil{
            shapeLayer.path = path!
        }else{
            shapeLayer.path = UIBezierPath(rect: self.frame).cgPath
        }
        gradientLayer.mask = shapeLayer
        
        self.insertSublayer(gradientLayer, at: 0)
        
        return gradientLayer
    }
}

// MARK: - NSTextAttachment

extension NSTextAttachment {
    func setImageHeight(_ height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height
        
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: ratio * height, height: height)
    }
}

// MARK: - ShadowedView
class ShadowedView: UIView{
    @IBInspectable var shadowColor: UIColor?{
        get {
            if self.layer.shadowColor != nil{
                return UIColor(cgColor: self.layer.shadowColor!)
            }else{
                return nil
            }
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    @IBInspectable var shadowWidthOffset: CGFloat {
        get {
            return layer.shadowOffset.width
        }
        set {
            layer.shadowOffset.width = newValue
        }
    }
    
    @IBInspectable var shadowHeightOffset: CGFloat {
        get {
            return layer.shadowOffset.height
        }
        set {
            layer.shadowOffset.height = newValue
        }
    }
    @IBInspectable var shadowRadius: CGFloat{
        get{
            return self.layer.shadowRadius
        }
        set{
            self.layer.shadowRadius = newValue
        }
    }
    @IBInspectable var shadowOpacity: CGFloat{
        get{
            return CGFloat(self.layer.shadowOpacity)
        }
        set{
            self.layer.shadowOpacity = Float(newValue)
        }
    }
    @IBInspectable var masksToBounds: Bool{
        get{
            return self.layer.masksToBounds
        }
        set{
            self.layer.masksToBounds = newValue
        }
    }
}

// MARK: - UIViewController
extension UIViewController{
    func findParentViewController(_ vc: UIViewController? = nil, searchVC: AnyClass)->UIViewController?{
        let vc: UIViewController = vc == nil ? self : vc!
        guard let parentVC: UIViewController = vc.parent else{
            return nil
        }
        if object_getClass(parentVC) === searchVC{
            return vc.parent
        }else if parentVC.isKind(of: searchVC){
            return vc.parent
        }else{
            return findParentViewController(parentVC, searchVC: searchVC)
        }
    }
}

// MARK: - CollectionViewFlowLayoutMinSpacing
class CollectionViewFlowLayoutMinSpacing : UICollectionViewFlowLayout {
    
    let cellSpacing:CGFloat = 10
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let attributes = super.layoutAttributesForElements(in: rect) {
            for (index, attribute) in attributes.enumerated() {
                if index == 0 { continue }
                let prevLayoutAttributes = attributes[index - 1]
                let origin = prevLayoutAttributes.frame.maxX
                if(origin + cellSpacing + attribute.frame.size.width < self.collectionViewContentSize.width) {
                    attribute.frame.origin.x = origin + cellSpacing
                }
            }
            return attributes
        }
        return nil
    }
}

// MARK: - Date
extension Date{
    func getDayOfWeek()->Int? {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let myComponents = myCalendar?.components(.weekday, from: self)
        let weekDay = myComponents?.weekday
        return weekDay
    }
    
    func dateStringWithFormat(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

// MARK: - PaddingLabel
class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 5.0
    @IBInspectable var rightInset: CGFloat = 5.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}

// MARK: - Dictionary
extension Dictionary {
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}

// MARK: - UILabel
extension UILabel{
    func addImage(name: String, afterText: Bool = false){
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: name)
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        
        if afterText{
            let strLabelText: NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
            strLabelText.append(attachmentString)
            
            self.attributedText = strLabelText
        }else{
            let strLabelText: NSAttributedString = NSAttributedString(string: self.text!)
            let mutableAttachmentString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            
            self.attributedText = mutableAttachmentString
        }
    }
    
    func addImage(image: UIImage, afterText: Bool = false){
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = image
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        
        if afterText{
            let strLabelText: NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
            strLabelText.append(attachmentString)
            
            self.attributedText = strLabelText
        }else{
            let strLabelText: NSAttributedString = NSAttributedString(string: self.text!)
            let mutableAttachmentString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            
            self.attributedText = mutableAttachmentString
        }
    }
}

extension UIDevice {
    static var isSimulator: Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
}
