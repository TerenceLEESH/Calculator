//
//  ViewController.swift
//  Calculator
//
//  Created by Terence Lee on 15/10/2020.
//

import UIKit

class ViewController: UIViewController {
    //test
  
    
    //
    var displayValue: Double{
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
        }
    }
    
    var DisplayStoring: Double
    {
        get
        {
            return Double(displayEquation.text!)!
        }
        set
        {
            displayEquation.text = String(newValue)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func digitPressed(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let originalText = display.text!
        let originalText2 = displayEquation.text!
        
        if (userIsInTheMiddleOfTyping){
            display.text = originalText + digit
            displayEquation.text = originalText2 + digit
        }else{
            display.text =  digit
            displayEquation.text = originalText2 + digit
            userIsInTheMiddleOfTyping  = true;
        }
      
        
        print("\(digit) pressed")
    }
    
    @IBOutlet weak var display: UILabel!
    
    private var brain = CalculatorBrain()
    @IBAction func operationPressed(_ sender: UIButton) {
        let o = sender.currentTitle!
        let original = displayEquation.text!

        if userIsInTheMiddleOfTyping{
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let operation = sender.currentTitle{
            brain.performOperation(operation)
            
            displayEquation.text = original + o
            }
        if let result = brain.result{
            displayValue = result
        }
    }
    
    
    @IBOutlet weak var displayEquation: UILabel!
    
    @IBAction func ClearButton(_ sender: UIButton) {
        displayEquation.text = " "
    }
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save(_ sender: UIButton) {
        savedProgram = brain.program
    }
    
    @IBAction func restore(_ sender: UIButton) {
        if savedProgram != nil{
            brain.program = savedProgram!
            if let result = brain.result{
            displayValue = result
            }
        }
    }
}

