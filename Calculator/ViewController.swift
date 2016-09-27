//
//  ViewController.swift
//  Calculator
//
//  Created by Marcus Vinícius on 9/19/16.
//  Copyright © 2016 Marcus Vinícius. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var displayDescription: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    private var addedPoint = false
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            if digit == "." && !addedPoint {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + digit
                addedPoint = true
            }
            else if digit != "." {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + digit
            }
            
            userIsInTheMiddleOfTyping = true
        }
        else if digit != "." {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var descriptionValue: Double {
        get {
            return Double(displayDescription.text!)!
        }
        set {
            displayDescription.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
            addedPoint = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
            displayValue = brain.result
        }
    }

}
