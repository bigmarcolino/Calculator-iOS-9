//
//  GraphViewController.swift
//  Calculator
//
//  Created by Marcus Vinícius on 26/10/16.
//  Copyright © 2016 Marcus Vinícius. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(graphView.zoom)))

            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(graphView.move)))

            let recognizer = UITapGestureRecognizer(target: graphView, action: #selector(graphView.doubleTap))
            
            recognizer.numberOfTapsRequired = 2
            
            graphView.addGestureRecognizer(recognizer)
        }
    }
    
    func getBounds() -> CGRect {
        return navigationController?.view.bounds ?? view.bounds
    }
    
    func getYCoordinate(x: CGFloat) -> CGFloat? {
        if let function = function {
            return CGFloat(function(x))
        }
        
        return nil
    }
    
    var function: ((CGFloat) -> Double)?
}
