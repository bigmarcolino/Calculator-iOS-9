//
//  ViewController.swift
//  Calculator
//
//  Created by Marcus Vinícius on 9/19/16.
//  Copyright © 2016 Marcus Vinícius. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var graphButton: UIButton!
    
    private var userIsInTheMiddleOfTyping = false
    
    private var brain = CalculatorBrain()
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            
            if digit != "." || textCurrentlyInDisplay.range(of: ".") == nil {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            if digit == "." {
                display.text = "0."
            } else {
                display.text = digit
            }
            
            userIsInTheMiddleOfTyping = true
        }
    }
    
    private var displayValue: Double? {
        get {
            if let text = display.text, let value = NumberFormatter().number(from: text)?.doubleValue {
                return value
            }
            
            return nil
        }
        set {
            if let value = newValue {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = Constants.Math.numberOfDigitsAfterDecimalPoint
                display.text = formatter.string(from: value as NSNumber)
                descriptionLabel.text = brain.getDescription()
            } else {
                display.text = "0"
                descriptionLabel.text = " "
                userIsInTheMiddleOfTyping = false
            }
            
        }
    }
    
    private func updateUI() {
        descriptionLabel.text = (brain.description.isEmpty ? " " : brain.getDescription())
        displayValue = brain.result
        graphButton.isEnabled = !brain.isPartialResult
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        
        updateUI()
    }

    @IBAction func clear(_ sender: UIButton) {
        brain.clear()
        displayValue = 0
        userIsInTheMiddleOfTyping = false
        descriptionLabel.text = ""
    }
    
    @IBAction func getVariable(_ sender: UIButton) {
        brain.setOperand(variableName: Constants.Math.variableName)
        userIsInTheMiddleOfTyping = false
        updateUI()
    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        brain.variableValues[Constants.Math.variableName] = displayValue
        
        if userIsInTheMiddleOfTyping {
            userIsInTheMiddleOfTyping = false
        } else {
            brain.undo()
        }
        
        brain.program = brain.program
        updateUI()
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        guard userIsInTheMiddleOfTyping == true else {
            brain.undo()
            updateUI()
            return
        }
        
        guard var number = display.text else {
            return
        }
        
        number.remove(at: number.index(before: number.endIndex))
        
        if number.isEmpty {
            number = "0"
            userIsInTheMiddleOfTyping = false
        }
        
        display.text = number
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "plot":
                guard !brain.isPartialResult else {
                    NSLog(Constants.Error.partialResult)
                    return
                }
                
                var destinationVC = segue.destination
                if let nvc = destinationVC as? UINavigationController {
                    destinationVC = nvc.visibleViewController ?? destinationVC
                }
                
                if let vc = destinationVC as? GraphViewController {
                    vc.navigationItem.title = brain.description
                    vc.function = {
                        (x: CGFloat) -> Double in
                        self.brain.variableValues[Constants.Math.variableName] = Double(x)
                        self.brain.program = self.brain.program
                        return self.brain.result
                    }
                }
            default: break
            }
        }
    }}
