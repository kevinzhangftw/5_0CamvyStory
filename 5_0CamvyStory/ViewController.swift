

import UIKit
import AddressBookUI

class ViewController: UIViewController, UINavigationControllerDelegate {
  
  var recipientNumber: String!
  
  var mediaVC: MediaViewController!
  let messageComposeVC = MFMessageComposer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    
    //wear the delgate hat for messagecomposevc to call people picker factory upon completion
    messageComposeVC.recipientDelegate = self
  }
  
  func setup() {
    presentRecipientVC()
  }
  
  func presentRecipientVC() {
    var peoplePicker = PeoplePickerFactory.returnaPeoplepicker()
    //people picker is an instance of system view controller for displaying system contacts
    peoplePicker.peoplePickerDelegate = self
    //view will be presented through viewdidload
    self.presentViewController(peoplePicker, animated: true){
      self.addMediaVC() //upon completion of presenting viewcontroller, preloading for performance
    }
  }
  
  func addMediaVC() {
    if mediaVC == nil {
      mediaVC = MediaViewController()
      //message delegate to trigger mfmessage upon media completion
      mediaVC.messageDelegate = self
      
      //presenting child viewcontroller
      self.addChildViewController(mediaVC)
      println(mediaVC.view!)
      self.view.addSubview(mediaVC!.view)
      mediaVC!.didMoveToParentViewController(self)
    }
    
  }
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

//class ends here extensions begin

extension ViewController: ABPeoplePickerNavigationControllerDelegate{
  func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!) {
    let (name, number) = PeoplePickerFactory.NameandPhonenumber(person: person)
    mediaVC!.recipientName = name
    recipientNumber = number
    
    self.dismissViewControllerAnimated(true, completion: { () -> Void in
      //start recording here.
    println("start recodring here")
      self.mediaVC!.recordNewVideo()
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

extension ViewController: MFMessageComposerDelegate{
  func mfMessageComposerDidFinish() {
    //TODO: clear textfield, show another people picker
    mediaVC!.recipientName = ""
    presentRecipientVC()
  }
}

