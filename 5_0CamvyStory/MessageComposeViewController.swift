
import UIKit
import MessageUI

protocol MessageComposeViewControllerDelegate {
  func messageComposeViewControllerDidFinish()
}

class MessageComposeViewController: UIViewController, MFMessageComposeViewControllerDelegate {

  var recipientDelegate: MessageComposeViewControllerDelegate?
  var recipientNumber: String!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  // A wrapper function to indicate whether or not a text message can be sent from the user's device
  func canSendText() -> Bool {
    return MFMessageComposeViewController.canSendText()
  }
  
  func configuredMessageComposeViewController(number: String) -> MFMessageComposeViewController {
    let mfmessageComposeVC = MFMessageComposeViewController()
        mfmessageComposeVC.messageComposeDelegate = self
        mfmessageComposeVC.recipients = [number]
        mfmessageComposeVC.addAttachmentURL(someOutputURL, withAlternateFilename: nil)
    return mfmessageComposeVC
  }
  
  func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
    //dimisssViewcontroller
    controller.dismissViewControllerAnimated(true, completion: nil)
    //trigger receipient vc again
    recipientDelegate?.messageComposeViewControllerDidFinish()
    
  }

}
