
import UIKit
import AVFoundation

let mediaMuxer = Muxer()
//global
var someOutputURL:NSURL!

class Muxer: NSObject {
  
  var mutableComposition: AVMutableComposition!
  var mutableVideoComposition: AVMutableVideoComposition!
//  var mutableAudioMix: AVMutableAudioMix?
  var exportSession: AVAssetExportSession!
  
  override init() {
    super.init()
    mutableComposition = AVMutableComposition()
  }

  func mux(#videoUrl:NSURL, and text:String) -> NSURL? {
    let mediaAsset = assetFromURL(videoUrl)
    
    addVideo(mediaAsset)
    addOverlay(mediaAsset, text: text)
//    addAudio(mediaAsset)
    export()
    
    return nil
  }
  
  
  func addVideo(mediaAsset: AVAsset) {
    mutableVideoComposition = mutableVideoComposition(propertiesOfAsset: mediaAsset)
  }
  
  func addOverlay(mediaAsset: AVAsset, text: String) {
    let tempVideoLayer = videoLayer()
    let parentLayer = CALayer()
    //need to be responsive here
    parentLayer.frame = CGRectMake(0, 0, 480, 640)
    parentLayer.addSublayer(tempVideoLayer)
    parentLayer.addSublayer(overlayLayer(overlay(text)))
    mutableVideoComposition.animationTool = animationTool(videoLayer: tempVideoLayer, inLayer: parentLayer)
  }
  
//  func addAudio(mediaAsset: AVAsset) {
//    let mutableAudioTrack = audioCompositionTrack(propertiesofAsset: mediaAsset)
//    mutableAudioMix = audioMix(track: mutableAudioTrack)
//  }
  
  func export() {
    //, audioMix: mutableAudioMix "audio parameter removed"
    self.exportSession = exportSession(composition: mutableComposition.copy() as! AVComposition, videoComposition: mutableVideoComposition, outputURL: outputURL())
    
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
    composition.frameDuration = CMTimeMake(1, 10)
    //TODO: reduce video duration
    return composition
  }
  
  ///configuring text. needs to be redone here no hardcoding
  func overlay(text: String) -> CATextLayer {
    let overlayText = CATextLayer()
    overlayText.font = "Helvetica"
    overlayText.fontSize = 45
    overlayText.frame = CGRectMake(0, 0, self.videoLayer().bounds.width, 100)
    println("self.videoLayer().bounds.width: \(self.videoLayer().bounds.width)")
    overlayText.string = text
    overlayText.alignmentMode = kCAAlignmentCenter
    overlayText.foregroundColor = UIColor.whiteColor().CGColor
    overlayText.backgroundColor = UIColor.clearColor().CGColor
    return overlayText
  }
  
  func overlayLayer(textLayer:CALayer) -> CALayer {
    let overlayLayer = CALayer()
    overlayLayer.addSublayer(textLayer)
    overlayLayer.backgroundColor = UIColor.clearColor().CGColor
    overlayLayer.frame = CGRectMake(0, (self.videoLayer().bounds.height)/1.4, self.videoLayer().bounds.width, 100)
    println("self.videoLayer().bounds.height: \(self.videoLayer().bounds.height)")
    overlayLayer.masksToBounds = true
//    overlayLayer.opacity = 0.8
    return overlayLayer
  }
  
  func videoLayer() -> CALayer {
    let videoLayer = CALayer()
//TODO: hardcoded frame, needs to be responsive for all ios devices
    videoLayer.frame = CGRectMake(0, 0, 480, 640)
//    videoLayer.opacity = 0.5
    return videoLayer
  }
  
  func animationTool(#videoLayer: CALayer, inLayer: CALayer) -> AVVideoCompositionCoreAnimationTool {
    return AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: inLayer)
  }
  
//  func audioCompositionTrack(propertiesofAsset mediaAsset: AVAsset) -> AVMutableCompositionTrack{
//    var error: NSError?
//    let mutableAudioTrack = mutableComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID( kCMPersistentTrackID_Invalid))
//    mutableAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, mediaAsset.duration),
//      ofTrack: mediaAsset.tracksWithMediaType(AVMediaTypeAudio)[0] as! AVAssetTrack,
//      atTime: kCMTimeZero,
//      error: &error)
//    assert(error == nil, "audio error!! \(error)")
//    return mutableAudioTrack
//  }
  
  
//  func audioMix(#track: AVCompositionTrack) -> AVMutableAudioMix {
//    let mixParameters:AVAudioMixInputParameters = AVMutableAudioMixInputParameters(track: track)
//    let audioMix = AVMutableAudioMix()
//    audioMix.inputParameters = [mixParameters]
//    return audioMix
//  }
  
  //, audioMix: mutableAudioMix "audio parameter removed"
  func exportSession(#composition: AVComposition, videoComposition:AVVideoComposition, outputURL:NSURL) -> AVAssetExportSession {
    
    //AVAssetExportSession init with 2 parameters; the avasset to export and the preset
    let exportSession = AVAssetExportSession(asset: composition as AVAsset, presetName: AVAssetExportPresetHighestQuality)
    
    //the exportsession configuration
    exportSession.videoComposition = videoComposition
//    exportSession.audioMix = audioMix
    exportSession.outputURL = outputURL
    println("exportSession.outputURL: \(exportSession.outputURL)")
    exportSession.outputFileType = AVFileTypeQuickTimeMovie
    
    return exportSession
  }
  
  
  func didFinishExporting() {
    println("didFinishExporting!!!")
  }
  
  
  
  func assetFromURL(url:NSURL) -> AVAsset {
    return AVAsset.assetWithURL(url) as! AVAsset
  }
}

  func outputURL() -> NSURL {
    var outputString = ""
    let timeInterval = NSDate().timeIntervalSince1970
    let success = NSFileManager.defaultManager().createDirectoryAtPath(NSHomeDirectory().stringByAppendingPathComponent("Documents/rawrDirectory"), withIntermediateDirectories: false, attributes: nil, error: nil);
    if success {
      println("Creating directory successful!")
      outputString = NSHomeDirectory().stringByAppendingPathComponent("Documents/rawrDirectory" + "\(timeInterval)" + "-movie.m4v")
    }else{
      println("Creating directory on time interval otherwise")
      outputString = NSHomeDirectory().stringByAppendingPathComponent("Documents/" + "\(timeInterval)" + "-movie.m4v")
    }
  
    someOutputURL = NSURL(fileURLWithPath: outputString, isDirectory: false)!
    println("someOutputURL currentOutputURL:\(someOutputURL)")
    
    return someOutputURL
}