//
//  timeFliesViewController.swift
//  Time Flies Beta
//
//  Created by George Sarantinos on 7/29/17.
//  Copyright © 2017 George Sarantinos. All rights reserved.
//

import UIKit

struct timeFly {
    let name: String!
    let start: Date!
    let end: Date!
    let array: [Any]
}

class timeFliesViewController: UIViewController {
    
    var timeFliesArray = [timeFly]()
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    
    @IBOutlet weak var newTFView: UIView!
    @IBOutlet weak var newTFPlacement: NSLayoutConstraint!
    @IBOutlet weak var newTFButton: UIButton!
    
    var actualStartDate = Date()
    var actualEndDate = Date()
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fetch timeFliesArray from coredata
        
        createStartDatePicker()
        createEndDatePicker()
        newTFView.layer.cornerRadius = 30
        newTFView.layer.borderColor = UIColor.gray.cgColor
        newTFView.layer.borderWidth = 0.5
        newTFView.layer.shadowColor = UIColor.black.cgColor
        newTFView.layer.shadowOffset = CGSize.zero
        newTFView.layer.shadowRadius = 5.0
        newTFView.layer.shadowOpacity = 0.5
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func createStartDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(timeFliesViewController.startDatePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        startDateField.inputView = datePicker
        
    }
    
    func startDatePickerValueChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        startDateField.text = formatter.string(from: sender.date)
        actualStartDate = sender.date
    }
    
    func createEndDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(timeFliesViewController.endDatePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        endDateField.inputView = datePicker
    }
    
    func endDatePickerValueChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        endDateField.text = formatter.string(from: sender.date)
        actualEndDate = sender.date
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func showNewTFMaker(_ sender: Any) {
        newTFPlacement.constant = -35
        newTFButton.isHidden = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func cancelNewTF(_ sender: Any) {
        newTFPlacement.constant = -365
        newTFButton.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        
        nameField.text = ""
        startDateField.text = ""
        endDateField.text = ""
    }
    
    @IBAction func createNewTimeFly(_ sender: Any) {
        let name = nameField.text
        let start = startDateField.text
        let end = endDateField.text
        
        let today = Date()
        
        if today < actualStartDate {
            print(true)
        } else {
            print(false)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        //save timeFliesArray to coredata
        
        self.dismiss(animated: false, completion: nil)
    }

}
