//
//  Point.swift
//  EightQueen
//
//  Created by Leif on 14/10/2016.
//  Copyright © 2016 Leif. All rights reserved.
//

class Point{
    var x: Int, y: Int, id: Int
    
    init(){
        self.x = 0
        self.y = 0
        self.id = 0
    }
    
    init(x: Int, y: Int){
        self.x = x
        self.y = y
        self.id = 0
    }
    
    init(x: Int, y: Int, id: Int){
        self.x = x
        self.y = y
        self.id = id
    }
}
