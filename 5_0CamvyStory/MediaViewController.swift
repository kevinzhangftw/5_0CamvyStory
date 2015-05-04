
import UIKit

protocol MediaViewControllerDelegate {
  func mediaViewControllerDidFinish()
}

class MediaViewController: UIViewController {

  var messageDelegate: MediaViewControllerDelegate?
  
  var videoCamera: GPUImageVideoCamera!
  var videoView: GPUImageView!
  dynamic var movieWriter: GPUImageMovieWriter!
  var textField: UITextField!
  var currentOutputURL: NSURL!
  var recipientName: String! {
    didSet{
      textField.attributedText = textFieldAttributedString(recipientName)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(animated: Bool) {
    videoCamera.startCameraCapture()
    recordNewVideo()
  }
  
  func recordNewVideo() {
    setupMovieWriter()
    movieWriter.startRecording()
  }
  
  override func viewDidAppear(animated: Bool) {
    textField.becomeFirstResponder() //animated keyboard slide-in
  }

  
  func setup(){
    setupVideoCamera()
    setupVideoView()
    setupTextInput()
  }

  func setupVideoCamera(){
    videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Front)
    videoCamera.outputImageOrientation = .Portrait
    videoCamera.horizontallyMirrorFrontFacingCamera = true
  }

  func setupVideoView() {
    //preview layer setup. maybe adjust video gravity later... perhaps with crop filter?
    if videoView == nil {
      videoView = GPUImageView(frame: self.view.bounds)
      view.addSubview(videoView)
      assert(videoCamera != nil, "videoCamera is nil!!")
      videoCamera.addTarget(videoView)
    }
  }

  func setupMovieWriter() {
    assert(videoCamera != nil, "videoCamera is nil!!!")
    movieWriter = GPUImageMovieWriter(movieURL: outputURL(), size: outputSize())
    movieWriter.shouldPassthroughAudio = true
    videoCamera.addTarget(movieWriter)
    videoCamera.audioEncodingTarget = movieWriter
    //TODO: make idempotent
    //TODO: consolidate behavior with filters.
    
  }
  
  
  func outputSize() -> CGSize {
    return CGSizeMake(480.0, 640.0)
  }
  
  func outputURL() -> NSURL {
    //set up time interval part of the url
    let timeInterval = NSDate().timeIntervalSince1970
    //set up the url in string format in the homedirectory which is the sandbox for ios
    let outputString = NSHomeDirectory().stringByAppendingPathComponent("Documents/" + "\(timeInterval)" + "-movie.m4v")
    //NSURL object initialized to outputString
    currentOutputURL = NSURL(fileURLWithPath: outputString, isDirectory: false)!
    println("outputURL currentOutputURL:\(currentOutputURL)")
    return currentOutputURL
  }

  func setupTextInput() {
    //textfield frame configuration begins here
    let textFieldWidth = self.view.bounds.width
    let textFieldHeight: CGFloat = 100
    textField = UITextField(frame: CGRectMake(0, (self.view.bounds.height - textFieldHeight)/4, textFieldWidth, textFieldHeight))
    textField.backgroundColor = UIColor.redColor()
    textField.delegate = self
    
    //textfield to be become first responder
//    textField.becomeFirstResponder()
    
    textField.font = UIFont(name: "Helvetica", size: 55)
    textField.attributedText = textFieldAttributedString("placeholder")
    textField.textAlignment = NSTextAlignment.Center
    textField.autocapitalizationType = UITextAutocapitalizationType.None
    textField.autocorrectionType = UITextAutocorrectionType.No
    textField.spellCheckingType = UITextSpellCheckingType.No
    textField.keyboardType = UIKeyboardType.Default
    textField.keyboardAppearance = UIKeyboardAppearance.Dark
    textField.returnKeyType = UIReturnKeyType.Done
    textField.enablesReturnKeyAutomatically = true
    
    //add this view
    view.addSubview(textField)
    
  }
  
  func textFieldAttributedString(name:String) -> NSAttributedString {
    return NSAttributedString(
      string: name,
      attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
  }
  
}

extension MediaViewController: UITextFieldDelegate {
 
  func textFieldShouldReturn(textField: UITextField) -> Bool {
      movieWriter.finishRecordingWithCompletionHandler {

        
                //end session upon completion
                self.videoCamera.stopCameraCapture()
        
        //upon completion, pass all the stuff to the muxer to complete the action
        mediaMuxer.mux(videoUrl: self.currentOutputURL, and: textField.attributedText!.string)
        
                //call message composer
                self.messageDelegate?.mediaViewControllerDidFinish()
        
                }
    
    return true
  }
  
}


