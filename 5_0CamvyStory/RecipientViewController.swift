//
//  RecipientViewController.swift
//  5_0CamvyStory
//
//  Created by Kevin Zhang on 2015-04-26.
//  Copyright (c) 2015 Kevin Zhang. All rights reserved.
//

import UIKit
import AddressBookUI

var phoneNumberString: String!
var personFirstName: String!

protocol RecipientViewControllerDelegate {
  func recipientViewControllerDidFinishPicking()
}

class RecipientViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate {
  
    let personPicker = ABPeoplePickerNavigationController()
    var delegate: RecipientViewControllerDelegate?
  
    override func viewDidLoad() {
      super.viewDidLoad()
      personPicker.peoplePickerDelegate = self
      self.presentViewController(personPicker, animated: false, completion: nil)
    }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
//    self.presentViewController(personPicker, animated: false, completion: nil)
    //set up constants for layout
  }
    
    //peoplePickerDelegate
    func peoplePickerNavigationController( peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!) {
     
      let phones: ABMultiValueRef =
      ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
      
      personFirstName = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue() as! String
      
      let phoneNumbersCount:Int = ABMultiValueGetCount(phones)
      
      for var i = 0 ; i < phoneNumbersCount ; i++ {
        phoneNumberString =
        ABMultiValueCopyValueAtIndex(phones, i).takeRetainedValue() as! String
        
        println(phoneNumberString)
        println(personFirstName)
      }
      
      delegate?.recipientViewControllerDidFinishPicking()
    }
  
}


