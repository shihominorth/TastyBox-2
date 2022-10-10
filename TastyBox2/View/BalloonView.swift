////
////  BalloonView.swift
////  TastyBox-2
////
////  Created by 北島　志帆美 on 2021-09-27.
////
//
//import UIKit
//
//final class BalloonView: UIView {
//    
//    // 三角部分の幅
//    private var triangleBottomLength: CGFloat!
//    // 三角部分の高さ
//    private var triangleHeight: CGFloat!
//    // 吹き出し内のコンテンツ部分を管理するView
//    private var innerView: UIView!
//    private var innerViewSize: CGSize!
//    private var innerViewOrigin: CGPoint!
//    
//    private var superViewRect: CGRect!
//    private var top: CGPoint!
//    private var left: CGPoint!
//    private var right: CGPoint!
//    
//    // 吹き出しの外枠と中身のViewとのinset用
//        var expandLength: (width: CGFloat, height: CGFloat) {
//            // 方向別に吹き出しの外枠のサイズを拡張したいときは、分岐を書く
//            return (30, 30)
//        }
//
//    private let viewSize: CGSize!
//    private let viewOrigin: CGPoint!
//    private let viewFrame : CGRect!
//    
//    private var diagonallyDirectionTriangleBottomCenterX: CGFloat = 0.0
//    private var triangleBottomLengthHalf: CGFloat = 0.0
//   
//    private var longLength: CGFloat = 0.0
//    private var shortLength: CGFloat = 0.0
//    private var color: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//    
//    init(superViewRect: CGRect, focusPoint: CGPoint, contentView: UIView, triangleBottomLength: CGFloat = 25, triangleHeight: CGFloat = 20) {
//        
//        self.triangleBottomLength = triangleBottomLength
//        self.triangleBottomLengthHalf = self.triangleBottomLength / 2
//        self.triangleHeight = triangleHeight
//    
//      
//        self.diagonallyDirectionTriangleBottomCenterX = self.frame.size.width * 0.2
//
//        self.longLength = diagonallyDirectionTriangleBottomCenterX + triangleBottomLengthHalf
//        self.shortLength = diagonallyDirectionTriangleBottomCenterX - triangleBottomLengthHalf
//        
//        self.top = CGPoint(x: self.frame.size.width, y: .zero)
//        self.left = CGPoint(x: top.x - longLength, y: top.y + triangleHeight)
//        self.right = CGPoint(x: top.x - shortLength, y: left.y)
//        
//        
//        let viewSize: CGSize = CGSize(width: viewFrame.width + expandLength.width,
//                              height: viewFrame.height + expandLength.height + triangleHeight)
//        let viewOrigin: CGPoint = CGPoint(x: focusPoint.x - viewSize.width, y: focusPoint.y)
//        
//        let viewFrame = CGRect(origin: viewOrigin, size: viewSize)
//        // 吹き出しの内容部分描画用のViewを用意
//        innerViewSize = CGSize(width: self.frame.width, height: self.frame.height - triangleHeight)
//        innerViewOrigin = CGPoint(x: .zero, y: triangleHeight)
//        innerView = UIView(frame: CGRect(origin: innerViewOrigin, size: innerViewSize))
//
//       
//        
//        super.init(frame: viewFrame)
//        
//        // BalloonView自体の背景を透明に（吹き出しのみを見せるため）
//        backgroundColor = .clear
//        
//        addSubview(innerView)
//        innerView.addSubview(contentView)
//        contentView.center = self.convert(innerView.center, to: innerView)
//    }
//    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        innerView.layer.masksToBounds = true
//        innerView.layer.cornerRadius = 10
//        
//        // 吹き出しの三角形部分を描画する
//        drawBalloonPath(rect: rect)
//    }
//    
//    func initalizeProperties() {
//        
//      
//    }
//    
//    func drawBalloonPath(rect: CGRect) {
//        // 三角形の各頂点を取得
////        let cornerPoints = directionType.triangleCornerPoints(superViewRect: rect,
////                                                              triangleBottomLength: triangleBottomLength,
////                                                              triangleHeight: triangleHeight)
//        // 三角形の描画
//        let triangle = UIBezierPath()
//        triangle.move(to: self.left)
//        triangle.addLine(to: self.top)
//        triangle.addLine(to: self.right)
//        triangle.close()
//        // 内側の色をセット
//        color.setFill()
//        // 内側を塗りつぶす
//        triangle.fill()
//    }
//}
