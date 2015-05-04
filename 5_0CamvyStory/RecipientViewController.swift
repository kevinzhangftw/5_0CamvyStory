
import UIKit
import AddressBookUI

//var phoneNumberString: String!
//var personFirstName: String!

protocol RecipientViewControllerDelegate {
  func recipientViewControllerDidFinishPicking()
}

class PeoplePickerFactory: NSObject {
  
        var delegate: RecipientViewControllerDelegate?
//  
//    override func viewDidLoad() {
//      super.viewDidLoad()
//      personPicker.peoplePickerDelegate = self
//      self.presentViewController(personPicker, animated: false, completion: nil)
//    }
  
  override init() {
    super.init()
    println("PeoplePickerFactory overriding init")
    setup()
  }
  
  func setup(){
  //
  }
  
  static func returnaPeoplepicker ()-> ABPeoplePickerNavigationController {
    let personPicker = ABPeoplePickerNavigationController()
        return personPicker
    
  }
  
  //return phoneNumberString and personFirstNameString from ABRecordRef 
  static func NameandPhonenumber(#person: ABRecordRef) -> (String, String){
    
    let phones: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
    
    let personFirstName = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue() as! String
    
    var phoneNumberString: String!
   
    let phoneNumbersCount:Int = ABMultiValueGetCount(phones)
    for var i = 0 ; i < phoneNumbersCount ; i++ {
      phoneNumberString =
        ABMultiValueCopyValueAtIndex(phones, i).takeRetainedValue() as! String
      
    }
    return (personFirstName, phoneNumberString)
  }
  
}

extension PeoplePickerFactory: ABPeoplePickerNavigationControllerDelegate{
  //peoplePickerDelegate
  func peoplePickerNavigationController( peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!) {
  
    PeoplePickerFactory.NameandPhonenumber(person: person)
  }

}


