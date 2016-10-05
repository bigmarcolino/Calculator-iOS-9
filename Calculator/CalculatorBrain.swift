//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Marcus Vinícius on 27/09/16.
//  Copyright © 2016 Marcus Vinícius. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    private var description = ""
    
    private func reset() {
        accumulator = 0.0
        description = ""
        pending = nil
        constant = ""
        hasPendingAfterUnaryOperation = false
        resetDescription = false
        hasEqualsInDescription = false
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UnaryOperation({ -$0 }),
        "C" : Operation.ResetOperation,
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "tan" : Operation.UnaryOperation(tan),
        "acos" : Operation.UnaryOperation(acos),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "-" : Operation.BinaryOperation({ $0 - $1 }),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case ResetOperation
        case Equals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                constant = symbol
                
            case .UnaryOperation(let function):
                if isPartialResult {
                    if constant != "" {
                        description = description.replacingOccurrences(of: "... ", with: "") + symbol + "(" + constant + ") ... "
                        constant = ""
                    }
                    else {
                        description = description.replacingOccurrences(of: "... ", with: "") + symbol + "(" + String(accumulator) + ") ... "
                    }
                    
                    accumulator = function(accumulator)
                    hasPendingAfterUnaryOperation = true
                }
                else {
                    accumulator = function(accumulator)
                    description = symbol + "(" + description.replacingOccurrences(of: " = ", with: "") + ") = "
                    resetDescription = true
                }
                
            case .BinaryOperation(let function):
                if isPartialResult {
                    if constant != "" {
                        description = description.replacingOccurrences(of: "... ", with: "") + constant + " " + symbol + " ... "
                        constant = ""
                    }
                    else {
                        description = description.replacingOccurrences(of: "... ", with: "") + String(accumulator) + " " + symbol + " ... "
                    }
                }
                else {
                    if description.range(of: "=") != nil{
                        hasEqualsInDescription = true
                    }
                    
                    if hasEqualsInDescription {
                        description = description.replacingOccurrences(of: " =", with: "")
                        
                        if constant != "" {
                            if resetDescription {
                                description = constant + " " + symbol + " ... "
                                resetDescription = false
                            }
                            else {
                                description = description + symbol + " ... "
                            }
                            
                            constant = ""
                        }
                        else {
                            if resetDescription {
                                description = String(accumulator) + " " + symbol + " ... "
                                resetDescription = false
                            }
                            else {
                                description = description + symbol + " ... "
                            }
                        }
                        
                        hasEqualsInDescription = false
                    }
                    else {
                        if constant != "" {
                            if resetDescription {
                                description = constant + " " + symbol + " ... "
                                resetDescription = false
                            }
                            else {
                                description = description + constant + " " + symbol + " ... "
                            }
                            
                            constant = ""
                        }
                        else {
                            if resetDescription {
                                description = String(accumulator) + " " + symbol + " ... "
                                resetDescription = false
                            }
                            else {
                                description = description + String(accumulator) + " " + symbol + " ... "
                            }
                        }
                    }
                }
                
                executePendingBinaryOperation()
                
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                
            case .Equals:
                if isPartialResult {
                    if(hasPendingAfterUnaryOperation){
                        description = description.replacingOccurrences(of: "... ", with: "").replacingOccurrences(of: " =", with: "") + " " + symbol + " "
                        hasPendingAfterUnaryOperation = false
                    }
                    else {
                        if constant != "" {
                            description = description.replacingOccurrences(of: "... ", with: "").replacingOccurrences(of: " =", with: "") + constant + " " + symbol + " "
                            constant = ""
                        }
                        else {
                            description = description.replacingOccurrences(of: "... ", with: "").replacingOccurrences(of: " =", with: "") + String(accumulator) + " " + symbol + " "
                        }
                    }
                }
                
                executePendingBinaryOperation()
                
            case .ResetOperation:
                reset()
            }
        }
    }
    
    private var resetDescription = false
    
    private var hasPendingAfterUnaryOperation = false
    
    private var hasEqualsInDescription = false
    
    private var constant = ""
    
    private func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        performOperation(symbol: operation)
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    var calcDescription: String {
        get {
            return description
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
