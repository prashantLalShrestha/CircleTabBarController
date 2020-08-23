//
//  CircleTabBarController.swift
//  CircleTabBarController
//
//  Created by Prashant Shrestha on 5/19/20.
//  Copyright © 2020 Inficare. All rights reserved.
//

import UIKit

fileprivate struct CircleTabBarBaseDimension {
    static var tabBarHeight: CGFloat {
        return 52
    }
    static var circleViewSize: CGSize {
        return CGSize(width: 60, height: 60)
    }
    static var circleViewCornerRadius: CGFloat {
        return CircleTabBarBaseDimension.circleViewSize.height / 2
    }
    static var circleViewHalfSize: CGSize {
        return CGSize(width: CircleTabBarBaseDimension.circleViewSize.width / 2, height: CircleTabBarBaseDimension.circleViewSize.height / 2)
    }
}

open class CircleTabBarController: UITabBarController {
    
    public enum CircleViewControllerTransitionType {
        case `default`
        case modal
    }
    
    private var barHeight: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                return CircleTabBarBaseDimension.tabBarHeight + view.safeAreaInsets.bottom
            } else {
                return CircleTabBarBaseDimension.tabBarHeight
            }
        }
    }
    
    public var circleBackgroundColorForNormal: UIColor? {
        didSet {
            circleView.backgroundColor = circleBackgroundColorForNormal
        }
    }
    public var circleBackgroundColorForSelected: UIColor?
    public var circleTintColorForNormal: UIColor? {
        didSet {
            circleImageView.tintColor = circleTintColorForNormal
            if let centerIndex = canAddCenterCircleView.centerIndex, let centerTabBarItem = self.tabBar.items?[centerIndex], let selectedColor = circleTintColorForSelected {
                centerTabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : selectedColor], for: .normal)
            }
        }
    }
    public var circleTintColorForSelected: UIColor? {
        didSet {
            if let centerIndex = canAddCenterCircleView.centerIndex, let centerTabBarItem = self.tabBar.items?[centerIndex], let selectedColor = circleTintColorForSelected {
                centerTabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : selectedColor], for: .selected)
            }
        }
    }
    public var circleTabBarItemTitle: String?
    public var circleTabBarItemImage: UIImage? {
        didSet {
            if let circleTabBarItemImage = circleTabBarItemImage {
                circleImageView.image = circleTabBarItemImage
            }
        }
    }
    public var circleTabBarItemImageForSelected: UIImage?
    
    public var circleViewControllerTransitionType: CircleViewControllerTransitionType = .default
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = CircleTabBarBaseDimension.circleViewCornerRadius
        view.isUserInteractionEnabled = true
        view.backgroundColor = circleBackgroundColorForNormal
        
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.24).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2.0)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        return view
    }()
    private lazy var circleImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = CircleTabBarBaseDimension.circleViewCornerRadius
        view.isUserInteractionEnabled = false
        view.contentMode = .center
        view.backgroundColor = .clear
        view.tintColor = circleTintColorForNormal
        return view
    }()
    private lazy var circleButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = CircleTabBarBaseDimension.circleViewCornerRadius
        view.backgroundColor = .clear
        view.addTarget(self, action: #selector(circleButtonTap), for: .touchUpInside)
        return view
    }()
    private lazy var centerDisablingView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.white.cgColor
        return maskLayer
    }()
    
    private var canAddCenterCircleView: (bool: Bool, centerIndex: Int?) {
        guard let viewControllers = viewControllers else {
            return (bool: false, centerIndex: nil)
        }
        guard viewControllers.count.isOdd && viewControllers.count <= 5 else {
            return (bool: false, centerIndex: nil)
        }
        return (bool: true, centerIndex: (viewControllers.count / 2))
    }
    
    private var centerViewController: UIViewController?
    
    private var shouldInit: Bool = true
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBar.isHidden = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.commonInit()
        UIView.animate(withDuration: 0.5) {
            self.tabBar.isHidden = false
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.updateFrames()
    }
    
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let selectedIndex = tabBar.items?.firstIndex(of: item) else { return }
        guard let centerIndex = canAddCenterCircleView.centerIndex else { return }
        if selectedIndex == centerIndex, circleViewControllerTransitionType == .default {
            circleImageView.tintColor = circleTintColorForSelected
            circleImageView.image = circleTabBarItemImageForSelected
        } else {
            circleImageView.tintColor = circleTintColorForNormal
            circleImageView.image = circleTabBarItemImage
        }
    }
    
}

fileprivate extension CircleTabBarController {
    func commonInit() {
        if shouldInit == true, canAddCenterCircleView.bool == true, let centerIndex = canAddCenterCircleView.centerIndex {
            
            defer {
                shouldInit = false
            }
            
            self.tabBarConfig()
            
            self.defaultColorConfig()
            
            self.addSubViews()
            
            if centerViewController == nil {
                centerViewController = viewControllers?[centerIndex]
            }

            if circleTabBarItemTitle == nil {
                circleTabBarItemTitle = tabBar.items?[centerIndex].title
            } else {
                tabBar.items?[centerIndex].title = circleTabBarItemTitle
            }

            if circleTabBarItemImage == nil {
                circleTabBarItemImage = self.tabBar.items?[centerIndex].image
                self.tabBar.items?[centerIndex].image = UIImage()
            } else {
                circleImageView.image = circleTabBarItemImage
            }

            if circleTabBarItemImageForSelected == nil {
                circleTabBarItemImageForSelected = circleTabBarItemImage
            }
        }
    }
    
    func updateFrames() {
        if canAddCenterCircleView.bool == true {
            self.updateTabBarFrame()
            self.updateCircleViewFrame()
        }
    }
    
    func tabBarConfig() {
        self.tabBar.isTranslucent = true
        self.tabBar.backgroundColor = UIColor.clear
        self.tabBar.layer.backgroundColor = UIColor.white.cgColor
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
        
        self.tabBar.layer.shadowColor = UIColor.black.withAlphaComponent(0.24).cgColor
        self.tabBar.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        self.tabBar.layer.shadowOpacity = 1.0
        self.tabBar.layer.shadowRadius = 4.0
    }
    
    func defaultColorConfig() {
        if self.circleBackgroundColorForNormal == nil {
            self.circleBackgroundColorForNormal = self.tabBar.backgroundColor
        }
        if self.circleBackgroundColorForSelected == nil {
            self.circleBackgroundColorForSelected = self.tabBar.backgroundColor
        }
        if self.circleTintColorForNormal == nil {
            self.circleTintColorForNormal = UIColor.systemGray
        }
        if self.circleTintColorForSelected == nil {
            self.circleTintColorForSelected = self.tabBar.tintColor
        }
    }
    
    func addSubViews() {
        if view.subviews.contains(centerDisablingView) == false {
            self.view.addSubview(centerDisablingView)
        }
        if circleView.subviews.contains(circleImageView) == false {
            circleView.addSubview(circleImageView)
        }
        if circleView.subviews.contains(circleButton) == false {
            circleView.addSubview(circleButton)
        }
        if view.subviews.contains(circleView) == false {
            self.view.addSubview(circleView)
        }
    }
    
    func updateTabBarFrame() {
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = barHeight
        tabFrame.origin.y = self.view.frame.size.height - barHeight
        self.tabBar.frame = tabFrame
        tabBar.setNeedsLayout()
    }
    
    func updateCircleViewFrame() {
        if let centerIndex = canAddCenterCircleView.centerIndex {
            let tabWidth = self.view.bounds.width / CGFloat(self.tabBar.items?.count ?? 5)
            let tabHeight = self.tabBar.bounds.height
            
            centerDisablingView.frame = CGRect(x: (tabWidth * CGFloat(centerIndex)), y: self.tabBar.frame.origin.y, width: tabWidth, height: tabHeight)
            circleView.frame = CGRect(x: (tabWidth * CGFloat(centerIndex)) + tabWidth / 2 - CircleTabBarBaseDimension.circleViewCornerRadius,
                                      y: self.tabBar.frame.origin.y - CircleTabBarBaseDimension.circleViewCornerRadius,
                                      width: CircleTabBarBaseDimension.circleViewSize.width,
                                      height: CircleTabBarBaseDimension.circleViewSize.height)
            circleImageView.frame = self.circleView.bounds
            circleButton.frame = self.circleView.bounds
            
            self.addShape(in: centerIndex, tabWidth: tabWidth)
        }
    }
    
    func addShape(in index: Int, tabWidth: CGFloat) {
        let bezPath = UIBezierPath()
        bezPath.addArc(withCenter: CGPoint(x: (tabWidth * CGFloat(index)) + tabWidth / 2, y: 0), radius: CircleTabBarBaseDimension.circleViewCornerRadius + 5.0, startAngle: .pi, endAngle: 0, clockwise: false)
        bezPath.append(UIBezierPath(rect: self.tabBar.bounds))
        
        bezPath.close()
        bezPath.fill()
        maskLayer.path = bezPath.cgPath
        
//            self.tabBar.layer.mask = mask
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
        self.tabBar.layer.backgroundColor = UIColor.clear.cgColor
        if tabBar.layer.sublayers?.contains(maskLayer) == true {
            maskLayer.removeFromSuperlayer()
            tabBar.layer.insertSublayer(maskLayer, at: 0)
        } else {
            tabBar.layer.insertSublayer(maskLayer, at: 0)
        }
        
        tabBar.layer.shadowPath = bezPath.cgPath
    }
}

fileprivate extension CircleTabBarController {
    @objc func circleButtonTap() {
        guard let centerIndex = canAddCenterCircleView.centerIndex, let centerVC = centerViewController else {
            return
        }
        switch circleViewControllerTransitionType {
        case .modal:
            let temporaryVC = UIViewController()
            temporaryVC.title = circleTabBarItemTitle
            viewControllers?[centerIndex] = temporaryVC
            centerVC.modalPresentationStyle = .fullScreen
            self.present(centerVC, animated: true, completion: nil)
        default:
            viewControllers?[centerIndex] = centerVC
            selectedIndex = centerIndex
            self.tabBar(tabBar, didSelect: tabBar.items![selectedIndex])
        }
    }
}

fileprivate extension BinaryInteger {
    ///Returns true whenever the integer is even, otherwise it will return false
    var isEven: Bool { return self % 2 == 0 }

    ///Returns true whenever the integer is odd, otherwise it will return false
    var isOdd: Bool { return self % 2 != 0 }
}


fileprivate extension UIImage {
    func scaled(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, _: false, _: 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
