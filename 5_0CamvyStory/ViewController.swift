import UIKit
import AddressBookUI

class ViewController: UIViewController {
  
  var recipientNumber: String!
  
  var mediaVC: MediaViewController!
  let messageComposeInstance: MFMessageComposer = MFMessageComposer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func setup() {
    presentRecipientVC()
    //messagecomposevc to call here when the message is sent.
    messageComposeInstance.recipientDelegate = self
  }
  
  func presentRecipientVC() {
    var peoplePicker = PeoplePickerFactory.returnaPeoplepicker()
    //peoplepicker extension below
    peoplePicker.peoplePickerDelegate = self
    //peoplepicker view will be presented through viewdidload
    self.presentViewController(peoplePicker, animated: false){
      self.addMediaVC() //upon completion of presenting viewcontroller, preloading for performance
    }
  }
  
  func addMediaVC() {
    if mediaVC == nil {
      mediaVC = MediaViewController()
      //message delegate to trigger mfmessage upon media completion
      mediaVC.messageDelegate = self
      
      //presenting child viewcontroller?? why??
      self.addChildViewController(mediaVC)
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
    println("kevin says start recording here")
      self.mediaVC!.recordNewVideo()
    })
  }
}

extension ViewController: MediaViewControllerDelegate{
  func mediaViewControllerDidFinish() {
    if messageComposeInstance.canSendText(){
      let systemMFMessageComposeVC = messageComposeInstance.configuredMessageComposeViewController(recipientNumber)
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

