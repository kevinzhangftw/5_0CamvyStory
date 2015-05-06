import MessageUI

protocol MFMessageComposerDelegate {
  func mfMessageComposerDidFinish()
}

class MFMessageComposer: NSObject {

  var recipientDelegate: MFMessageComposerDelegate?
  var recipientNumber: String!
  
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

} //class ends here. extension begins

extension MFMessageComposer: MFMessageComposeViewControllerDelegate {
  
  func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
    //dimisssViewcontroller
    controller.dismissViewControllerAnimated(true, completion: nil)
    //trigger receipient vc again
    recipientDelegate?.mfMessageComposerDidFinish()
    
  }

}
