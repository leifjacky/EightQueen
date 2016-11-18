//
//  EightQueenAlgorithm.swift
//  EightQueen
//
//  Created by Leif on 14/10/2016.
//  Copyright © 2016 Leif. All rights reserved.
//

class EightQueenAlgorithm{
    
    var n: Int = 8
    var points = [Point]()
    var position = [Int]()
    var chessBoard = [[Int]]()
    var answers = [[Int]]()
    var numberOfNodes: Int = 0
    var animations = [AnimationType](), nowAnimation: Int = 0
    
    init(){
        initialize()
    }
    
    init(n: Int){
        self.n = n
        initialize()
    }
    
    func initialize() {
        points = [Point](repeating: Point(x: 0, y: 0, id: 0), count: 1)
        position = [Int](repeating: 0, count: n + 1)
        chessBoard = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: n + 1)
        answers = [[Int]]()
        animations = [AnimationType]()
        nowAnimation = 0
        numberOfNodes = 0
    }
    
    func checkAll(hasChessBoard: Bool) -> Bool{
        if hasChessBoard{
            for i in 1 ..< points.count - 1{
                for j in i + 1 ..< points.count{
                    animations.append(AnimationType(type: 7, from: points[i].id, to: points[j].id))
                    if points[i].x == points[j].x || points[i].y == points[j].y || abs(points[i].x - points[j].x) == abs(points[i].y - points[j].y){
                        animations.append(AnimationType(type: 3, from: points[j].id, to: points[i].id))
                        animations.append(AnimationType(type: -2, from: points[j].id, to: points[i].id))
                        return false
                    }
                }
            }
        }else{
            if n > 1{
                for i in 2...n{
                    if !place(k: i){
                        return false
                    }
                }
            }
        }
    
        return true
    }
    
    func place(k: Int) -> Bool{
        if k == 1{ return true }
        for i in 1...k - 1{
            animations.append(AnimationType(type: 7, from: i, to: k))
            if position[k] == position[i] || abs(position[k] - position[i]) == k - i{
                animations.append(AnimationType(type: 9, from: i, to: k, fromColumn: position[i], toColumn: position[k]))
                animations.append(AnimationType(type: -2, from: i, to: k))
                return false
            }
        }
        return true
    }
    
    func runBackTrack(){
        var k = 1
        position[k] = 0
        
        while k>0{
            numberOfNodes += 1
            position[k] += 1
            if position[k] == 1{
                animations.append(AnimationType(type: 0, from: k, to: position[k]))
            }else if position[k] <= n{
                animations.append(AnimationType(type: 2, from: k, to: position[k]))
            }
            
            while position[k] <= n && !place(k: k){
                numberOfNodes += 1
                position[k] += 1
                if position[k] <= n{
                    animations.append(AnimationType(type: 2, from: k, to: position[k]))
                }
            }
            
            if position[k] > n{
                animations.append(AnimationType(type: 1, from: k, to: position[k] - 1))
                numberOfNodes -= 1
                k -= 1
            }else if k == n{
                animations.append(AnimationType(type: 8, from: 0, to: 0))
                foundAnswer()
            }else{
                k += 1
                position[k] = 0
            }
        }
    }
    
    func foundAnswer(){
        answers.append(position)
    }
    
    func runForce(){
        var k = 1
        position[k] = 0
        
        while k>0{
            numberOfNodes += 1
            position[k] += 1
            if position[k] == 1{
                animations.append(AnimationType(type: 0, from: k, to: position[k]))
            }else if position[k] <= n{
                animations.append(AnimationType(type: 2, from: k, to: position[k]))
            }
            
            if position[k] > n{
                animations.append(AnimationType(type: 1, from: k, to: position[k] - 1))
                numberOfNodes -= 1
                k -= 1
            }else if k == n{
                if checkAll(hasChessBoard: false){
                    animations.append(AnimationType(type: 8, from: 0, to: 0))
                    foundAnswer()
                }
            }else{
                k += 1
                position[k] = 0
            }
        }
    }
    
    var fullPosition: Int = 1
    var bit = [Int: Int]()
    
    func runBitBackTrack(){
        bit = [Int: Int]()
        fullPosition = (1 << n) - 1
        
        for i in 0 ..< n{
            let value = 1 << i
            bit[value] = n - i
        }
        
        bitBackTrack(row: 1, column: 0, diagonal: 0, backDiagonal: 0);
    }
    
    func bitBackTrack(row: Int, column: Int, diagonal: Int, backDiagonal: Int){
        var pos: Int, p: Int;
        if column != fullPosition{
            animations.append(AnimationType(type: 11, from: row, to: column | diagonal | backDiagonal))
            pos = fullPosition & (~(column | diagonal | backDiagonal))
            while pos != 0{
                p = pos & -pos
                pos -= p
                if position[row] == 0{
                    animations.append(AnimationType(type: 0, from: row, to: bit[p]!))
                }else{
                    animations.append(AnimationType(type: 10, from: row, to: row, fromColumn: position[row], toColumn: bit[p]!))
                }
                position[row] = bit[p]!
                bitBackTrack(row: row + 1, column: column | p, diagonal: (diagonal | p) >> 1, backDiagonal: (backDiagonal | p) << 1)
            }
            
            animations.append(AnimationType(type: 1, from: row, to: position[row]))
            animations.append(AnimationType(type: 12, from: row, to: column | diagonal | backDiagonal))
            position[row] = 0
        }else{
            animations.append(AnimationType(type: 8, from: 0, to: 0))
            foundAnswer()
        }
    }
}
