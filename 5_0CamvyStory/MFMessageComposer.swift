import MessageUI

protocol MFMessageComposerDelegate {
  func mfMessageComposerDidFinish()
}

class MFMessageComposer: NSObject {

  var recipientDelegate: MFMessageComposerDelegate?
  var recipientNumber: String!
  
  // A wrapper function to indicate whether or not a text message can be sent from the user's device
  static func canSendText() -> Bool {
    return MFMessageComposeViewController.canSendText()
  }
  
  func configuredMessageComposeViewController(number: String, attachmentURL: NSURL) -> MFMessageComposeViewController {
    let mfmessageComposeVC = MFMessageComposeViewController()
        mfmessageComposeVC.messageComposeDelegate = self
        mfmessageComposeVC.recipients = [number]
        mfmessageComposeVC.addAttachmentURL(attachmentURL, withAlternateFilename: nil)
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
