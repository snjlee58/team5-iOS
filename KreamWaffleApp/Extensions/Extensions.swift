//
//  Extensions.swift
//  KreamWaffleApp
//
//  Created by grace kim  on 2022/12/28.
//

import UIKit

extension UILabel {
    func configureWith(_ text: String,
                       color: UIColor,
                       alignment: NSTextAlignment,
                       size: CGFloat,
                       weight: UIFont.Weight = .regular) {
        self.font = .systemFont(ofSize: size, weight: weight)
        self.text = text
        self.textColor = color
        self.textAlignment = alignment
    }
}

extension UIView {
    func setupCornerRadius(_ cornerRadius: CGFloat = 0, maskedCorners: CACornerMask? = nil) {
        layer.cornerRadius = cornerRadius
        if let corners = maskedCorners {
            layer.maskedCorners = corners
        }
    }
    
    func animateClick(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform.identity
            } completion: { _ in completion() }
        }
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 7
    }
}

extension UIStackView {
    func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach { addArrangedSubview($0) }
    }
}


extension UIViewController {

    /// Adds child view controller to the parent.
    /// - Parameter child: Child view controller.
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    /// It removes the child view controller from the parent.
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}

extension UIImage {

    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

}

extension UIStackView {

    func addBackground(color: UIColor) {
        let subview = UIView(frame: bounds)
        subview.backgroundColor = color
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subview, at: 0)
    }

}


enum UserDefaultsKeys : String {
    case isLoggedIn
    case userID
    case savedUser
}

extension UserDefaults{

    //MARK: Check Login
    func setLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }

    func isLoggedIn()-> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }

    //MARK: Save User Data
    func setUserID(value: Int){
        set(value, forKey: UserDefaultsKeys.userID.rawValue)
        //synchronize()
    }

    //MARK: Retrieve User Data
    func getUserID() -> Int{
        return integer(forKey: UserDefaultsKeys.userID.rawValue)
    }
    
    func reset() {
        removeObject(forKey: UserDefaultsKeys.savedUser.rawValue)
    }
}

extension CALayer {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIButton{

    func setImageTintColor(_ color: UIColor) {
        let tintedImage = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = color
    }

}


extension UIViewController {
    func presentLoginAgainAlert() {
        let alert = UIAlertController(title: "실패", message: "다시 로그인해주세요.", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        self.present(alert, animated: false, completion: nil)
    }
    
}

extension Bundle {
    
    var NAVER_CONSUMER_KEY: String {
        guard let file = self.path(forResource: "Secret", ofType: "plist") else { return "" }
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["NAVER_CONSUMER_KEY"] as? String else {
            fatalError("NAVER_CONSUMER_KEY error")
        }
        return key
    }
    
    var NAVER_CONSUMER_SECRET: String {
        guard let file = self.path(forResource: "Secret", ofType: "plist") else { return "" }
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["NAVER_CONSUMER_SECRET"] as? String else {
            fatalError("NAVER_CONSUMER_SECRET error")
        }
        return key
    }
    
    var GOOGLE_CLIENT_ID: String {
        guard let file = self.path(forResource: "Secret", ofType: "plist") else { return "" }
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["GOOGLE_CLIENT_ID"] as? String else {
            fatalError("GOOGLE_CLIENT_ID error")
        }
        return key
    }
}

extension UserDefaults {
    func saveProfileImage(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        let encoded = try! PropertyListEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: "profileImage")
    }

    func loadProfileImage() -> UIImage?{
         guard let data = UserDefaults.standard.data(forKey: "profileImage") else { return nil }
         let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
         let image = UIImage(data: decoded)
         return image
    }
    
    func deleteProfileImage(){
        UserDefaults.standard.removeObject(forKey: "profileImage")
    }
}

