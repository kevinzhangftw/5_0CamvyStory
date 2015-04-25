//
//  ViewController.swift
//  5_0CamvyStory
//
//  Created by Kevin Zhang on 2015-04-20.
//  Copyright (c) 2015 Kevin Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  let mediaVC = MediaViewController()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    addMediaVC()
  }
  
  func addMediaVC() {
    self.addChildViewController(mediaVC)
    //mediaVC.view.frame = CGRectMake(x, y, width, height)
    self.view.addSubview(mediaVC.view)
    mediaVC.didMoveToParentViewController(self)
  }


  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

