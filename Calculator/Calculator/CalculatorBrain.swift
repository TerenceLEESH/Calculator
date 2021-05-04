//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Terence Lee on 15/10/2020.
//

import Foundation

struct CalculatorBrain{
    private var accumulator: Double?
    private var internalProgram : [Any] = []
    private var sequence : [Any] = []
    private var LastOperation: String?
    private var pendingBinaryOperation: PendingBinaryOperation?
    private var pendingAddMinusOperation:PendingAddMinus?
    private var pendingMultiplyDivideOperation:PendingMultiplyDivide?
    
    private enum Operation{
        case constant(Double)
        case AddMinusOperation((Double,Double)->Double)
        case MultiplyDivideOperation((Double,Double) -> Double)
        case triOperation((Double) -> Double)
        case unaryOperation((Double) -> Double)
        case equals
        case clear
    }
    
    
    private var operations: Dictionary<String, Operation> =
        ["π": Operation.constant(Double.pi),
         "e": Operation.constant(M_E),
         
         "+": Operation.AddMinusOperation({$0+$1}),
         "-": Operation.AddMinusOperation({$0-$1}),
         "x": Operation.MultiplyDivideOperation({$0*$1}),
         "/": Operation.MultiplyDivideOperation({$0/$1}),
         "=": Operation.equals,
         "sqrt": Operation.unaryOperation(sqrt),
         "sin": Operation.triOperation(sin),
         "cos": Operation.triOperation(cos),
         "tan": Operation.triOperation(tan),
         "+/-": Operation.unaryOperation({-$0}),
         "AC": Operation.clear
         
         
        ]
    
    struct PendingBinaryOperation{
        let binaryfunction: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double{
            return binaryfunction(firstOperand, secondOperand)
            
        }
        
    }
    
    struct PendingAddMinus{
        let function: (Double,Double)->Double
        let firstOperand: Double
        func perform(with secondOperand: Double)->Double{
            return function(firstOperand,secondOperand)
        }
    }
    
    struct PendingMultiplyDivide{
        let function: (Double,Double)->Double
        let firstOperand: Double
        func perform(with secondOperand: Double)->Double{
            return function(firstOperand,secondOperand)
        }
    }
    
   
 
    
    private mutating func performPendingBinaryOperation(){
        if (accumulator != nil){
            if(pendingMultiplyDivideOperation != nil && pendingAddMinusOperation != nil){
                accumulator = pendingAddMinusOperation!.perform(with: pendingMultiplyDivideOperation!.perform(with: accumulator!))
            }else if(pendingMultiplyDivideOperation != nil && pendingAddMinusOperation == nil){
                accumulator = pendingMultiplyDivideOperation!.perform(with: accumulator!)
            }else if(pendingMultiplyDivideOperation == nil && pendingAddMinusOperation != nil){
                accumulator = pendingAddMinusOperation!.perform(with: accumulator!)
            }
        }
        pendingMultiplyDivideOperation = nil
        pendingAddMinusOperation = nil
            
    }
    
 
    mutating func performOperation(_ symbol: String){
        internalProgram.append(symbol)
        sequence.append(symbol)
        
        
        if let operation = operations[symbol]{
            switch operation
            {
            case .constant(let value):
                accumulator = value
                
            case .AddMinusOperation(let function):
                if accumulator != nil{
                    switch LastOperation{
                    case "="?, nil:
                        pendingAddMinusOperation = PendingAddMinus(function: function,firstOperand:accumulator!)
                    case "+"?, "-"?:
                    if let Temp = pendingAddMinusOperation{
                        pendingAddMinusOperation = PendingAddMinus(function: function,firstOperand: Temp.perform(with:  accumulator!))
                        pendingMultiplyDivideOperation = nil
                    }
                    case "x"?, "/"?:
                    if(pendingAddMinusOperation != nil){
                        if let Temp = pendingAddMinusOperation{
                            pendingAddMinusOperation = PendingAddMinus(function: function,firstOperand: Temp.perform(with: pendingMultiplyDivideOperation!.perform(with: accumulator!)))
                        pendingMultiplyDivideOperation = nil
                        }
                    }
                    else{
                        pendingAddMinusOperation = PendingAddMinus(function: function,firstOperand:pendingMultiplyDivideOperation!.perform(with:accumulator!))
                        pendingMultiplyDivideOperation = nil
                    }
                    default : break
                }
                accumulator = nil
            }
            
            case .MultiplyDivideOperation(let function):
                if(accumulator != nil){
                    switch LastOperation{
                    case "*"? , "/"? :
                        if let Temp = pendingMultiplyDivideOperation{
                            pendingMultiplyDivideOperation=PendingMultiplyDivide(function: function,
                                firstOperand: Temp.perform(with: accumulator!))
                        }
                    case "+"? , "-"? , "="?,nil:
                        pendingMultiplyDivideOperation=PendingMultiplyDivide(function: function,firstOperand: accumulator!)
                    default : break
                    }
                    accumulator=nil
                }
            
            case.triOperation(let function):
                accumulator = function(accumulator! * Double.pi / 180)
                pendingBinaryOperation = nil
                
            case .equals:
                performPendingBinaryOperation()
                
            case .unaryOperation(let function):
                if accumulator != nil{
                    accumulator = function(accumulator!)
                }
                
            case .clear:
                accumulator = 0.0
                sequence.removeAll()
                
            }
            if(symbol != "π" && symbol != "e" && symbol != "sin" && symbol != "cos" && symbol != "tan"){
                LastOperation = symbol
            }
            
        print("\(sequence)")
            
        }
    }
    
    mutating func setOperand(_ operand: Double){
        accumulator = operand
        internalProgram.append(operand)
        sequence.append(operand)
        print("\(sequence)")
        
        }
    

    
    mutating func clear(){
        accumulator = 0.0
        pendingBinaryOperation = nil
        internalProgram.removeAll()
        

    }
   
   
    typealias PropertyList = Any
    
    var program : PropertyList{
        get{
            return internalProgram as AnyObject
        }
        set{
            clear()
            if let arrayOfOps = newValue as? [AnyObject]{
                for op in arrayOfOps{
                    if let operand = op as? Double{
                        setOperand(operand)
                    }else if let operation = op as? String{
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    var result: Double?{
        get{
            return accumulator
        }
    }
}
