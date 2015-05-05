
//import UIKit
import AddressBookUI

//var phoneNumberString: String!
//var personFirstName: String!

//protocol PeoplePickerFactoryDelegate {
//  func peoplePickerFactoryDidFinishPicking()
//}

class PeoplePickerFactory: NSObject {
  
//        var delegate: PeoplePickerFactoryDelegate?
//
//    override func viewDidLoad() {
//      super.viewDidLoad()
//      personPicker.peoplePickerDelegate = self
//      self.presentViewController(personPicker, animated: false, completion: nil)
//    }
  
//  override init() {
//    super.init()
//    println("PeoplePickerFactory overriding init")
//    setup()
//  }
//  
//  func setup(){
//  //setup enviroment 
//  
//  }
  
  //return an instance of peoplepicker system viewcontroller
  static func returnaPeoplepicker ()-> ABPeoplePickerNavigationController {
    let peoplePicker = ABPeoplePickerNavigationController()
        return peoplePicker
  }
  
  //return phoneNumberString and personFirstNameString from ABRecordRef from viewcontroller
  static func NameandPhonenumber(#person: ABRecordRef) -> (String, String){
    let personFirstName = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue() as! String
    
    let phones: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
    var phoneNumberString: String!
    let phoneNumbersCount: Int = ABMultiValueGetCount(phones)
    for var i = 0 ; i < phoneNumbersCount ; i++ {
      phoneNumberString = ABMultiValueCopyValueAtIndex(phones, i).takeRetainedValue() as! String
    }
    return (personFirstName, phoneNumberString)
  }
  
} //class ends here. extension begins

extension PeoplePickerFactory: ABPeoplePickerNavigationControllerDelegate{
  //peoplePickerDelegate
  func peoplePickerNavigationController( peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!) {
    PeoplePickerFactory.NameandPhonenumber(person: person)
  }

}


