//
//  ViewController.swift
//  EightQueen
//
//  Created by Leif on 09/10/2016.
//  Copyright © 2016 Leif. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, CAAnimationDelegate {
    @IBOutlet weak var textFieldN: NSTextField!
    @IBOutlet weak var selectAlgorithm: NSPopUpButton!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var inputRow: NSTextField!
    @IBOutlet weak var inputColumn: NSTextField!
    @IBOutlet weak var cutAnimation: NSButton!
    @IBOutlet weak var showAnswers: NSButton!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var pauseCheck: NSButton!

    var algorithm: EightQueenAlgorithm!
    var n: Int!
    var chessBoardViews: [[NSView]]!, crossViews: [[NSView]]!, cellRects: [[NSRect]]!
    var queens: [NSImageView]!, queensCount: Int = 0
    var frameHeight: CGFloat!, frameWidth: CGFloat!
    var cellHeight: CGFloat!, cellWidth: CGFloat!
    var attackQueen: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.wantsLayer = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func initialize(){
        frameHeight = imageView.frame.height
        frameWidth = imageView.frame.width
        cellHeight = frameHeight / CGFloat(n)
        cellWidth = frameWidth / CGFloat(n)
    }

    @IBAction func generateChessBoard(_ sender: AnyObject) {
        for subView in imageView.subviews{
            subView.removeFromSuperview()
        }
        
        n = Int(textFieldN.stringValue)!
        initialize()
        algorithm = EightQueenAlgorithm(n: n)
        cellRects = [[NSRect]](repeating: [NSRect](repeating: NSRect(), count: n + 1), count: n + 1)
        chessBoardViews = [[NSView]](repeating: [NSView](repeating: NSView(), count: n + 1), count: n + 1)
        crossViews = [[NSView]](repeating: [NSView](repeating: NSView(), count: n + 1), count: n + 1)
        queens = [NSImageView](repeating: NSImageView(), count: n + 1)
        queensCount = 0
        
        var row: Int, column: Int
        for i in 0 ..< n{
            row = i + 1
            for j in 0 ..< n{
                column = j + 1
                cellRects[row][column] = NSRect(x: CGFloat(j) * cellWidth, y: CGFloat(n - row) * cellHeight, width: cellWidth, height: cellHeight)
                switch (row + column) & 1{
                case 1:
                    chessBoardViews[row][column] = BlackCell(frame: cellRects[row][column])
                case 0:
                    chessBoardViews[row][column] = WhiteCell(frame: cellRects[row][column])
                default:
                    break
                }
                
                crossViews[row][column] = GrayCross(frame: cellRects[row][column])
                crossViews[row][column].wantsLayer = true
                crossViews[row][column].alphaValue = 0.0
                
                imageView.addSubview(chessBoardViews[row][column])
                imageView.addSubview(crossViews[row][column])
            }
        }
    }
    
    @IBAction func runDemo(_ sender: AnyObject) {
        algorithm.initialize()
        switch selectAlgorithm.indexOfSelectedItem{
        case 0:
            algorithm.runForce()
            break
        case 1:
            algorithm.runBackTrack()
            break
        case 2:
            algorithm.runBitBackTrack()
            break
        default:
            break
        }
        algorithm.animations.append(AnimationType(type: 5, from: 0, to: 0))
        animationDidStop(CAAnimation(), finished: false)
    }

    @IBAction func addQueen(_ sender: AnyObject) {
        if algorithm == nil{ return }
        let row = Int(inputRow.stringValue), column = Int(inputColumn.stringValue)
        if queensCount < n && algorithm.chessBoard[row!][column!] == 0{
            algorithm.chessBoard[row!][column!] = 1
            queensCount += 1
            algorithm.points.append(Point(x: row!, y: column!, id: queensCount))
            queens[queensCount] = NSImageView(frame: cellRects[row!][column!])
            queens[queensCount].image = #imageLiteral(resourceName: "queen")
            queens[queensCount].wantsLayer = true
            imageView.addSubview(queens[queensCount])
        }
    }
    
    @IBAction func check(_ sender: AnyObject) {
        if algorithm.checkAll(hasChessBoard: true){
            for point in algorithm.points{
                algorithm.position[point.x] = point.y
            }
            algorithm.answers.append(algorithm.position)
            algorithm.animations.append(AnimationType(type: 5, from: 0, to: 0))
        }
        animationDidStop(CAAnimation(), finished: false)
    }
    
    @IBAction func pressTextFieldN(_ sender: AnyObject) {
        generateChessBoard(self)
    }
    
    @IBAction func pressAddQueen(_ sender: AnyObject) {
        addQueen(self)
    }
    
    @IBAction func pressCut(_ sender: AnyObject) {
        if cutAnimation.state == 1{
            showAnswers.state = 0
        }
    }
    
    @IBAction func pressShowAnswers(_ sender: AnyObject) {
        if showAnswers.state == 1{
            for row in 1 ... n{
                for column in 1 ... n{
                    crossViews[row][column].alphaValue = 0.0
                }
            }
            cutAnimation.state = 0
        }
    }
    
    @IBAction func pressPause(_ sender: AnyObject) {
        if pauseCheck.state == 0{
            animationDidStop(CAAnimation(), finished: false)
        }
    }
    
    @IBAction func pressSingleStep(_ sender: AnyObject) {
        animationDidStop(CAAnimation(), finished: false)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let animationTime: Double = timeSlider.doubleValue
        
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 1.0
        alphaAnimation.toValue = 0.0
        alphaAnimation.duration = animationTime
        alphaAnimation.autoreverses = true
        alphaAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let nullAnimation = CAAnimation()
        nullAnimation.duration = 0.0
        nullAnimation.delegate = self
        
        if algorithm.nowAnimation < algorithm.animations.count{
            if showAnswers.state == 1{
                algorithm.nowAnimation = algorithm.animations.count - 1
            }
            
            let animation = algorithm.animations[algorithm.nowAnimation]
            
            if cutAnimation.state == 1{
                switch animation.type{
                case -2,6,7:
                    animation.type = -1
                    break
                case 3,9:
                    animation.type = 7
                    break
                default:
                    break
                }
            }
            
            switch animation.type {
            case -2:
                attackQueen.removeFromSuperview()
                attackQueen.layer?.add(nullAnimation, forKey: nil)
                break
            case -1:
                imageView.layer?.add(nullAnimation, forKey: nil)
                break
            case 0: // 出现
                let index: Int = animation.from, position: Int = animation.to
                queens[index].removeFromSuperview()
                queens[index] = NSImageView(frame: cellRects[index][position])
                queens[index].image = #imageLiteral(resourceName: "queen")
                queens[index].wantsLayer = true
                imageView.addSubview(queens[index])
                
                alphaAnimation.fromValue = 0.0
                alphaAnimation.toValue = 1.0
                if pauseCheck.state == 0{
                    alphaAnimation.delegate = self
                }
                alphaAnimation.autoreverses = false
                
                queens[index].layer?.add(alphaAnimation, forKey: "appear")
                
                break
            case 1: // 消失
                let index: Int = animation.from, position: Int = animation.to
                queens[index].removeFromSuperview()
                queens[index] = NSImageView(frame: cellRects[index][position])
                queens[index].image = #imageLiteral(resourceName: "queen")
                queens[index].wantsLayer = true
                queens[index].alphaValue = 0.0
                imageView.addSubview(queens[index])
                
                if pauseCheck.state == 0{
                    alphaAnimation.delegate = self
                }
                alphaAnimation.autoreverses = false
                
                queens[index].layer?.add(alphaAnimation, forKey: "disappear")
                
                break
            case 2: // 移动
                let index: Int = animation.from, position: Int = animation.to
                queens[index].removeFromSuperview()
                queens[index] = NSImageView(frame: cellRects[index][position])
                queens[index].image = #imageLiteral(resourceName: "queen")
                queens[index].wantsLayer = true
                imageView.addSubview(queens[index])
                
                let moveAnimation = CABasicAnimation(keyPath: "position")
                moveAnimation.fromValue = NSValue(point: cellRects[index][position - 1].origin)
                moveAnimation.toValue = NSValue(point: cellRects[index][position].origin)
                moveAnimation.duration = animationTime
                moveAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                if pauseCheck.state == 0{
                    moveAnimation.delegate = self
                }
                
                queens[index].layer?.add(moveAnimation, forKey: "move")
                break
            case 3,9: // 攻击
                var row: Int, column: Int, toRow: Int, toColumn: Int
                if animation.type == 3{
                    row = algorithm.points[animation.from].x
                    column = algorithm.points[animation.from].y
                    toRow = algorithm.points[animation.to].x
                    toColumn = algorithm.points[animation.to].y
                }else{
                    row = animation.from
                    column = animation.fromColumn
                    toRow = animation.to
                    toColumn = animation.toColumn
                }
                attackQueen = NSImageView(frame: cellRects[row][column])
                attackQueen.image = #imageLiteral(resourceName: "queen")
                attackQueen.alphaValue = 0.5

                let attackAnimation = CABasicAnimation(keyPath: "position")
                attackAnimation.fromValue = NSValue(point: cellRects[row][column].origin)
                attackAnimation.toValue = NSValue(point: cellRects[toRow][toColumn].origin)
                attackAnimation.duration = animationTime
                attackAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                if pauseCheck.state == 0{
                    attackAnimation.delegate = self
                }
                
                imageView.addSubview(attackQueen, positioned: NSWindowOrderingMode.above, relativeTo: nil)
                attackQueen.wantsLayer = true
                attackQueen.layer?.add(attackAnimation, forKey: "attack")
                
                break
            case 4: break
            case 5:
                alphaAnimation.fromValue = 0.0
                alphaAnimation.toValue = 1.0
                
                let answersNo = animation.to
                for (index, value) in algorithm.answers[answersNo!].enumerated(){
                    if index == 0 { continue }
                    let row: Int = index, column: Int = value
                    queens[index].removeFromSuperview()
                    queens[index] = NSImageView(frame: cellRects[row][column])
                    queens[index].image = #imageLiteral(resourceName: "queen")
                    queens[index].wantsLayer = true
                    queens[index].alphaValue = 0.0
                    imageView.addSubview(queens[index])
                    if index == n{
                        if pauseCheck.state == 0{
                            alphaAnimation.delegate = self
                        }
                    }
                    queens[index].layer?.add(alphaAnimation, forKey: "alpha")
                }
                algorithm.animations.append(AnimationType(type: 5, from: 0, to: (answersNo! + 1) % algorithm.answers.count))
                break
            case 6: break
            case 7:
                queens[animation.from].layer?.add(alphaAnimation, forKey: nil)
                if pauseCheck.state == 0{
                    alphaAnimation.delegate = self
                }
                queens[animation.to].layer?.add(alphaAnimation, forKey: nil)
                
                break
            case 8:
                for i in 1 ... n{
                    if i == n {
                        if pauseCheck.state == 0{
                            alphaAnimation.delegate = self
                        }
                    }
                    queens[i].layer?.add(alphaAnimation, forKey: "alpha")
                }
                break
            case 10:
                let row: Int = animation.from, fromColumn: Int = animation.fromColumn, toColumn = animation.toColumn
                queens[row].removeFromSuperview()
                queens[row] = NSImageView(frame: cellRects[row][toColumn!])
                queens[row].image = #imageLiteral(resourceName: "queen")
                queens[row].wantsLayer = true
                imageView.addSubview(queens[row])
                
                let moveAnimation = CABasicAnimation(keyPath: "position")
                moveAnimation.fromValue = NSValue(point: cellRects[row][fromColumn].origin)
                moveAnimation.toValue = NSValue(point: cellRects[row][toColumn!].origin)
                moveAnimation.duration = animationTime
                moveAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                if pauseCheck.state == 0{
                    moveAnimation.delegate = self
                }
                
                queens[row].layer?.add(moveAnimation, forKey: "move")
                break
            case 11:
                let row: Int = animation.from, featureNumber: Int = animation.to
                for i in 0 ..< n{
                    let comp = 1 << i
                    if featureNumber & comp > 0{
                        let column = n - i
                        crossViews[row][column].alphaValue = 1.0
                        alphaAnimation.autoreverses = false
                        alphaAnimation.fromValue = 0.0
                        alphaAnimation.toValue = 1.0
                        crossViews[row][column].layer?.add(alphaAnimation, forKey: nil)
                    }
                }
                nullAnimation.duration = animationTime
                imageView.layer?.add(nullAnimation, forKey: nil)
                
                break
            case 12:
                let row: Int = animation.from, featureNumber: Int = animation.to
                for i in 0 ..< n{
                    let comp = 1 << i
                    if featureNumber & comp > 0{
                        let column = n - i
                        crossViews[row][column].alphaValue = 0.0
                        alphaAnimation.autoreverses = false
                        alphaAnimation.fromValue = 1.0
                        alphaAnimation.toValue = 0.0
                        crossViews[row][column].layer?.add(alphaAnimation, forKey: nil)
                    }
                }
                nullAnimation.duration = animationTime
                imageView.layer?.add(nullAnimation, forKey: nil)
                
                break
            default:
                break
            }
            
            algorithm.nowAnimation += 1
        }
    }
    
    class WhiteCell: NSView{
        // 普通矩形绘制
        override func draw(_ dirtyRect: NSRect) {
            NSColor.white.setFill()
            
            let path = NSBezierPath(rect: self.bounds)
            // NSBezierPath 矩形路径
            path.fill()
            // 填充路径
        }
    }
    
    class BlackCell: NSView{
        // 普通矩形绘制
        override func draw(_ dirtyRect: NSRect) {
            NSColor.black.setFill()
            
            let path = NSBezierPath(rect: self.bounds)
            // NSBezierPath 矩形路径
            path.fill()
            // 填充路径
        }
    }
    
    class GrayCross: NSView{
        override func draw(_ dirtyRect: NSRect) {
            let bezierPath = NSBezierPath()
            
            // 创建一个矩形，所有边内缩5%
            let drawingRect = NSInsetRect(self.bounds, self.bounds.size.width * 0.15, self.bounds.size.height * 0.15)
            
            // 确定组成绘画的点
            let topLeft = CGPoint(x: drawingRect.minX, y: drawingRect.maxY)
            let topRight = CGPoint(x: drawingRect.maxX, y: drawingRect.maxY)
            let bottomLeft = CGPoint(x: drawingRect.minX, y: drawingRect.minY)
            let bottomRight = CGPoint(x: drawingRect.maxX, y: drawingRect.minY)
            
            // 开始绘制
            bezierPath.move(to: topLeft)
            bezierPath.line(to: bottomRight)
            bezierPath.move(to: topRight)
            bezierPath.line(to: bottomLeft)
            
            bezierPath.lineWidth = 5.0
            NSColor.brown.setStroke()
            bezierPath.stroke()
        }
    }
}
