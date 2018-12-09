//
//  ViewController.swift
//  ImageLabeling
//
//  Created by Kanta'MacPro on 5/12/2561 BE.
//  Copyright © 2561 Kanta'MacPro. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var moonImage: UIImageView!
    @IBOutlet weak var cameraImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        assignBackGround()
        moonImage.image = UIImage(named: "blueMoonIMG")
        cameraImage.image = UIImage(named: "cameraIMG")
    }
    
    private func assignBackGround() {
        let background = UIImage(named: "BackGroundIMG")
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }


}

