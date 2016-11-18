//
//  AnimationType.swift
//  EightQueen
//
//  Created by Leif on 18/10/2016.
//  Copyright © 2016 Leif. All rights reserved.
//

class AnimationType{
    /*
     -2 清除攻击
     -1	空白
     0	出现
     1	消失
     2	移动(位置加1)
     3	攻击
     4	冲突
     5	答案
     6	闪烁(单)
     7	闪烁(双)
     8	单个答案
     9	攻击，循环过程中
     */
    var type: Int!, from: Int!, to: Int!, fromColumn: Int!, toColumn: Int!
    
    init(type: Int, from: Int, to: Int){
        self.type = type
        self.from = from
        self.to = to
    }
    
    init(type: Int, from: Int, to: Int, fromColumn: Int, toColumn: Int){
        self.type = type
        self.from = from
        self.to = to
        self.fromColumn = fromColumn
        self.toColumn = toColumn
    }
}
