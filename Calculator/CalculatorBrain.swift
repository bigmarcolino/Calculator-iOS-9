//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Marcus Vinícius on 27/09/16.
//  Copyright © 2016 Marcus Vinícius. All rights reserved.
//

import Foundation

class CalculatorBrain {
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    private var resultAccumulator = 0.0
    
    private var internalProgram = [AnyObject]()
    
    var variableValues = [String:Double]()
    
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Precedence.Max
            }
        }
    }
    
    private var currentPrecedence = Precedence.Max
    
    func clear() {
        pending = nil
        resultAccumulator = 0.0
        descriptionAccumulator = "0"
        internalProgram.removeAll()
    }
    
    func setOperand(operand: Double) {
        resultAccumulator = operand
        descriptionAccumulator = String(format:"%g", operand)
        internalProgram.append(operand as AnyObject)
    }
    
    func setOperand(variableName: String) {
        variableValues[variableName] = variableValues[variableName] ?? 0.0
        resultAccumulator = variableValues[variableName]!
        descriptionAccumulator = variableName
        internalProgram.append(variableName as AnyObject)
    }
    
    private enum Precedence: Int {
        case Min = 0, Max
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UnaryOperation({ -$0 }, { "-(\($0))"}),
        "√" : Operation.UnaryOperation(sqrt, { "√(\($0))"}),
        "cos" : Operation.UnaryOperation(cos, { "cos(\($0))"}),
        "sin" : Operation.UnaryOperation(sin, { "sin(\($0))"}),
        "tan" : Operation.UnaryOperation(tan, { "tan(\($0))"}),
        "×" : Operation.BinaryOperation({ $0 * $1 }, { "\($0) × \($1)"}, Precedence.Max),
        "÷" : Operation.BinaryOperation({ $0 / $1 }, { "\($0) ÷ \($1)"}, Precedence.Max),
        "+" : Operation.BinaryOperation({ $0 + $1 }, { "\($0) + \($1)"}, Precedence.Min),
        "−" : Operation.BinaryOperation({ $0 - $1 }, { "\($0) - \($1)"}, Precedence.Min),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Precedence)
        case Equals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        
        if let operation = operations[symbol] {
            switch operation {
                
            case .Constant(let value):
                resultAccumulator = value
                descriptionAccumulator = symbol
                
            case .UnaryOperation(let resultFunction, let descriptionFunction):
                resultAccumulator = resultFunction(resultAccumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
                
            case .BinaryOperation(let resultFunction, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence.rawValue < precedence.rawValue {
                    descriptionAccumulator = "(\(descriptionAccumulator))"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: resultFunction, firstOperand: resultAccumulator,
                                                     descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
                
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    func undo() {
        if !internalProgram.isEmpty {
            internalProgram.removeLast()
            program = internalProgram as CalculatorBrain.PropertyList
        } else {
            clear()
            descriptionAccumulator = ""
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            resultAccumulator = pending!.binaryFunction(pending!.firstOperand, resultAccumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    var result: Double {
        get {
            return resultAccumulator
        }
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
                    } else if let variableName = op as? String {
                        if variableValues[variableName] != nil {
                            setOperand(variableName: variableName)
                        } else if let operation = op as? String {
                            performOperation(symbol: operation)
                        }
                    }
                }
            }
        }
    }
    
    func getDescription() -> String {
        let whitespace = (description.hasSuffix(" ") ? "" : " ")
        return isPartialResult ? (description + whitespace  + "...") : (description + whitespace  + "=")
    }
}
