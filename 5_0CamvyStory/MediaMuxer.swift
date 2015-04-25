
import UIKit
import AVFoundation

let mediaMuxer = MediaMuxer()

class MediaMuxer: NSObject {
  
  var mutableComposition: AVMutableComposition!
  var mutableVideoComposition: AVMutableVideoComposition!
  var mutableAudioMix: AVMutableAudioMix!
  var exportSession: AVAssetExportSession!
  
  override init() {
    super.init()
    mutableComposition = AVMutableComposition()
  }

  func mux(#videoUrl:NSURL, and text:String) -> NSURL? {
    let mediaAsset = assetFromURL(videoUrl)
    

    
    addVideo(mediaAsset)
    addOverlay(mediaAsset, string: text)
    addAudio(mediaAsset)
    export()
    
    return nil
  }
  //
  
  func addVideo(mediaAsset: AVAsset) {
    mutableVideoComposition = mutableVideoComposition(propertiesOfAsset: mediaAsset)
  }
  
  func addOverlay(mediaAsset: AVAsset, string:String) {
    let tempVideoLayer = videoLayer()
    let parentLayer = CALayer()
    parentLayer.frame = CGRectMake(0, 0, 480, 640)
    parentLayer.addSublayer(tempVideoLayer)
    parentLayer.addSublayer(overlayLayer(overlay(text: string)))
    mutableVideoComposition.animationTool = animationTool(videoLayer: tempVideoLayer, inLayer: parentLayer)
  }
  
  func addAudio(mediaAsset: AVAsset) {
    let mutableAudioTrack = audioCompositionTrack(propertiesofAsset: mediaAsset)
    mutableAudioMix = audioMix(track: mutableAudioTrack)
  }
  
  func export() {
    self.exportSession = exportSession(composition: mutableComposition.copy() as! AVComposition, videoComposition: mutableVideoComposition, audioMix: mutableAudioMix, outputURL: outputURL())
    
    self.exportSession.exportAsynchronouslyWithCompletionHandler {
      if self.exportSession.status == .Completed {
        let path = self.exportSession.outputURL.relativePath!
        println("self.exportSession.outputURL.relativePath: \(self.exportSession.outputURL.relativePath)")
 
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
          dispatch_async(dispatch_get_main_queue()){
           UISaveVideoAtPathToSavedPhotosAlbum(self.exportSession.outputURL.relativePath, nil, nil, nil)
          }
        }
        
      } else {
        println("self.exportSession.error: \(self.exportSession.error)")
      }
    }
  }
  
  ///
  
  ///insert track with time range
  func videoCompositionTrack(#asset: AVAsset) -> AVMutableCompositionTrack{
    let videoTrack = mutableComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID( kCMPersistentTrackID_Invalid))
    var error: NSError?
    videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration),
      ofTrack: asset.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack,
      atTime: kCMTimeZero,
      error: &error)
    assert(error == nil, "We have a muxing error!!! \(error)")
    return videoTrack
  }
 
  ///configuring the properties of the layer of the avcompoistion track
  func videoCompositionLayerInstruction(#assetTrack: AVCompositionTrack) -> AVMutableVideoCompositionLayerInstruction {
    let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
    videoLayerInstruction.setTransform(assetTrack.preferredTransform, atTime: kCMTimeZero)
    videoLayerInstruction.setOpacity(0, atTime: assetTrack.asset.duration)
    return videoLayerInstruction;
  }
  
  ///configure the properties of the avcomposition track
  func videoCompositionInstruction(#assetTrack: AVCompositionTrack) -> AVMutableVideoCompositionInstruction {
    let videoInstruction = AVMutableVideoCompositionInstruction()
    videoInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, assetTrack.asset.duration)
    let videoLayerInstruction = videoCompositionLayerInstruction(assetTrack: assetTrack)
    videoInstruction.layerInstructions = [videoLayerInstruction]
    return videoInstruction
  }
  
  func mutableVideoComposition (propertiesOfAsset asset: AVAsset) -> AVMutableVideoComposition{
    let composition = AVMutableVideoComposition(propertiesOfAsset: asset)
    let videoTrack = videoCompositionTrack(asset: asset);
    let videoInstruction = videoCompositionInstruction(assetTrack: videoTrack)
    composition.instructions = [videoInstruction]
    composition.renderSize = CGSizeMake(480, 640) //Variable.
    composition.frameDuration = CMTimeMake(1, 30)
    return composition
  }
  
  ///configuring text. needs to be redone here no hardcoding
  func overlay(#text:String) -> CATextLayer {
    let overlayText = CATextLayer()
    overlayText.font = "Helvetica"
    overlayText.fontSize = 36
    overlayText.frame = CGRectMake(0, 0, 100, 100)
    overlayText.string = text
    overlayText.alignmentMode = kCAAlignmentCenter
    overlayText.foregroundColor = UIColor.whiteColor().CGColor
    overlayText.backgroundColor = UIColor.blackColor().CGColor
    return overlayText
  }
  
  func overlayLayer(textLayer:CALayer) -> CALayer {
    let overlayLayer = CALayer()
    overlayLayer.addSublayer(textLayer)
    overlayLayer.backgroundColor = UIColor.darkGrayColor().CGColor
    overlayLayer.frame = CGRectMake(0, 0, 100, 100)
    overlayLayer.masksToBounds = true
    overlayLayer.opacity = 0.8
    return overlayLayer
  }
  
  func videoLayer() -> CALayer {
    let videoLayer = CALayer()
    videoLayer.frame = CGRectMake(0, 0, 480, 640)
    videoLayer.opacity = 0.5
    return videoLayer
  }
  
  func animationTool(#videoLayer: CALayer, inLayer: CALayer) -> AVVideoCompositionCoreAnimationTool {
    return AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: inLayer)
  }
  
  func audioCompositionTrack(propertiesofAsset mediaAsset: AVAsset) -> AVMutableCompositionTrack{
    var error: NSError?
    let mutableAudioTrack = mutableComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID( kCMPersistentTrackID_Invalid))
    mutableAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, mediaAsset.duration),
      ofTrack: mediaAsset.tracksWithMediaType(AVMediaTypeAudio)[0] as! AVAssetTrack,
      atTime: kCMTimeZero,
      error: &error)
    assert(error == nil, "audio error!! \(error)")
    return mutableAudioTrack
  }
  
  
  func audioMix(#track: AVCompositionTrack) -> AVMutableAudioMix {
    let mixParameters:AVAudioMixInputParameters = AVMutableAudioMixInputParameters(track: track)
    let audioMix = AVMutableAudioMix()
    audioMix.inputParameters = [mixParameters]
    return audioMix
  }
  
  func exportSession(#composition: AVComposition, videoComposition:AVVideoComposition, audioMix:AVAudioMix, outputURL:NSURL) -> AVAssetExportSession {
    let exportSession = AVAssetExportSession(asset: composition as AVAsset, presetName: AVAssetExportPreset640x480)
    exportSession.videoComposition = videoComposition
    exportSession.audioMix = audioMix
    exportSession.outputURL = outputURL
    println("exportSession.outputURL: \(exportSession.outputURL)")
    exportSession.outputFileType = AVFileTypeQuickTimeMovie
    
    return exportSession
  }
  
  //
  
  func didFinishExporting() {
    println("didFinishExporting!!!")
  }
  
  /*
  // 5 - Create exporter
  AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
  presetName:AVAssetExportPresetHighestQuality];
  exporter.outputURL=url;
  exporter.outputFileType = AVFileTypeQuickTimeMovie;
  exporter.shouldOptimizeForNetworkUse = YES;
  [exporter exportAsynchronouslyWithCompletionHandler:^{
  dispatch_async(dispatch_get_main_queue(), ^{
  [self exportDidFinish:exporter];
  });
  }];
*/
  
  
  func assetFromURL(url:NSURL) -> AVAsset {
    return AVAsset.assetWithURL(url) as! AVAsset
  }
 
  
}

var someOutputURL:NSURL!

func outputURL() -> NSURL {
//  let timeInterval = NSDate().timeIntervalSince1970
//  let timeString = String(format: "time%.f", timeInterval)
//  
//  var tempString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first! as! String
//  
//  tempString = tempString.stringByAppendingPathComponent("rawrDirectory/" + timeString + "movie.m4v")
//  
//  let outputString = NSHomeDirectory().stringByAppendingPathComponent(timeString + "-movie.m4v")
//  let output = NSURL(fileURLWithPath: outputString, isDirectory: false)!
//  
//  return NSURL(fileURLWithPath: tempString, isDirectory: false)!
  //make directory first
  var outputString = ""
  let timeInterval = NSDate().timeIntervalSince1970
  
  
  let success = NSFileManager.defaultManager().createDirectoryAtPath(NSHomeDirectory().stringByAppendingPathComponent("Documents/rawrDirectory"), withIntermediateDirectories: false, attributes: nil, error: nil);
  if success {
    println("Creating directory successful!")
    outputString = NSHomeDirectory().stringByAppendingPathComponent("Documents/rawrDirectory" + "\(timeInterval)" + "-movie.m4v")
    
  } else {
    println("Creating directory FAIL!")
    outputString = NSHomeDirectory().stringByAppendingPathComponent("Documents/" + "\(timeInterval)" + "-movie.m4v")
  }
  
  
  someOutputURL = NSURL(fileURLWithPath: outputString, isDirectory: false)!
  println("someOutputURL currentOutputURL:\(someOutputURL)")
  return someOutputURL
  
}