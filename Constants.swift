//
//  Constants.swift
//  Calculator
//
//  Created by Marcus Vinícius on 19/10/16.
//  Copyright © 2016 Marcus Vinícius. All rights reserved.
//

import Foundation

struct Constants {
    struct Math {
        static let numberOfDigitsAfterDecimalPoint = 6
        static let variableName = "M"
    }
    
    struct Drawing {
        static let pointsPerUnit = 40.0
    }
    
    struct Error {
        static let data = "Calculadora: fonte de dados não encontrada"
        static let partialResult = "Calculadora: tentando desenhar um resultado parcial"
    }
}
