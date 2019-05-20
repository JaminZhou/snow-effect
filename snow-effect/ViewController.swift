//
//  ViewController.swift
//  snow-effect
//
//  Created by JaminZhou on 2017/2/26.
//  Copyright © 2017年 Hangzhou Tomorning Technology Co., Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var segmentBackView: UIView!
    var segmentSlideView: UIView!
    var pagingScrollView: UIScrollView!
    var currentIndex = 0 {
        didSet {
            if (currentIndex != oldValue) {
                if oldValue != 0 {(segmentBackView.viewWithTag(oldValue) as! UIButton).isSelected = false}
                (segmentBackView.viewWithTag(currentIndex) as! UIButton).isSelected = true
            }
        }
    }
    
    let KScreenWidth = UIScreen.main.bounds.width
    let KScreenHeight = UIScreen.main.bounds.height
    let KSegmentViewtHeight: CGFloat = 44
    let KSegmentViewLeading: CGFloat = 8
    let KPagingViewHeight = UIScreen.main.bounds.height-64-44
    let KOnePixels = 1/UIScreen.main.scale

    override func viewDidLoad() {
        super.viewDidLoad()
        addSegmentView()
        addPagingView()
    }
    
    func addSegmentView() {
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KSegmentViewtHeight))
        backView.backgroundColor = UIColor.white
        backView.layer.shadowColor = UIColor.black.cgColor
        backView.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        backView.layer.shadowRadius = 3
        backView.layer.shadowOpacity = 0.04
        
        let lineView = UIView(frame: CGRect(x: 0, y: KSegmentViewtHeight-KOnePixels, width: KScreenWidth, height: KOnePixels))
        lineView.backgroundColor = UIColor(white: 218/255.0, alpha: 1.0)
        
        view.addSubview(backView)
        view.addSubview(lineView)
        
        for i in 0...2 {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: CGFloat(i)*KScreenWidth/3, y: 0, width: KScreenWidth/3, height: KSegmentViewtHeight)
            button.tag = i+1
            button.addTarget(self, action: #selector(tapSegmentButton(_:)), for: .touchUpInside)
            backView.addSubview(button)
            let normal = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium),
                          NSAttributedString.Key.foregroundColor: UIColor(red: 78/255, green: 86/255, blue: 101/255, alpha: 1)]
            let select = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium),
                          NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 141/255, blue: 237/255, alpha: 1)]
            var title = ""
            switch i {
            case 0:
                title = "Notifications"
            case 1:
                title = "Groups"
            case 2:
                title = "Message"
            default:
                break
            }
            button.setAttributedTitle(NSAttributedString(string: title, attributes: normal), for: .normal)
            button.setAttributedTitle(NSAttributedString(string: title, attributes: select), for: .selected)
        }
        
        let slideView = UIView(frame: CGRect(x: 0, y: KSegmentViewtHeight-2, width: KScreenWidth/3, height: 2))
        let blueView = UIView(frame: CGRect(x: KSegmentViewLeading, y: 0, width: slideView.frame.width-2*KSegmentViewLeading, height: slideView.frame.height))
        blueView.backgroundColor = UIColor(red: 0, green: 141/255, blue: 237/255.0, alpha: 1.0)
        slideView.addSubview(blueView)
        backView.addSubview(slideView)
        
        segmentSlideView = slideView
        segmentBackView = backView
    }
    
    func addPagingView() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: KSegmentViewtHeight, width: KScreenWidth, height: KPagingViewHeight))
        scrollView.contentSize = CGSize(width: 3*scrollView.frame.width, height: scrollView.frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        for i in 0...2 {
            let view = Bundle.main.loadNibNamed("ActivityView", owner: self, options: nil)![i] as! UIView
            view.frame = scrollView.bounds
            view.frame.origin.x = CGFloat(i)*scrollView.frame.width
            scrollView.addSubview(view)
            
            if (i == 1) {addSnowEffect(view.viewWithTag(1)!)}
        }
        
        scrollView.contentOffset = CGPoint(x: scrollView.frame.width, y: 0)
        pagingScrollView = scrollView
    }
    
    func addSnowEffect(_ view: UIView) {
        let rect = CGRect(x: -0.3*view.frame.width, y: -0.7*view.frame.height, width: view.frame.width*1.6, height: 0.1*view.frame.height)
        let emitter = CAEmitterLayer()
        emitter.frame = rect
        view.layer.addSublayer(emitter)
        
        emitter.emitterShape = .rectangle
        emitter.emitterPosition = CGPoint(x: rect.width/2, y: rect.height/2)
        emitter.emitterSize = rect.size
        
        let cell = CAEmitterCell()
        cell.contents = #imageLiteral(resourceName: "snow").cgImage
        cell.birthRate = 12
        cell.lifetime = 80
        cell.lifetimeRange = 1
        cell.yAcceleration = 4.0
        cell.scale = 0.8
        cell.scaleRange = 0.2
        cell.scaleSpeed = -0.03
        cell.alphaRange = 0.08
        cell.alphaSpeed = -0.05
        
        emitter.emitterCells = [cell]
    }
    
    @objc func tapSegmentButton(_ sender: UIButton) {
        if currentIndex !=  sender.tag {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.pagingScrollView.contentOffset = CGPoint(x: self.KScreenWidth*(CGFloat(sender.tag)-1), y: 0)
            }, completion: nil)
        }
    }

}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        var rect = segmentSlideView.frame
        rect.origin.x = offsetX/3
        segmentSlideView.frame = rect
        currentIndex = Int((offsetX+0.5*KScreenWidth)/KScreenWidth)+1
    }
    
}
