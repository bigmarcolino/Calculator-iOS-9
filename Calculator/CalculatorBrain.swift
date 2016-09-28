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
    
    private var description = ""
    
    private func reset() {
        accumulator = 0.0
        description = ""
        pending = nil
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
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
        "×" : Operation.BinaryOperation({ $0 * $1}),
        "÷" : Operation.BinaryOperation({ $0 / $1}),
        "+" : Operation.BinaryOperation({ $0 + $1}),
        "-" : Operation.BinaryOperation({ $0 - $1}),
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
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                
                
                if isPartialResult {
                    description = description + String(accumulator) + " " + symbol + " ... "
                }
                else {
                    description = description.replacingOccurrences(of: "... ", with: "") + String(accumulator) + " "
                }
                
                executePendingBinaryOperation()
                
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                
            case .Equals:
                executePendingBinaryOperation()
            case .ResetOperation:
                reset()
            }
        }
    }
    
    private func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var isPartialResult: Bool {
        get {
            if pending == nil{
                return true
            }
            else{
                return false
            }
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
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
