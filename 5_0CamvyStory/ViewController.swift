

import UIKit

class ViewController: UIViewController, RecipientViewControllerDelegate, MediaViewControllerDelegate, MessageComposeViewControllerDelegate {
  
  let mediaVC = MediaViewController()
  let recipientVC = RecipientViewController()
  let messageComposeVC = MessageComposeViewController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    //wear the delgate hats
    recipientVC.delegate = self
    mediaVC.messageDelegate = self
    messageComposeVC.recipientDelegate = self
  }
  
  func setup() {
    addRecipientVC()
  }
  
  func addRecipientVC() {
//    self.addChildViewController(recipientVC)
    recipientVC.didMoveToParentViewController(self)
    self.view.addSubview(recipientVC.view)
  }
  
  func recipientViewControllerDidFinishPicking() {
    //init media VC
    addMediaVC()
  }

  func addMediaVC() {
    self.addChildViewController(mediaVC)
    self.view.addSubview(mediaVC.view)
    mediaVC.didMoveToParentViewController(self)
  }
  
  func messageComposeViewControllerDidFinish() {
    
    //message sent in the background. now we call the recipient again
    addRecipientVC()
  }
  

  func mediaViewControllerDidFinish() {
    
    if messageComposeVC.canSendText(){
      // Obtain a configured MFMessageComposeViewController
      let systemMFMessageComposeVC = messageComposeVC.configuredMessageComposeViewController()
      
      // Present the configured MFMessageComposeViewController instance
      // Note that the dismissal of the VC will be handled by the messageComposer instance,
      // since it implements the appropriate delegate call-back
      presentViewController(systemMFMessageComposeVC, animated: true, completion: nil)
      } else {
        // Let the user know if his/her device isn't able to send text messages
      let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
      errorAlert.show()
      }
    }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

