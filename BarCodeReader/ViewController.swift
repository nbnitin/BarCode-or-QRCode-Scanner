//
//  ViewController.swift
//  BarCodeReader
//
//  Copyright © 2020 Nitin. All rights reserved.
//

import UIKit

class ViewController: UIViewController,ScannerDelegate {
    
    let x = ScannerViewController()

    var qrCodeFrameView: UIView?

    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.addChild(x)
        containerView.addSubview(x.view)
        x.didMove(toParent: self)
        x.delegate = self
    }
    
    //Mark:- view did appear
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(true)
        //setting up green line
           setupGreenLine()
    }
       
    //Mark:- setting up green line with animation
    func setupGreenLine(){
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView(frame: CGRect(x: 0, y: 30, width: self.view.frame.width, height: 2))
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.backgroundColor = .green
            containerView.addSubview(qrCodeFrameView)
            self.view.bringSubviewToFront(qrCodeFrameView)
            //animates that green view
            UIView.animate(withDuration: 6.0, delay: 0, options: [.repeat, .autoreverse] , animations: {
                qrCodeFrameView.frame = CGRect(x: 0, y: self.containerView.frame.height, width: qrCodeFrameView.frame.width, height: qrCodeFrameView.frame.height)
            }) { (completed) in

            }
        }

    }
    
    //Mark:-stops the animation
    func stopAnimation(){
        qrCodeFrameView!.layer.removeAllAnimations()
        qrCodeFrameView?.removeFromSuperview()
    }
    
   
    
    //Mark:- scanner delegate functions
    
    //Mark:- called on failed
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    //Mark:- called on success
    func success(code: String) {
        self.stopAnimation()
        let ac = UIAlertController(title: "Scanning done", message: code, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(UIAlertAction) in
            self.x.startScanning()
            self.setupGreenLine()
        }))
        present(ac, animated: true)
        
    }

}

