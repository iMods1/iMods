//
//  LoginViewController.swift
//  iMods
//
//  Created by Brendon Roberto on 8/29/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var textFieldTapRecognizer: UITapGestureRecognizer!
    var textFieldToResign: UITextField?
    let passwordTextFieldTag = 1
    
    override func viewDidLoad() {
    
    }
    
    func textFieldDidBeginEditing(textField: UITextField!) {
        self.textFieldToResign = textField
        if self.view.gestureRecognizers.count == 0 {
            self.view.addGestureRecognizer(self.textFieldTapRecognizer)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if textField.tag == 1 {
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
            var otherTextField = self.view.viewWithTag(self.passwordTextFieldTag)
            otherTextField?.becomeFirstResponder()
        }
        return false
    }
    
    @IBAction func didTapOutsideTextField(sender: UITapGestureRecognizer) {
        self.textFieldToResign?.resignFirstResponder()
        self.view.removeGestureRecognizer(sender)
    }
    
    @IBAction func didPressLogin(sender: UIButton) {
        // TODO: Implement actual login logic
        self.performSegueWithIdentifier("tabbar_main", sender: self)
    }
    
    @IBAction func didPressRegister(sender: UIButton) {
        // TODO: Implement register logic
        var alert = UIAlertController(title: "Not Implemented", message: "Registering is not implemented! Sorry!", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
