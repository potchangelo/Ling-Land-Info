//
//  InputViewController.swift
//  Ling Land Info
//
//  Created by Potchara Puttawanchai on 25/4/2561 BE.
//  Copyright © 2561 Potchara Puttawanchai. All rights reserved.
//

import UIKit
import GoogleMaps

class InputViewController: UIViewController {
    
    // MARK: - Variables : Model
    
    var newPlan: Plan?
    
    // MARK: Variables : Storyboard UI
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var inputsGroupStackView: UIStackView!
    
    // MARK: - Constant
    
    let inputsGroupCount = 4
    let generatePlanSegue = "generate-plan-segue"
    
    // TODO: -- Sample Data, uncomment for quick test
    
    /*let sampleData: [[String: Double]] = [
        ["x": 13.798708, "y": 100.542236],
        ["x": 13.798853, "y": 100.544133],
        ["x": 13.801279, "y": 100.544950],
        ["x": 13.802988, "y": 100.542164]
    ]*/
    
    // MARK: - Functions : Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Load each coordinate inputs stack view from xib file (create 4 views)
        // Into storyboard inputs group stack view
        // And save references to all inputs, for getting data
        for i in 1 ... self.inputsGroupCount {
            let inputsStackView = UINib(nibName: "InputsStackView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! InputsStackView
            inputsStackView.inputsGroupLabel.text = "Coordinate #\(i)"
            
            inputsStackView.xTextField.delegate = self
            inputsStackView.yTextField.delegate = self
            
            // TODO: -- Sample Data, uncomment for quick test
            
            /*let data = self.sampleData[i-1]
            inputsStackView.xTextField.text = "\(data["x"]!)"
            inputsStackView.yTextField.text = "\(data["y"]!)"*/
            
            self.inputsGroupStackView.addArrangedSubview(inputsStackView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add keyboard frame observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove keyboard frame observers
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.generatePlanSegue {
            let vc = segue.destination as! MapViewController
            vc.plan = self.newPlan
        }
    }
    
    // MARK: - Functions : Keyboard events
    
    @objc func keyboardWillShow(notification: NSNotification) {
        // Get keyboard size
        var userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        
        // Update related views
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardSize.height + 16
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // Update related views
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    // MARK: - Functions : storyboard UI actions
    
    @IBAction func generatePlanClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.newPlan = Plan()
        for view in self.inputsGroupStackView.subviews {
            guard let inputsStackView = view as? InputsStackView else { continue }
            guard let x = Double(inputsStackView.xTextField.text!), let y = Double(inputsStackView.yTextField.text!) else { continue }
            let coord = CLLocationCoordinate2DMake(x, y)
            newPlan?.addCoordinate(coord)
        }
        performSegue(withIdentifier: self.generatePlanSegue, sender: self)
    }
    
}

// MARK: - Extension : UITextFieldDelegate

extension InputViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

