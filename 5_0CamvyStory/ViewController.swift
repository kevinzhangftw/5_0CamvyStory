

import UIKit
import AddressBookUI

class ViewController: UIViewController, UINavigationControllerDelegate, MessageComposeViewControllerDelegate {
  
  var mediaVC: MediaViewController?
  let messageComposeVC = MessageComposeViewController()
  var recipientNumber: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    //wear the delgate hats
    
    messageComposeVC.recipientDelegate = self
  }
  
  func setup() {
    presentRecipientVC()
  }
  
  func presentRecipientVC() {
    var peoplePicker = PeoplePickerFactory.returnaPeoplepicker()
    peoplePicker.peoplePickerDelegate = self
    self.presentViewController(peoplePicker, animated: true){
      self.addMediaVC() //preloading for performance
    }
  }
  
  func addMediaVC() {
    //TODO: make idempotent.
    if mediaVC == nil {
      mediaVC = MediaViewController()
      mediaVC!.messageDelegate = self
      self.addChildViewController(mediaVC!)
      self.view.addSubview(mediaVC!.view)
      mediaVC!.didMoveToParentViewController(self)
    }
    
  }
  
  
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

extension ViewController: ABPeoplePickerNavigationControllerDelegate{
  func peoplePickerNavigationController( peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!) {
    let (name, number) = PeoplePickerFactory.NameandPhonenumber(person: person)
    mediaVC!.recipientName = name
    recipientNumber = number
    self.dismissViewControllerAnimated(true, completion: { () -> Void in
      //start recording here.
      //mediaVC. startrecording
    })
  }
}

extension ViewController:  MediaViewControllerDelegate{
  
  func mediaViewControllerDidFinish() {
    if messageComposeVC.canSendText(){
      let systemMFMessageComposeVC = messageComposeVC.configuredMessageComposeViewController(recipientNumber)
      presentViewController(systemMFMessageComposeVC, animated: true, completion: nil)
    } else {
      let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
      errorAlert.show()
    }
  }
}

extension ViewController: MessageComposeViewControllerDelegate{
  func messageComposeViewControllerDidFinish() {
    //TODO: clear textfield, show another people picker
    mediaVC!.recipientName = ""
    presentRecipientVC()
  }
}

