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
    
    private var brain = CalculatorBrain()
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display.text!
        
        if userIsInTheMiddleOfTyping {
            if digit == "." && !addedPoint {
                display.text = textCurrentlyInDisplay + digit
                addedPoint = true
            }
            else if digit != "." {
                display.text = textCurrentlyInDisplay + digit
            }
            
            userIsInTheMiddleOfTyping = true
        }
        else if digit != "." {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
        else if digit == "." && !addedPoint {
            display.text = "0" + digit
            userIsInTheMiddleOfTyping = true
            addedPoint = true
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
    
    private var descriptionValue: String {
        get {
            return displayDescription.text!
        }
        set {
            displayDescription.text = newValue
        }
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
            addedPoint = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
            displayValue = brain.result
            descriptionValue = brain.calcDescription
        }
    }

}
